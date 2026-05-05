from typing import Dict, Any, List
import json
import uuid
from sqlmodel import Session, select
from ...models.internship import InternshipApplication, InternshipApplicationStatus, Internship
from ...models.evaluations import MagicLink

class SubmitInternshipApplicationUseCase:
    def __init__(self, db: Session):
        self.db = db

    def execute(self, student_uid: str, proposed_acs: List[str], mission_description: str) -> InternshipApplication:
        """
        L'étudiant soumet sa proposition de stage (formulaire préparatoire).
        """
        app = InternshipApplication(
            student_uid=student_uid,
            proposed_acs_json=json.dumps(proposed_acs),
            mission_description=mission_description,
            status=InternshipApplicationStatus.SUBMITTED
        )
        self.db.add(app)
        self.db.commit()
        self.db.refresh(app)
        return app

class ReviewInternshipApplicationUseCase:
    def __init__(self, db: Session):
        self.db = db

    def execute(self, application_id: int, director_uid: str, is_approved: bool, comment: str) -> InternshipApplication:
        """
        Le directeur d'étude valide ou refuse la proposition de stage.
        """
        app = self.db.exec(select(InternshipApplication).where(InternshipApplication.id == application_id)).first()
        if not app:
            raise ValueError("Candidature introuvable")

        app.status = InternshipApplicationStatus.APPROVED if is_approved else InternshipApplicationStatus.REJECTED
        app.director_comment = comment

        # Si approuvé, on crée la coquille du stage officiel
        if is_approved:
            internship = Internship(
                student_uid=app.student_uid,
                application_id=app.id
            )
            self.db.add(internship)

        self.db.commit()
        self.db.refresh(app)
        return app

class FinalizeInternshipDetailsUseCase:
    def __init__(self, db: Session):
        self.db = db

    def execute(self, internship_id: int, tutor_name: str, tutor_email: str, tutor_phone: str) -> Internship:
        """
        L'étudiant renseigne les détails administratifs de son stage validé.
        """
        internship = self.db.exec(select(Internship).where(Internship.id == internship_id)).first()
        if not internship:
            raise ValueError("Stage introuvable")

        internship.tutor_name = tutor_name
        internship.tutor_email = tutor_email
        internship.tutor_phone = tutor_phone

        self.db.commit()
        self.db.refresh(internship)
        return internship

class GenerateTutorMagicLinkUseCase:
    def __init__(self, db: Session, smtp_service: Any):
        self.db = db
        self.smtp = smtp_service

    def execute(self, internship_id: int, base_url: str) -> MagicLink:
        """
        Génère un Magic Link pour le tuteur et l'envoie par email.
        """
        internship = self.db.exec(select(Internship).where(Internship.id == internship_id)).first()
        if not internship or not internship.tutor_email:
            raise ValueError("Stage ou email du tuteur introuvable")

        token = str(uuid.uuid4())
        link = MagicLink(
            tutor_email=internship.tutor_email,
            internship_id=internship_id,
            token=token
        )
        self.db.add(link)
        self.db.commit()
        self.db.refresh(link)

        # Envoi de l'email via SMTP
        full_url = f"{base_url}/tutor-access?token={token}"
        self.smtp.send_email(
            to=internship.tutor_email,
            subject="Accès au suivi de stage IUT",
            body=f"Bonjour {internship.tutor_name},\n\nVous pouvez accéder à l'espace d'évaluation de votre stagiaire via ce lien unique :\n{full_url}\n\nL'équipe IUT."
        )

        return link
