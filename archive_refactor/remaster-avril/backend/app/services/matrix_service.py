import logging
from nio import AsyncClient, LoginResponse, RoomVisibility, RoomMessageText
from app.core.config import settings

logger = logging.getLogger(__name__)

class MatrixService:
    def __init__(self):
        self.client = AsyncClient(settings.MATRIX_HOMESERVER, settings.MATRIX_BOT_USER)
        self.access_token = settings.MATRIX_ACCESS_TOKEN

    async def _ensure_logged_in(self):
        if self.access_token:
            self.client.access_token = self.access_token
            return True
        if settings.MATRIX_BOT_PASSWORD:
            resp = await self.client.login(settings.MATRIX_BOT_PASSWORD)
            if isinstance(resp, LoginResponse):
                self.access_token = resp.access_token
                return True
        return False

    async def send_message(self, room_id: str, message: str, formatted: bool = True):
        logged_in = await self._ensure_logged_in()
        if not logged_in: return None
        try:
            content = {"msgtype": "m.text", "body": message}
            if formatted:
                content["format"] = "org.matrix.custom.html"
                content["formatted_body"] = message.replace("\n", "<br>")
            resp = await self.client.room_send(room_id=room_id, message_type="m.room.message", content=content)
            return getattr(resp, "event_id", None)
        except Exception as e:
            logger.error(f"Matrix Send Error: {e}")
            return None

    async def redact_event(self, room_id: str, event_id: str, reason: str = "Suppression via Hub"):
        logged_in = await self._ensure_logged_in()
        if not logged_in: return False
        try:
            resp = await self.client.room_redact(room_id, event_id, reason=reason)
            return not hasattr(resp, "error")
        except Exception as e:
            logger.error(f"Matrix Redact Error: {e}")
            return False

    async def create_room(self, name: str, topic: str = "", private: bool = True):
        logged_in = await self._ensure_logged_in()
        if not logged_in: return None
        try:
            resp = await self.client.room_create(
                visibility=RoomVisibility.private if private else RoomVisibility.public,
                name=name, topic=topic
            )
            return getattr(resp, "room_id", None)
        except Exception as e:
            logger.error(f"Matrix Room Creation Error: {e}")
            return None

    async def get_room_messages(self, room_id: str, limit: int = 10):
        logged_in = await self._ensure_logged_in()
        if not logged_in: return []
        try:
            resp = await self.client.room_messages(room_id, limit=limit)
            messages = []
            if hasattr(resp, "chunk"):
                for event in resp.chunk:
                    if isinstance(event, RoomMessageText):
                        messages.append({
                            "event_id": event.event_id,
                            "sender": event.sender.split(':')[0].replace('@', ''),
                            "content": event.body,
                            "timestamp": event.server_timestamp
                        })
            return messages
        except Exception as e:
            logger.error(f"Matrix Fetch Error: {e}")
            return []

    async def broadcast_announcement(self, title: str, content: str, room_type: str = "general", priority: str = "normal"):
        rooms = {"general": settings.MATRIX_ROOM_GENERAL}
        room_id = rooms.get(room_type, settings.MATRIX_ROOM_GENERAL)
        prefix = ""
        if priority == "important": prefix = "⚠️ **IMPORTANT**\n"
        elif priority == "critical": prefix = "🚨 **CRITIQUE** (@room)\n"
        formatted_message = f"### {title}\n\n{prefix}{content}"
        event_id = await self.send_message(room_id, formatted_message)
        return room_id, event_id

matrix_service = MatrixService()
