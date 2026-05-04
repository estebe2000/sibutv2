from abc import ABC, abstractmethod

class PdfGeneratorInterface(ABC):
    @abstractmethod
    def generate_internship_certificate(self, internship_data: dict, evaluation_data: dict) -> bytes:
        """
        Génère un certificat de fin de stage au format PDF (bytes).
        """
        pass
