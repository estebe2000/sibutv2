import asyncio
import time
from nio import AsyncClient, RoomMessageText
from datetime import datetime

MATRIX_URL = "http://synapse:8008"
ROOM_ID = "!ERNwyyxESqTcJRNbqp:localhost"
ACCESS_TOKEN = "syt_YWRtaW4taXV0bGg_vXhgHSPoMHDcGoXcuKXn_2Vzpc7"

def format_age(timestamp_ms):
    """Calcule l'âge d'un message de manière lisible."""
    diff = int((time.time() * 1000 - timestamp_ms) / 1000)
    if diff < 60: return f"À l'instant"
    if diff < 3600: return f"Il y a {diff // 60} min"
    if diff < 86400: return f"Il y a {diff // 3600} h"
    return f"Il y a {diff // 86400} j"

async def get_room_messages(room_id_ignored: str = None, limit: int = 5):
    """
    Récupère les vrais derniers messages du salon Matrix Annonces.
    """
    client = AsyncClient(MATRIX_URL, "@admin-iutlh:localhost")
    client.access_token = ACCESS_TOKEN
    
    try:
        # On récupère les messages (sync pour récupérer l'état actuel)
        sync_resp = await client.sync(timeout=3000, full_state=True)
        
        # Récupération des messages du salon spécifique
        res = await client.room_messages(ROOM_ID, limit=limit)
        
        messages = []
        if hasattr(res, 'chunk'):
            for event in res.chunk:
                if isinstance(event, RoomMessageText):
                    messages.append({
                        "sender": event.sender.split(':')[0].replace('@', ''),
                        "body": event.body,
                        "age": format_age(event.server_timestamp)
                    })
        
        await client.close()
        
        # Si aucun message, on met un message de bienvenue
        if not messages:
            return [{"sender": "Système", "body": "Bienvenue sur le fil d'actualité. Postez votre premier message dans Matrix !", "age": "Maintenant"}]
            
        return messages
        
    except Exception as e:
        print(f"Erreur Réelle Matrix: {e}")
        await client.close()
        return [{"sender": "Erreur", "body": "Impossible de joindre le serveur Matrix.", "age": "Maintenant"}]
