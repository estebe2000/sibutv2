import sys, os
from jinja2 import Environment, FileSystemLoader
from app.models.models import User, UserRole

def test_sidebar_rendering():
    print("--- 🔍 SIDEBAR RENDERING TEST ---")
    template_dir = os.path.join(os.path.dirname(__file__), "templates")
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template("dashboard.html")
    
    # Simulation de l'utilisateur admin-iutlh
    mock_user = User(
        full_name="Admin IUT LH",
        ldap_uid="admin-iutlh",
        role=UserRole.ADMIN,
        roles_json='["ADMIN", "PROFESSOR"]'
    )
    
    try:
        html = template.render(
            user=mock_user, 
            active_role="ADMIN", 
            request={"url": {"path": "/"}}, 
            stats={"users": 0, "activities": 0, "resources": 0},
            data={"recent_activities": []},
            news=[]
        )
        
        # 1. Vérification sélecteur de rôle
        if "Changer de vue" in html:
            print("✅ 'Changer de vue' label FOUND")
        else:
            print("❌ 'Changer de vue' label MISSING")
            
        # 2. Vérification bouton Logout
        if "Quitter" in html or "/logout" in html:
            print("✅ Logout button FOUND")
        else:
            print("❌ Logout button MISSING")
            
        # 3. Vérification des rôles listés
        if "Administrateur" in html or "Enseignant" in html:
            print("✅ Role labels FOUND in dropdown")
        else:
            print("❌ Role labels MISSING in dropdown")
            
    except Exception as e:
        print(f"💥 Rendering Crash: {e}")

if __name__ == "__main__":
    test_sidebar_rendering()
