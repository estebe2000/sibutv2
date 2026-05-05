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

    def generate_fiche_pdf(self, item_data: dict, requestor_name: str) -> bytes:
        """
        Génère un PDF basique pour une Activité ou une Ressource.
        La mise en page sera améliorée dans un second temps.
        """
        buffer = io.BytesIO()
        c = canvas.Canvas(buffer, pagesize=letter)

        c.setFont("Helvetica-Bold", 20)
        title = item_data.get("label", "Fiche Élément")
        code = item_data.get("code", "")
        c.drawString(50, 750, f"{code} - {title}")

        c.setFont("Helvetica", 12)
        y = 700

        c.drawString(50, y, "Description :")
        y -= 20
        c.setFont("Helvetica", 10)

        # Simple wrap for description (très basique pour l'instant)
        desc = item_data.get("description", "Aucune description")
        if not desc:
            desc = "Aucune description"
        c.drawString(50, y, desc[:100]) # On coupe à 100 char pour la maquette basique
        if len(desc) > 100:
            y -= 15
            c.drawString(50, y, desc[100:200] + ("..." if len(desc) > 200 else ""))

        y -= 40
        c.setFont("Helvetica-Bold", 12)
        c.drawString(50, y, "Détails Techniques :")
        y -= 20
        c.setFont("Helvetica", 10)

        for key, value in item_data.items():
            if key not in ["label", "code", "description"] and value is not None:
                c.drawString(50, y, f"{key}: {value}")
                y -= 15

        # Bas de page : Demandeur
        c.setFont("Helvetica-Oblique", 10)
        c.drawString(50, 50, f"Document généré par le Skills Hub IUT.")
        c.drawString(50, 35, f"Demandé par : {requestor_name}")

        c.showPage()
        c.save()

        buffer.seek(0)
        return buffer.getvalue()
