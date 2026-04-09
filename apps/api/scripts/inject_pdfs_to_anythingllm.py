import sys
import os
import io
import time

# Add parent directory to path to allow importing app modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlmodel import Session, select
from app.database import engine
from app.models import Activity, Resource
from app.services.pdf_service import generate_activity_pdf, generate_resource_pdf
from app.services.anythingllm_service import AnythingLLMService

def inject_all_pdfs():
    print("Starting PDF Injection to AnythingLLM...")
    
    try:
        service = AnythingLLMService()
        new_doc_locations = []
        
        with Session(engine) as session:
            # 1. Resources
            resources = session.exec(select(Resource)).all()
            print(f"Found {len(resources)} Resources to process.")
            
            for i, res in enumerate(resources):
                try:
                    print(f"Processing Resource {i+1}/{len(resources)}: {res.code}")
                    pdf_buffer = generate_resource_pdf(res, session)
                    pdf_bytes = pdf_buffer.getvalue()
                    filename = f"Ressource_{res.code}.pdf"
                    
                    loc = service.upload_document_bytes(pdf_bytes, filename)
                    if loc:
                        new_doc_locations.append(loc)
                    else:
                        print(f"Failed to upload {filename}")
                    
                    # Small pause to avoid overwhelming the server
                    time.sleep(0.1)
                except Exception as e:
                    print(f"Error processing resource {res.code}: {e}")

            # 2. Activities
            activities = session.exec(select(Activity)).all()
            print(f"Found {len(activities)} Activities to process.")
            
            for i, act in enumerate(activities):
                try:
                    print(f"Processing Activity {i+1}/{len(activities)}: {act.code}")
                    pdf_buffer = generate_activity_pdf(act, session)
                    pdf_bytes = pdf_buffer.getvalue()
                    filename = f"Fiche_{act.code.replace(' ', '_')}.pdf"
                    
                    loc = service.upload_document_bytes(pdf_bytes, filename)
                    if loc:
                        new_doc_locations.append(loc)
                    else:
                        print(f"Failed to upload {filename}")
                    
                    time.sleep(0.1)
                except Exception as e:
                    print(f"Error processing activity {act.code}: {e}")

        # 3. Update Embeddings
        print(f"Updating embeddings with {len(new_doc_locations)} new documents...")
        
        # Optional: Get old docs to remove them? 
        # For now, let's just add new ones. AnythingLLM might handle duplicates by ID but filenames are unique-ish.
        # Actually, let's try to fetch old docs first to be clean.
        old_docs = service.get_workspace_documents()
        print(f"Found {len(old_docs)} existing documents in workspace.")
        
        # We replace everything with the new set + maybe keeping what was not generated here?
        # To be safe, let's just ADD for now. If we want to replace, we pass old_docs as deletes.
        # The user wants "toutes les infos déjà triées", implies a full update.
        # Let's delete everything old to have a fresh state matching the DB.
        
        # Careful: 'global_knowledge_base.txt' from previous RAG attempt might be there. We should remove it.
        
        res = service.update_embeddings(add_locations=new_doc_locations, remove_locations=old_docs)
        print(f"Embeddings update result: {res}")
        
    except Exception as e:
        print(f"Global Error during injection: {e}")

if __name__ == "__main__":
    inject_all_pdfs()
