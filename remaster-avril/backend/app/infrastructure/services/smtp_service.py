import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from ...application.interfaces.smtp_interface import SmtpServiceInterface

class SmtpService(SmtpServiceInterface):
    def __init__(self, server: str, port: int, user: str, password: str, from_email: str):
        self.server = server
        self.port = port
        self.user = user
        self.password = password
        self.from_email = from_email

    def send_email(self, to: str, subject: str, body: str) -> bool:
        try:
            msg = MIMEMultipart()
            msg['From'] = self.from_email
            msg['To'] = to
            msg['Subject'] = subject

            msg.attach(MIMEText(body, 'plain'))

            # Pour le mode dégradé local si serveur non configuré, on simule l'envoi
            if not self.server or self.server == "smtp.educ-ai.fr":
                print(f"[SMTP MOCK] Email intercepté pour {to} : {subject}\n{body}")
                return True

            server = smtplib.SMTP(self.server, self.port)
            server.starttls()
            if self.user and self.password:
                server.login(self.user, self.password)
            text = msg.as_string()
            server.sendmail(self.from_email, to, text)
            server.quit()
            return True
        except Exception as e:
            print(f"Erreur SMTP: {e}")
            return False
