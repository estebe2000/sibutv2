from fastapi import APIRouter, Request, Depends, HTTPException
from fastapi.responses import HTMLResponse
from sqlmodel import Session, select
from app.core.security import get_current_db_user, engine
from app.services.ai_service import ai_service
from app.models.models import User
import uuid

router = APIRouter(prefix="/ai", tags=["ai"])

@router.get("/ged/list")
async def ai_ged_list(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: raise HTTPException(status_code=401)
    
    # Initialisation auto du dataset si manquant
    if not db_user.ragflow_dataset_id:
        db_user.ragflow_dataset_id = await ai_service.get_or_create_dataset(db_user.ldap_uid)
        with Session(engine) as session:
            session.add(db_user)
            session.commit()
            session.refresh(db_user)

    docs = await ai_service.list_documents(db_user.ragflow_dataset_id)
    if not docs:
        return HTMLResponse(content='<p class="text-xs italic text-slate-400">Aucun document dans votre base.</p>')
    
    html = "".join([f"""
        <div class="p-3 bg-slate-50 rounded-xl border border-slate-100 mb-2 flex justify-between items-center group">
            <span class="text-[10px] font-bold text-slate-700 truncate">{d['name']}</span>
            <span class="px-2 py-0.5 bg-emerald-100 text-emerald-700 rounded text-[8px] font-black uppercase">Prêt</span>
        </div>
    """ for d in docs])
    return HTMLResponse(content=html)

@router.post("/ged/upload")
async def ai_ged_upload(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: raise HTTPException(status_code=401)
    
    form_data = await request.form()
    upload_file = form_data.get("file")
    if not upload_file: return HTMLResponse(content="Erreur: Fichier manquant")

    # 1. S'assurer que le Dataset existe
    if not db_user.ragflow_dataset_id:
        db_user.ragflow_dataset_id = await ai_service.get_or_create_dataset(db_user.ldap_uid)
        with Session(engine) as session:
            session.add(db_user)
            session.commit()
            session.refresh(db_user)
    
    # 2. Upload et parsing
    content = await upload_file.read()
    success = await ai_service.upload_document(db_user.ragflow_dataset_id, content, upload_file.filename)
    
    return HTMLResponse(content="OK" if success else "Erreur d'upload")

@router.post("/chat")
async def ai_chat_endpoint(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: raise HTTPException(status_code=401)
    
    # Extraction du message
    if "application/json" in request.headers.get("content-type", ""):
        data = await request.json()
        message = data.get("message")
    else:
        form_data = await request.form()
        message = form_data.get("message")

    if not message: return HTMLResponse("")
    
    # --- LOGIQUE DE PERSONNALISATION RAGFLOW ---
    
    # 1. S'assurer que le Dataset (KB) existe
    if not db_user.ragflow_dataset_id:
        db_user.ragflow_dataset_id = await ai_service.get_or_create_dataset(db_user.ldap_uid)
    
    # 2. S'assurer que l'Assistant (Chat) existe et est lié au Dataset
    if not db_user.ragflow_chat_id:
        db_user.ragflow_chat_id = await ai_service.get_or_create_chat(db_user.ldap_uid, db_user.ragflow_dataset_id)
    
    # Mise à jour DB si IDs créés
    with Session(engine) as session:
        session.add(db_user)
        session.commit()
        session.refresh(db_user)

    # 3. Récupérer ou créer la Session de conversation
    if not db_user.ragflow_session_id:
        db_user.ragflow_session_id = await ai_service.get_or_create_session(db_user.ragflow_chat_id)
        with Session(engine) as session:
            session.add(db_user)
            session.commit()
            session.refresh(db_user)
    
    # 4. Poser la question via le RAG personnalisé
    result = await ai_service.ask_question(db_user.ragflow_chat_id, db_user.ragflow_session_id, message)
    answer = result.get("answer", "Désolé, je ne parviens pas à analyser vos documents.")
    
    # En cas de nouvelle session forcée par le SDK
    if "session_id" in result and result["session_id"] != db_user.ragflow_session_id:
        db_user.ragflow_session_id = result["session_id"]
        with Session(engine) as session:
            session.add(db_user); session.commit()

    ai_msg_id = f"msg_{uuid.uuid4().hex[:8]}"
    
    html = f"""
    <div class="flex gap-4 justify-end">
        <div class="bg-blue-600/20 p-6 rounded-[2.5rem] max-w-2xl font-medium text-sm border border-blue-500/20 text-blue-100">{message}</div>
    </div>
    <div class="flex gap-4 animate-in slide-in-from-left duration-500">
        <div class="w-10 h-10 bg-indigo-600 rounded-xl flex items-center justify-center shrink-0 shadow-lg">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 8V4H8"/><rect width="16" height="12" x="4" y="8" rx="2"/></svg>
        </div>
        <div id="{ai_msg_id}" class="bg-white/10 p-6 rounded-[2.5rem] max-w-2xl font-medium text-sm border border-white/5 ai-response prose prose-invert prose-sm">
            {answer}
        </div>
    </div>
    <script>
        if (window.markdownit) {{
            const el = document.getElementById('{ai_msg_id}');
            el.innerHTML = window.markdownit({{html:true}}).render(el.innerHTML.trim());
        }}
        document.getElementById('chat-window').scrollTo({{ top: document.getElementById('chat-window').scrollHeight, behavior: 'smooth' }});
    </script>
    """
    return HTMLResponse(content=html)
