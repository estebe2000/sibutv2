import logging
from nio import AsyncClient, LoginResponse
from app.core.config import settings

logger = logging.getLogger(__name__)

class MatrixService:
    def __init__(self):
        self.client = AsyncClient(settings.MATRIX_HOMESERVER, settings.MATRIX_BOT_USER)
        self.access_token = settings.MATRIX_ACCESS_TOKEN

    async def _ensure_logged_in(self):
        """Vérifie que le client est authentifié, sinon tente un login."""
        if self.access_token:
            self.client.access_token = self.access_token
            return True
        
        if settings.MATRIX_BOT_PASSWORD:
            resp = await self.client.login(settings.MATRIX_BOT_PASSWORD)
            if isinstance(resp, LoginResponse):
                self.access_token = resp.access_token
                logger.info("Matrix Bot logged in successfully")
                return True
            else:
                logger.error(f"Matrix Login failed: {resp}")
        
        return False

    async def send_message(self, room_id: str, message: str, formatted: bool = True):
        """Envoie un message dans un salon Matrix."""
        logged_in = await self._ensure_logged_in()
        if not logged_in:
            logger.error("Matrix Bot not logged in, cannot send message")
            return False

        try:
            content = {
                "msgtype": "m.text",
                "body": message
            }
            if formatted:
                # On pourrait ajouter du support Markdown ici
                content["format"] = "org.matrix.custom.html"
                content["formatted_body"] = message.replace("\n", "<br>")

            await self.client.room_send(
                room_id=room_id,
                message_type="m.room.message",
                content=content
            )
            return True
        except Exception as e:
            logger.error(f"Matrix Send Error: {e}")
            return False
        finally:
            await self.client.close()

    async def create_room(self, name: str, topic: str = "", private: bool = True):
        """Crée un nouveau salon sur Matrix."""
        logged_in = await self._ensure_logged_in()
        if not logged_in: return None

        try:
            resp = await self.client.room_create(
                visibility="private" if private else "public",
                name=name,
                topic=topic
            )
            # nio renvoie un objet RoomCreateResponse
            if hasattr(resp, "room_id"):
                logger.info(f"Matrix Room created: {name} ({resp.room_id})")
                return resp.room_id
            return None
        except Exception as e:
            logger.error(f"Matrix Room Creation Error: {e}")
            return None

    async def invite_user(self, room_id: str, user_id: str):
        """Invite un utilisateur dans un salon."""
        logged_in = await self._ensure_logged_in()
        if not logged_in: return False

        try:
            # Assurez-vous que l'user_id est au format @username:domain.com
            if not user_id.startswith("@"):
                user_id = f"@{user_id}:{settings.DOMAIN}"
            
            await self.client.room_invite(room_id, user_id)
            return True
        except Exception as e:
            logger.error(f"Matrix Invite Error: {e}")
            return False

    async def broadcast_announcement(self, title: str, content: str, room_type: str = "general", priority: str = "normal"):
        """Diffuse une annonce formattée."""
        # Mapping des salons (à affiner selon tes IDs réels)
        rooms = {
            "general": settings.MATRIX_ROOM_GENERAL,
            "teachers": settings.MATRIX_ROOM_GENERAL, # Placeholder
            "students": settings.MATRIX_ROOM_GENERAL  # Placeholder
        }
        
        room_id = rooms.get(room_type, settings.MATRIX_ROOM_GENERAL)
        
        prefix = ""
        if priority == "important": prefix = "⚠️ **IMPORTANT**\n"
        elif priority == "critical": prefix = "🚨 **CRITIQUE** (@room)\n"

        formatted_message = f"### {title}\n\n{prefix}{content}"
        
        return await self.send_message(room_id, formatted_message)

matrix_service = MatrixService()
