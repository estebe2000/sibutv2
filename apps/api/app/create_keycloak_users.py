import os
import time
from .services.keycloak_service import create_local_user, list_local_users

def setup_test_accounts():
    accounts = [
        {"uid": "tata", "name": "Admin", "surname": "Tata", "email": "tata@univ-test.fr"},
        {"uid": "tbtb", "name": "Directeur", "surname": "Tbtb", "email": "tbtb@univ-test.fr"},
        {"uid": "tctc", "name": "Enseignant", "surname": "Tctc", "email": "tctc@univ-test.fr"},
        {"uid": "tdtd", "name": "Etudiant", "surname": "Tdtd", "email": "tdtd@univ-test.fr"},
    ]

    print("Checking existing users in Keycloak...")
    existing_users = list_local_users()
    existing_uids = [u["username"] for u in existing_users]

    for acc in accounts:
        if acc["uid"] in existing_uids:
            print(f"User {acc['uid']} already exists in Keycloak. Skipping creation.")
            continue
        
        try:
            print(f"Creating user {acc['uid']} in Keycloak...")
            create_local_user(
                username=acc["uid"],
                email=acc["email"],
                first_name=acc["name"],
                last_name=acc["surname"],
                password=acc["uid"] # Password = Username as requested
            )
            print(f"User {acc['uid']} created successfully.")
            # Small sleep to avoid flooding the Keycloak admin API
            time.sleep(0.5)
        except Exception as e:
            print(f"Error creating {acc['uid']}: {e}")

if __name__ == "__main__":
    setup_test_accounts()
