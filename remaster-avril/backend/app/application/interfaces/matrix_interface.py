from abc import ABC, abstractmethod

class MatrixServiceInterface(ABC):
    @abstractmethod
    async def create_internship_room(self, student_uid: str, teacher_uid: str, tutor_name: str) -> str:
        """
        Crée un canal de discussion Matrix/Element pour le stage et invite les membres.
        Retourne le Room ID.
        """
        pass

    @abstractmethod
    async def invite_magic_link_user_to_room(self, room_id: str, magic_link_token: str) -> bool:
        """
        Génère une invitation Matrix pour un utilisateur externe via son Magic Link.
        """
        pass
