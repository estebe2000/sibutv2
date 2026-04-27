from authlib.integrations.starlette_client import OAuth
from .config import settings

oauth = OAuth()
oauth.register(
    name='keycloak',
    client_id=settings.KEYCLOAK_CLIENT_ID,
    client_secret=settings.KEYCLOAK_CLIENT_SECRET,
    authorize_url=f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/auth",
    access_token_url=f"http://remaster_keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/token",
    userinfo_endpoint=f"http://remaster_keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/userinfo",
    jwks_uri=f"http://remaster_keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/certs",
    client_kwargs={'scope': 'openid profile email'},
)
