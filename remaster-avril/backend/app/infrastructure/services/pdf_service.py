import io
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from ...application.interfaces.pdf_interface import PdfGeneratorInterface

class ReportLabPdfGenerator(PdfGeneratorInterface):
    def generate_internship_certificate(self, internship_data: dict, evaluation_data: dict) -> bytes:
        """
        Génère un PDF basique via ReportLab pour le certificat de fin de stage.
        """
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=letter)

        c.setFont("Helvetica-Bold", 24)
        c.drawString(100, 750, "Certificat d'Évaluation de Stage")

        c.setFont("Helvetica", 14)
        c.drawString(100, 700, f"Étudiant(e) : {internship_data.get('student_name', 'Inconnu')}")
        c.drawString(100, 675, f"Entreprise : {internship_data.get('company_name', 'Inconnue')}")
        c.drawString(100, 650, f"Tuteur : {internship_data.get('tutor_name', 'Inconnu')}")

        c.setFont("Helvetica-Bold", 16)
        c.drawString(100, 600, "Résultats d'évaluation :")

        c.setFont("Helvetica", 12)
        y = 575
        ac_scores = evaluation_data.get("ac_scores", {})
        for ac_code, score in ac_scores.items():
            c.drawString(120, y, f"- {ac_code} : {score}% d'acquisition")
            y -= 20

        c.drawString(100, y - 20, f"Commentaire de l'enseignant : {evaluation_data.get('teacher_comment', '')}")
        c.drawString(100, y - 40, f"Bonus/Malus appliqué : {evaluation_data.get('bonus_malus', 0)}%")

        c.setFont("Helvetica-Oblique", 10)
        c.drawString(100, 100, "Document généré par Skills Hub IUT.")

        c.showPage()
        c.save()

        buffer.seek(0)
        return buffer.getvalue()
