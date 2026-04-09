import os
import requests
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, BackgroundTasks
from pydantic import BaseModel
from typing import List, Optional
from sqlmodel import Session, select
from ..database import get_session
from ..models import SystemConfig
from ..services.rag import generate_full_knowledge_base, KNOWLEDGE_FILE_PATH
from langchain_mistralai import ChatMistralAI
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage, AIMessage
import fitz  # PyMuPDF

router = APIRouter()

# --- Models ---

class MessageItem(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[MessageItem]
    file_context: Optional[str] = None

class TestConnectionRequest(BaseModel):
    provider: str
    model: str
    endpoint: str
    api_key: str

# --- Helpers ---

def get_config_dict(session: Session):
    configs = session.exec(select(SystemConfig)).all()
    return {c.key: c.value for c in configs}

def get_api_key(session: Session):
    # Backward compatibility helper (used by ingest if needed, but ingest uses logic inside generate?)
    # Actually ingest just calls a function.
    # This helper is kept if needed by other parts, but get_llm supersedes it for chat.
    statement = select(SystemConfig).where(SystemConfig.key == "mistral_api_key")
    config = session.exec(statement).first()
    return config.value if config else ""

def get_llm(config: dict, temp=0, max_tokens=2000):
    provider = config.get('ai_provider', 'codestral')
    api_key = config.get('ai_api_key') or config.get('mistral_api_key')
    endpoint = config.get('ai_endpoint') or os.getenv("MISTRAL_ENDPOINT", "https://codestral.mistral.ai/v1")
    model = config.get('ai_model') or os.getenv("MISTRAL_MODEL", "codestral-latest")

    # Normalize endpoint
    if "/chat/completions" in endpoint:
        endpoint = endpoint.replace("/chat/completions", "")

    # Clean trailing slash for base_url construction if needed
    endpoint = endpoint.rstrip('/')

    if not api_key and provider != 'ollama':
        # Don't raise error immediately to allow test-connection to fail gracefully if needed, 
        # but for chat it will fail.
        pass

    if provider in ['mistral', 'codestral']:
        return ChatMistralAI(
            mistral_api_key=api_key,
            model=model,
            temperature=temp,
            endpoint=endpoint,
            max_tokens=max_tokens
        )
    elif provider in ['openai', 'ollama', 'anthropic', 'azure']:
        # Auto-fix Ollama endpoint for OpenAI compatibility
        if provider == 'ollama' and not endpoint.endswith("/v1"):
            endpoint = f"{endpoint}/v1"
            
        # Use ChatOpenAI as generic client
        return ChatOpenAI(
            api_key=api_key if api_key else "dummy",
            base_url=endpoint,
            model=model,
            temperature=temp,
            max_tokens=max_tokens
        )
    else:
        # Fallback
        return ChatMistralAI(mistral_api_key=api_key, model=model, endpoint=endpoint)

# --- Endpoints ---

@router.post("/extract-text")
async def extract_text(file: UploadFile = File(...)):
    try:
        content = ""
        if file.content_type == "application/pdf":
            pdf_bytes = await file.read()
            doc = fitz.open(stream=pdf_bytes, filetype="pdf")
            for page in doc: content += page.get_text()
        else:
            content = (await file.read()).decode("utf-8")
        return {"text": content, "filename": file.filename}
    except Exception as e:
        print(f"Extraction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/ingest")
async def ingest_knowledge(background_tasks: BackgroundTasks, session: Session = Depends(get_session)):
    """Génère le fichier de contexte global."""
    background_tasks.add_task(generate_full_knowledge_base)
    return {"status": "Ingestion started", "message": "Reconstruction du contexte global en cours..."}

@router.post("/test-connection")
async def test_connection(req: TestConnectionRequest):
    """Test the connection to the LLM provider."""
    try:
        config = {
            'ai_provider': req.provider,
            'ai_model': req.model,
            'ai_endpoint': req.endpoint,
            'ai_api_key': req.api_key
        }
        
        llm = get_llm(config, max_tokens=10)
        # Use simple invoke for test
        response = await llm.ainvoke([HumanMessage(content="Hello, reply with just 'OK'.")])
        return {"status": "success", "response": response.content}
    except Exception as e:
        print(f"Connection Test Failed: {e}")
        # Return error detail to frontend
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/ollama/models")
async def get_ollama_models(endpoint: Optional[str] = None):
    """Scans for Ollama on host and returns models."""
    candidates = []
    if endpoint: candidates.append(endpoint)
    candidates.extend(["http://host.docker.internal:11434", "http://172.17.0.1:11434"])
    
    for url in candidates:
        try:
            # Clean url for tags endpoint
            base = url.rstrip('/')
            if base.endswith("/v1"): base = base.replace("/v1", "")
            
            res = requests.get(f"{base}/api/tags", timeout=2)
            if res.status_code == 200:
                data = res.json()
                models = [m['name'] for m in data.get('models', [])]
                return {"models": models, "endpoint": base}
        except Exception as e:
            print(f"Ollama scan failed for {url}: {e}")
            continue
            
    raise HTTPException(status_code=404, detail="Aucune instance Ollama détectée sur le réseau.")

@router.post("/chat")
async def chat_with_context(request: ChatRequest, session: Session = Depends(get_session)):
    # 1. Load Knowledge Base
    context_data = ""
    if os.path.exists(KNOWLEDGE_FILE_PATH):
        with open(KNOWLEDGE_FILE_PATH, "r", encoding="utf-8") as f:
            context_data = f.read()
    else:
        context_data = "(Aucune donnée de contexte disponible. Veuillez cliquer sur 'Mettre à jour l'IA'.)"

    # 2. Construct System Prompt
    system_prompt = f"""Tu es l'assistant pédagogique expert du BUT Techniques de Commercialisation.
    
    Voici TOUTES les informations officielles (Base de données + Fichiers) :
    
    {context_data}
    
    INSTRUCTIONS :
    - Utilise ces informations pour répondre.
    - Si l'information est dans le texte ci-dessus, cite-la.
    - Si on te demande "toutes les ressources", liste-les toutes (elles sont ci-dessus).
    - Garde un ton professionnel et aide l'utilisateur.
    """

    # 3. Build message history
    messages_payload = [SystemMessage(content=system_prompt)]
    
    # Add file context to the first user message if present
    for i, m in enumerate(request.messages):
        content = m.content
        if i == len(request.messages) - 1 and request.file_context:
            content = f"CONTEXTE FICHIER :\n{request.file_context}\n\nQUESTION :\n{content}"
            
        if m.role in ['bot', 'assistant']:
            messages_payload.append(AIMessage(content=content))
        else:
            messages_payload.append(HumanMessage(content=content))

    try:
        # Get dynamic config and LLM
        config = get_config_dict(session)
        llm = get_llm(config)
        
        # Invoke LLM with full history
        res = await llm.ainvoke(messages_payload)
        bot_reply = res.content
        
        # Cleanup
        bot_reply = bot_reply.replace('［ ［', '［').replace('］ ］', '］')
        return {"response": bot_reply}

    except Exception as e:
        print(f"Erreur Chat History: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur IA : {str(e)}")