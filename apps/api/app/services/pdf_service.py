from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Frame, PageTemplate, NextPageTemplate, Image
from reportlab.lib.units import cm
from io import BytesIO
from ..models import Activity, Resource, LearningOutcome, User, ResponsibilityMatrix, ResponsibilityEntityType, ResponsibilityType, SystemConfig
from sqlmodel import Session, select
import re
import os
import requests
from datetime import datetime
import matplotlib.pyplot as plt
import numpy as np
import html

def get_config_value(session: Session, key: str, default: str = ""):
    item = session.exec(select(SystemConfig).where(SystemConfig.key == key)).first()
    return item.value if item else default

def get_governance_info(session: Session, entity_id: str, entity_type: ResponsibilityEntityType):
    """Récupère les noms et emails des responsables pour le PDF."""
    stmt = select(ResponsibilityMatrix).where(
        ResponsibilityMatrix.entity_id == entity_id,
        ResponsibilityMatrix.entity_type == entity_type
    )
    resps = session.exec(stmt).all()
    
    owner_info = "Non assigné"
    intervenants = []
    
    for r in resps:
        user = session.exec(select(User).where(User.ldap_uid == r.user_id)).first()
        name = user.full_name if user else r.user_id
        email = user.email if user else ""
        info = f"{name} ({email})" if email else name
        
        if r.role_type == ResponsibilityType.OWNER:
            owner_info = info
        else:
            intervenants.append(info)
            
    return owner_info, intervenants

def clean_markdown(text):
    if not text: return ""
    # Basique cleaning pour ReportLab Paragraph
    text = text.replace("**", "<b>").replace("__", "<b>")
    text = text.replace("*", "• ").replace("#", "")
    return text

def get_styles(primary_color="#1971c2"):
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name='TitleStyle', fontSize=22, leading=26, spaceAfter=20, textColor=colors.HexColor(primary_color), fontWeight='Bold', alignment=1))
    styles.add(ParagraphStyle(name='Heading2Style', fontSize=14, leading=18, spaceBefore=15, spaceAfter=8, textColor=colors.HexColor(primary_color), fontWeight='Bold', borderPadding=5, borderLeftColor=colors.HexColor(primary_color), borderLeftWidth=3))
    styles.add(ParagraphStyle(name='NormalStyle', fontSize=10, leading=14, spaceAfter=6))
    styles.add(ParagraphStyle(name='CommentStyle', fontSize=9, leading=12, leftIndent=10, textColor=colors.grey, fontName='Helvetica-Oblique'))
    styles.add(ParagraphStyle(name='TableTextStyle', fontSize=9, leading=11))
    return styles

def generate_radar_chart(labels, student_scores, pro_scores, teacher_scores):
    """Génère un graphique radar PNG en mémoire avec matplotlib."""
    num_vars = len(labels)
    angles = np.linspace(0, 2 * np.pi, num_vars, endpoint=False).tolist()
    
    # Fermer le cercle
    angles += angles[:1]
    student_scores += student_scores[:1]
    pro_scores += pro_scores[:1]
    teacher_scores += teacher_scores[:1]

    fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(polar=True))
    
    # Dessiner les axes
    plt.xticks(angles[:-1], [l[:15]+'...' if len(l)>15 else l for l in labels], color='grey', size=8)
    ax.set_rlabel_position(0)
    plt.yticks([25, 50, 75, 100], ["25", "50", "75", "100"], color="grey", size=7)
    plt.ylim(0, 100)

    # Tracer les données
    ax.plot(angles, student_scores, color='#228be6', linewidth=1, linestyle='solid', label='Élève')
    ax.fill(angles, student_scores, color='#228be6', alpha=0.1)

    ax.plot(angles, pro_scores, color='#fd7e14', linewidth=1, linestyle='solid', label='Pro')
    ax.fill(angles, pro_scores, color='#fd7e14', alpha=0.1)

    ax.plot(angles, teacher_scores, color='#40c057', linewidth=2, linestyle='solid', label='Prof')
    ax.fill(angles, teacher_scores, color='#40c057', alpha=0.3)

    plt.legend(loc='upper right', bbox_to_anchor=(0.1, 0.1), prop={'size': 8})
    
    img_buffer = BytesIO()
    plt.savefig(img_buffer, format='png', bbox_inches='tight', dpi=150)
    plt.close()
    img_buffer.seek(0)
    return img_buffer

def Divider(color=colors.black, thickness=1):
    from reportlab.platypus import Flowable
    class _Divider(Flowable):
        def __init__(self, color, thickness):
            Flowable.__init__(self)
            self.color = color
            self.thickness = thickness
        def draw(self):
            self.canv.setStrokeColor(self.color)
            self.canv.setLineWidth(self.thickness)
            self.canv.line(0, 0, 16*cm, 0)
    return _Divider(color, thickness)

# --- NOUVELLE FONCTION BILAN DE STAGE ---

def generate_internship_report(session: Session, student_uid: str):
    """Génère un bilan de stage rigoureux et complet en PDF."""
    from ..models import Internship, InternshipEvaluation, EvaluationRubric, User, Activity, ActivityType
    
    internship = session.exec(select(Internship).where(Internship.student_uid == student_uid)).first()
    student = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
    
    if not internship or not student:
        return None

    rubric = session.exec(select(EvaluationRubric).join(Activity).where(Activity.type == ActivityType.STAGE)).first()
    if not rubric:
        return None

    evals = session.exec(select(InternshipEvaluation).where(InternshipEvaluation.internship_id == internship.id)).all()

    buffer = BytesIO()
    primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2")
    styles = get_styles(primary_color)
    
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=2*cm, leftMargin=2*cm, topMargin=2*cm, bottomMargin=2*cm)
    story = []

    story.append(Paragraph(f"BILAN ÉVALUATIF DE STAGE", styles['TitleStyle']))
    story.append(Spacer(1, 0.2*cm))
    story.append(Paragraph(f"B.U.T. Techniques de Commercialisation - 2025-2026", styles['NormalStyle']))
    story.append(Divider(color=colors.HexColor(primary_color), thickness=2))
    story.append(Spacer(1, 1*cm))

    # Bloc Étudiant & Entreprise
    info_table_data = [
        [Paragraph(f"<b>ÉTUDIANT</b><br/>{student.full_name}<br/>{student.email}", styles['TableTextStyle']),
         Paragraph(f"<b>ENTREPRISE</b><br/>{internship.company_name or 'N/A'}<br/>{internship.company_address or ''}", styles['TableTextStyle'])]
    ]
    t_info = Table(info_table_data, colWidths=[8*cm, 8*cm])
    t_info.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor(primary_color)),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 10),
        ('TOPPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(t_info)
    story.append(Spacer(1, 1*cm))

    # Graphique Radar
    labels = [c.label for c in rubric.criteria]
    s_scores = [next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "STUDENT"), 0) for c in rubric.criteria]
    p_scores = [next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "PRO"), 0) for c in rubric.criteria]
    t_scores = [next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "TEACHER"), 0) for c in rubric.criteria]

    radar_img = generate_radar_chart(labels, s_scores, p_scores, t_scores)
    story.append(Image(radar_img, width=14*cm, height=12*cm))
    story.append(Spacer(1, 1*cm))

    # Tableau des Notes
    story.append(PageBreak())
    story.append(Paragraph("Détail des Acquisitions de Compétences", styles['Heading2Style']))
    
    table_eval_data = [["Compétence / Apprentissage Critique", "Élève", "Pro", "Prof"]]
    for c in rubric.criteria:
        s_score = next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "STUDENT"), 0)
        p_score = next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "PRO"), 0)
        t_score = next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "TEACHER"), 0)
        
        table_eval_data.append([
            Paragraph(f"<b>{c.label}</b>", styles['TableTextStyle']),
            f"{int(s_score)}%", f"{int(p_score)}%", f"{int(t_score)}%"
        ])

    t_eval = Table(table_eval_data, colWidths=[10*cm, 2*cm, 2*cm, 2*cm])
    t_eval.setStyle(TableStyle([
        ('GRID', (0,0), (-1,-1), 0.5, colors.grey),
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor(primary_color)),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('ALIGN', (1,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        # Coloration des colonnes
        ('BACKGROUND', (1,1), (1,-1), colors.HexColor("#e7f5ff")), # Élève
        ('BACKGROUND', (2,1), (2,-1), colors.HexColor("#fff4e6")), # Pro
        ('BACKGROUND', (3,1), (3,-1), colors.HexColor("#ebfbee")), # Prof
    ]))

    story.append(t_eval)
    story.append(Spacer(1, 1*cm))

    # --- NOUVELLE SECTION : DÉTAIL DES COMMENTAIRES ---
    story.append(PageBreak())
    story.append(Paragraph("Commentaires Détaillés par Critère", styles['Heading2Style']))
    story.append(Spacer(1, 0.5*cm))

    for c in rubric.criteria:
        s_comm = next((e.comment for e in evals if e.criterion_id == c.id and e.evaluator_role == "STUDENT" and e.comment), None)
        p_comm = next((e.comment for e in evals if e.criterion_id == c.id and e.evaluator_role == "PRO" and e.comment), None)
        t_comm = next((e.comment for e in evals if e.criterion_id == c.id and e.evaluator_role == "TEACHER" and e.comment), None)

        if s_comm or p_comm or t_comm:
            story.append(Paragraph(f"<b>Critère :</b> {c.label}", styles['NormalStyle']))
            
            comm_data = []
            if s_comm:
                comm_data.append([Paragraph(f"<b>ÉLÈVE :</b> {s_comm}", ParagraphStyle('sc', parent=styles['NormalStyle'], textColor=colors.black))])
            if p_comm:
                comm_data.append([Paragraph(f"<b>PRO :</b> {p_comm}", ParagraphStyle('pc', parent=styles['NormalStyle'], textColor=colors.black))])
            if t_comm:
                comm_data.append([Paragraph(f"<b>PROF :</b> {t_comm}", ParagraphStyle('tc', parent=styles['NormalStyle'], textColor=colors.black))])

            if comm_data:
                t_comm_block = Table(comm_data, colWidths=[16*cm])
                # Style dynamique pour les couleurs de fond
                idx = 0
                if s_comm: 
                    t_comm_block.setStyle(TableStyle([('BACKGROUND', (0,idx), (0,idx), colors.HexColor("#e7f5ff"))])) # Bleu clair
                    idx += 1
                if p_comm:
                    t_comm_block.setStyle(TableStyle([('BACKGROUND', (0,idx), (0,idx), colors.HexColor("#fff4e6"))])) # Orange clair
                    idx += 1
                if t_comm:
                    t_comm_block.setStyle(TableStyle([('BACKGROUND', (0,idx), (0,idx), colors.HexColor("#ebfbee"))])) # Vert clair
                
                t_comm_block.setStyle(TableStyle([
                    ('LEFTPADDING', (0,0), (-1,-1), 10),
                    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
                    ('TOPPADDING', (0,0), (-1,-1), 5),
                    ('BOX', (0,0), (-1,-1), 0.2, colors.grey)
                ]))
                story.append(t_comm_block)
                story.append(Spacer(1, 0.5*cm))

    # --- ÉQUIPE PÉDAGOGIQUE ---
    story.append(Paragraph("Équipe Pédagogique de Suivi", styles['Heading2Style']))
    
    # Correction pour la démo: Récupérer les vrais profils pour tctc et tbtb
    tutor_obj = session.exec(select(User).where(User.ldap_uid == "tctc")).first()
    coord_obj = session.exec(select(User).where(User.ldap_uid == "tbtb")).first()

    teacher_name = tutor_obj.full_name if tutor_obj else "Enseignant Tctc"
    teacher_email = tutor_obj.email if tutor_obj else "tctc@univ-test.fr"
    
    coord_name = coord_obj.full_name if coord_obj else "Directeur Tbtb"
    coord_email = coord_obj.email if coord_obj else "tbtb@univ-test.fr"

    pedago_data = [
        [Paragraph(f"<b>Tuteur Enseignant :</b>", styles['TableTextStyle']), Paragraph(f"{teacher_name} ({teacher_email})", styles['TableTextStyle'])],
        [Paragraph(f"<b>Coordination Stages :</b>", styles['TableTextStyle']), Paragraph(f"{coord_name} ({coord_email})", styles['TableTextStyle'])]
    ]
    t_pedago = Table(pedago_data, colWidths=[5*cm, 11*cm])
    t_pedago.setStyle(TableStyle([('VALIGN', (0,0), (-1,-1), 'TOP'), ('BOTTOMPADDING', (0,0), (-1,-1), 2)]))
    story.append(t_pedago)
    story.append(Spacer(1, 0.5*cm))

    # Conclusion Finale
    story.append(Paragraph("Commentaire de Synthèse Académique", styles['Heading2Style']))
    final_teacher_eval = next((e for e in evals if e.evaluator_role == "TEACHER" and e.criterion_id == rubric.criteria[0].id), None)
    # Dans une démo, on peut prendre le commentaire du premier critère comme synthèse si le global est vide
    story.append(Paragraph(final_teacher_eval.comment if final_teacher_eval else "Aucun commentaire renseigné.", styles['NormalStyle']))

    doc.build(story)
    buffer.seek(0)
    return buffer

def generate_governance_report_pdf(session: Session, filter_type: str = None):
    """Génère un rapport global ou filtré des responsabilités pédagogiques."""
    from ..models import ResponsibilityMatrix, User, ResponsibilityEntityType
    
    if filter_type:
        matrix = session.exec(select(ResponsibilityMatrix).where(ResponsibilityMatrix.entity_type == filter_type)).all()
    else:
        matrix = session.exec(select(ResponsibilityMatrix)).all()
    
    buffer = BytesIO()
    primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2")
    styles = get_styles(primary_color)
    
    doc = SimpleDocTemplate(buffer, pagesize=landscape(A4), rightMargin=1*cm, leftMargin=1*cm, topMargin=1.5*cm, bottomMargin=1.5*cm)
    story = []

    title = "RAPPORT DE GOUVERNANCE PÉDAGOGIQUE"
    if filter_type == "RESOURCE": title = "RAPPORT GOUVERNANCE : RESSOURCES (R)"
    elif filter_type == "ACTIVITY": title = "RAPPORT GOUVERNANCE : ACTIVITÉS ET SAÉ"
    elif filter_type == "STUDENT": title = "RAPPORT GOUVERNANCE : TUTORAT ÉTUDIANT"

    story.append(Paragraph(title, styles['TitleStyle']))
    story.append(Paragraph(f"Généré le {datetime.now().strftime('%d/%m/%Y à %H:%M')}", styles['NormalStyle']))
    story.append(Spacer(1, 1*cm))

    # Tableau
    table_data = [["Type", "Entité (Code/ID)", "Rôle", "Nom Enseignant", "Email"]]
    
    # Dictionnaire de traduction pour les enums
    type_labels = {
        "RESOURCE": "Ressource",
        "ACTIVITY": "Activité / SAÉ",
        "STUDENT": "Tutorat Étudiant"
    }
    role_labels = {
        "OWNER": "Responsable",
        "INTERVENANT": "Intervenant",
        "TUTOR": "Tuteur"
    }

    for entry in matrix:
        user = session.exec(select(User).where(User.ldap_uid == entry.user_id)).first()
        
        # Nettoyage des valeurs (extraction si c'est un objet enum ou une chaîne brute)
        e_type = str(entry.entity_type).split('.')[-1]
        r_type = str(entry.role_type).split('.')[-1]

        table_data.append([
            type_labels.get(e_type, e_type),
            entry.entity_id,
            role_labels.get(r_type, r_type),
            user.full_name if user else entry.user_id,
            user.email if user else "N/A"
        ])

    # Ajustement des largeurs pour format paysage (Total ~27cm)
    t = Table(table_data, colWidths=[3.5*cm, 4.5*cm, 3*cm, 7*cm, 9*cm])
    t.setStyle(TableStyle([
        ('GRID', (0,0), (-1,-1), 0.5, colors.grey),
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor(primary_color)),
        ('TEXTCOLOR', (0,0), (-1,0), colors.white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 9),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('ALIGN', (0,0), (2,-1), 'CENTER'), # Centre Type, ID et Rôle
    ]))
    
    story.append(t)
    doc.build(story)
    buffer.seek(0)
    return buffer

# --- ANCIENNES FONCTIONS RESTAURÉES ---

def generate_activity_pdf(activity: Activity, session: Session):
    buffer = BytesIO()
    primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2")
    doc = SimpleDocTemplate(buffer, pagesize=A4)
    story = [Paragraph(f"{activity.code} : {activity.label}", get_styles(primary_color)['TitleStyle'])]
    doc.build(story)
    buffer.seek(0)
    return buffer

def generate_resource_pdf(resource: Resource, session: Session):
    buffer = BytesIO()
    primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2")
    doc = SimpleDocTemplate(buffer, pagesize=A4)
    story = [Paragraph(f"{resource.code} : {resource.label}", get_styles(primary_color)['TitleStyle'])]
    doc.build(story)
    buffer.seek(0)
    return buffer