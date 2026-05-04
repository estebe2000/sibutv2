from abc import ABC, abstractmethod

class PdfGeneratorInterface(ABC):
    @abstractmethod
    def generate_internship_certificate(self, internship_data: dict, evaluation_data: dict) -> bytes:
        """
        Génère un certificat de fin de stage au format PDF (bytes).
        """
        pass

    @abstractmethod
    def generate_fiche_pdf(self, item_data: dict, requestor_name: str) -> bytes:
        """
        Génère une fiche PDF pour une activité ou une ressource.
        """
        pass
