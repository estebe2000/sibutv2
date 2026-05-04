from nio import AsyncClient
from ...application.interfaces.matrix_interface import MatrixServiceInterface

class MatrixService(MatrixServiceInterface):
    def __init__(self, matrix_url: str, admin_token: str, server_name: str):
        self.matrix_url = matrix_url
        self.admin_token = admin_token
        self.server_name = server_name

    async def create_internship_room(self, student_uid: str, teacher_uid: str, tutor_name: str) -> str:
        """
        Crée le salon Matrix. Utilise nio AsyncClient pour faire un create_room().
        """
        client = AsyncClient(self.matrix_url, f"@admin:{self.server_name}")
        client.access_token = self.admin_token

        try:
            # Création de la room
            room_name = f"Suivi Stage - {student_uid} / {tutor_name}"
            res = await client.room_create(
                name=room_name,
                preset="private_chat",
                invite=[f"@{student_uid}:{self.server_name}", f"@{teacher_uid}:{self.server_name}"]
            )

            await client.close()

            if hasattr(res, 'room_id'):
                return res.room_id
            raise ValueError(f"Erreur création Matrix: {res}")

        except Exception as e:
            await client.close()
            raise Exception(f"Erreur MatrixService: {str(e)}")

    async def invite_magic_link_user_to_room(self, room_id: str, magic_link_token: str) -> bool:
        """
        Pour contourner le fait que le tuteur n'a pas de compte LDAP :
        On utilise une feature Guest ou un compte "Tuteur générique" provisionné à la volée.
        Dans une V1, on simule l'envoi d'invitation.
        """
        print(f"[MATRIX MOCK] Invitation envoyée sur la room {room_id} pour le tuteur (token: {magic_link_token})")
        return True
