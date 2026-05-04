from abc import ABC, abstractmethod

class SmtpServiceInterface(ABC):
    @abstractmethod
    def send_email(self, to: str, subject: str, body: str) -> bool:
        """
        Envoie un email via SMTP. Retourne True si succès.
        """
        pass
