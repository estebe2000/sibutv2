from app.ldap_utils import verify_credentials
import os

print(f"Testing LDAP connection with Alain Dubois...")
result = verify_credentials("alain.dubois", "password")
print(f"Result: {result}")
