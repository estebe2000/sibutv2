from fastapi import APIRouter, Request, Depends, HTTPException
from fastapi.responses import HTMLResponse
from sqlmodel import Session, select
from app.core.security import get_current_db_user, engine
from app.services.ai_service import ai_service
import uuid

router = APIRouter(prefix="/ai", tags=["ai"])

@router.get("/ged/list")
async def ai_ged_list(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user or not db_user.ragflow_dataset_id: 
        return HTMLResponse(content='Aucun document.')
    docs = await ai_service.list_documents(db_user.ragflow_dataset_id)
    html = "".join([f'<div class="p-3 bg-slate-50 rounded-xl border border-slate-100 mb-2">{d["name"]}</div>' for d in docs])
    return HTMLResponse(content=html or 'Aucun document.')

@router.post("/ged/upload")
async def ai_ged_upload(request: Request):
    db_user = await get_current_db_user(request)
    form_data = await request.form()
    upload_file = form_data.get("file")
    if not db_user.ragflow_dataset_id:
        db_user.ragflow_dataset_id = await ai_service.get_or_create_dataset(db_user.ldap_uid)
        with Session(engine) as session:
            session.add(db_user)
            session.commit()
            session.refresh(db_user)
    content = await upload_file.read()
    await ai_service.upload_document(db_user.ldap_uid, content, upload_file.filename)
    return HTMLResponse(content="OK")

@router.post("/chat")
async def ai_chat_endpoint(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: raise HTTPException(status_code=401)
    
    if "application/json" in request.headers.get("content-type", ""):
        data = await request.json()
        message = data.get("message")
    else:
        form_data = await request.form()
        message = form_data.get("message")

    if not message: return HTMLResponse("")
    
    session_id = request.session.get("rag_session_id")
    if not session_id:
        session_id = await ai_service.create_session_by_id(ai_service.default_chat_id)
        if session_id: request.session["rag_session_id"] = session_id
        else: return HTMLResponse("<div class='text-red-400 p-4'>Erreur de session IA.</div>")
    
    result = await ai_service.chat(ai_service.default_chat_id, session_id, message)
    answer = result.get("answer", "Zéro réponse.")
    
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
