from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Frame, PageTemplate, NextPageTemplate, Image, Flowable
from reportlab.lib.units import cm
from io import BytesIO
from ..models import Activity, Resource, LearningOutcome, User, ResponsibilityMatrix, ResponsibilityEntityType, ResponsibilityType, SystemConfig, EvaluationRubric, Internship, InternshipEvaluation, ActivityType
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
        ResponsibilityMatrix.entity_id == str(entity_id),
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

def get_styles(primary_color="#1971c2"):
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name='TitleStyle', fontSize=22, leading=26, spaceAfter=20, textColor=colors.HexColor(primary_color), fontWeight='Bold', alignment=1))
    styles.add(ParagraphStyle(name='Heading2Style', fontSize=14, leading=18, spaceBefore=15, spaceAfter=8, textColor=colors.HexColor(primary_color), fontWeight='Bold', borderPadding=5, borderLeftColor=colors.HexColor(primary_color), borderLeftWidth=3))
    styles.add(ParagraphStyle(name='NormalStyle', fontSize=10, leading=14, spaceAfter=6))
    styles.add(ParagraphStyle(name='CommentStyle', fontSize=9, leading=12, leftIndent=10, textColor=colors.grey, fontName='Helvetica-Oblique'))
    styles.add(ParagraphStyle(name='TableTextStyle', fontSize=9, leading=11))
    styles.add(ParagraphStyle(name='GroupHeaderStyle', fontSize=12, leading=14, spaceBefore=10, spaceAfter=5, textColor=colors.HexColor(primary_color), fontWeight='Bold'))
    return styles

def clean_markdown(text):
    if not text: return ""
    replacements = {'ﬁ': 'fi', 'ﬂ': 'fl', 'ﬀ': 'ff', 'ﬃ': 'ffi', 'ﬄ': 'ffl', '\u25a0': 'fi'}
    for old, new in replacements.items():
        text = text.replace(old, new)
    text = html.escape(text)
    text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'###\s*(.*?)(\n|$)', r'<br/><b>\1</b><br/>', text)
    text = text.replace("\n•", "<br/>•").replace("\n-", "<br/>-")
    text = text.replace("\n", "<br/>")
    return text.strip()

def generate_radar_chart(labels, student_scores, pro_scores, teacher_scores):
    """Génère un graphique radar PNG en mémoire."""
    num_vars = len(labels)
    if num_vars < 3: return None
    angles = np.linspace(0, 2 * np.pi, num_vars, endpoint=False).tolist()
    angles += angles[:1]
    student_scores += student_scores[:1]
    pro_scores += pro_scores[:1]
    teacher_scores += teacher_scores[:1]

    fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(polar=True))
    plt.xticks(angles[:-1], [l[:15]+'...' if len(l)>15 else l for l in labels], color='grey', size=8)
    ax.set_rlabel_position(0)
    plt.yticks([25, 50, 75, 100], ["25", "50", "75", "100"], color="grey", size=7)
    plt.ylim(0, 100)

    ax.plot(angles, student_scores, color='#228be6', linewidth=1, label='Élève')
    ax.fill(angles, student_scores, color='#228be6', alpha=0.1)
    ax.plot(angles, pro_scores, color='#fd7e14', linewidth=1, label='Pro')
    ax.fill(angles, pro_scores, color='#fd7e14', alpha=0.1)
    ax.plot(angles, teacher_scores, color='#40c057', linewidth=2, label='Prof')
    ax.fill(angles, teacher_scores, color='#40c057', alpha=0.3)

    plt.legend(loc='upper right', bbox_to_anchor=(0.1, 0.1), prop={'size': 8})
    
    img_buffer = BytesIO()
    plt.savefig(img_buffer, format='png', bbox_inches='tight', dpi=150)
    plt.close()
    img_buffer.seek(0)
    return img_buffer

def Divider(color=colors.black, thickness=1, width=16):
    class _Divider(Flowable):
        def __init__(self, color, thickness, width):
            Flowable.__init__(self)
            self.color = color
            self.thickness = thickness
            self.width = width
        def draw(self):
            self.canv.setStrokeColor(self.color)
            self.canv.setLineWidth(self.thickness)
            self.canv.line(0, 0, self.width*cm, 0)
    return _Divider(color, thickness, width)

# --- FICHES ACTIVITÉS (VERSION RICHE RESTAURÉE) ---
def generate_activity_pdf(activity: Activity, session: Session):
    buffer = BytesIO()
    primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2")
    logo_url = get_config_value(session, "APP_LOGO_URL", "")
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=1.5*cm, leftMargin=1.5*cm, topMargin=1.5*cm, bottomMargin=1.5*cm)
    
    frame_p = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id='normal')
    template_p = PageTemplate(id='portrait', frames=frame_p, pagesize=A4)
    l_width, l_height = landscape(A4)
    frame_l = Frame(1.5*cm, 1.5*cm, l_width - 3*cm, l_height - 3*cm, id='landscape_frame')
    template_l = PageTemplate(id='landscape', frames=frame_l, pagesize=landscape(A4))
    doc.addPageTemplates([template_p, template_l])
    
    story = []
    styles = get_styles(primary_color)

    # Header with Logo
    header_data = []
    logo_path = logo_url
    if logo_url and logo_url.startswith("http"):
        try:
            response = requests.get(logo_url, timeout=5, verify=False)
            if response.status_code == 200:
                temp_logo = f"/tmp/logo_{datetime.now().timestamp()}.png"
                with open(temp_logo, 'wb') as f: f.write(response.content)
                logo_path = temp_logo
        except: pass

    if logo_path and os.path.exists(logo_path):
        try:
            img = Image(logo_path)
            aspect = img.imageWidth / img.imageHeight
            img.drawHeight = 1.5*cm
            img.drawWidth = 1.5*cm * aspect
            header_data.append([img, Paragraph(f"Document généré le {datetime.now().strftime('%d/%m/%Y')}", styles['NormalStyle'])])
        except:
            header_data.append([Paragraph("Skills Hub", styles['TitleStyle']), Paragraph(f"Généré le {datetime.now().strftime('%d/%m/%Y')}", styles['NormalStyle'])])
    else:
        header_data.append([Paragraph("Skills Hub BUT TC", styles['TitleStyle']), Paragraph(f"Généré le {datetime.now().strftime('%d/%m/%Y')}", styles['NormalStyle'])])

    t_header = Table(header_data, colWidths=[12*cm, 6*cm])
    t_header.setStyle(TableStyle([('VALIGN', (0,0), (-1,-1), 'MIDDLE'), ('ALIGN', (1,0), (1,0), 'RIGHT')]))
    story.append(t_header); story.append(Spacer(1, 0.5*cm)); story.append(Divider(colors.grey, 0.5)); story.append(Spacer(1, 0.5*cm))

    # Activity Title & Gov
    story.append(Paragraph(f"{activity.code} : {activity.label}", styles['TitleStyle']))
    owner, intervenants = get_governance_info(session, str(activity.id), ResponsibilityEntityType.ACTIVITY)
    story.append(Paragraph(f"<b>Responsable :</b> {owner}", styles['NormalStyle']))
    if intervenants: story.append(Paragraph(f"<b>Intervenant(s) :</b> {', '.join(intervenants)}", styles['NormalStyle']))
    
    story.append(Spacer(1, 0.5*cm))
    data = [["Type:", activity.type], ["Semestre:", f"S{activity.semester}"], ["Parcours:", activity.pathway]]
    t = Table(data, colWidths=[3*cm, 12*cm])
    t.setStyle(TableStyle([('FONTNAME', (0,0), (0,-1), 'Helvetica-Bold'), ('FONTSIZE', (0,0), (-1,-1), 10)]))
    story.append(t); story.append(Spacer(1, 0.5*cm))

    if activity.description:
        story.append(Paragraph("Descriptif", styles['Heading2Style']))
        story.append(Paragraph(clean_markdown(activity.description), styles['NormalStyle']))

    story.append(Spacer(1, 1*cm))
    story.append(Paragraph("Sommaire interactif", styles['Heading2Style']))
    story.append(Paragraph('<a href="#evaluation" color="orange"><b><u>→ Accéder à la Grille d\'auto-évaluation (Mode Paysage - Fin de document)</u></b></a>', styles['NormalStyle']))

    if activity.learning_outcomes:
        story.append(Spacer(1, 0.5*cm))
        story.append(Paragraph("Apprentissages Critiques :", styles['NormalStyle']))
        for lo in sorted(activity.learning_outcomes, key=lambda x: x.code):
            story.append(Paragraph(f'• <a href="#{lo.code}" color="blue"><u>{lo.code} : {lo.label}</u></a>', styles['NormalStyle']))
    
    res_codes = [r.strip() for r in activity.resources.split(',')] if activity.resources else []
    if res_codes:
        story.append(Spacer(1, 0.3*cm))
        story.append(Paragraph("Ressources mobilisées :", styles['NormalStyle']))
        for r_code in res_codes:
            res_obj = session.exec(select(Resource).where(Resource.code == r_code)).first()
            story.append(Paragraph(f'• <a href="#{r_code}" color="teal"><u>{r_code} : {res_obj.label if res_obj else ""}</u></a>', styles['NormalStyle']))

    story.append(PageBreak())

    # Details AC
    if activity.learning_outcomes:
        story.append(Paragraph("Détails des Apprentissages Critiques", styles['Heading2Style']))
        for lo in sorted(activity.learning_outcomes, key=lambda x: x.code):
            story.append(Paragraph(f'<a name="{lo.code}"/><b>{lo.code} : {lo.label}</b>', styles['Heading2Style']))
            if lo.description: story.append(Paragraph(clean_markdown(lo.description), styles['NormalStyle']))
            story.append(Spacer(1, 0.5*cm))
        story.append(PageBreak())

    # Details Resources
    if res_codes:
        story.append(Paragraph("Détails des Ressources", styles['Heading2Style']))
        for r_code in res_codes:
            res = session.exec(select(Resource).where(Resource.code == r_code)).first()
            if res:
                story.append(Paragraph(f'<a name="{res.code}"/><b>Ressource {res.code} : {res.label}</b>', styles['Heading2Style']))
                if res.description: story.append(Paragraph(clean_markdown(res.description), styles['NormalStyle']))
                if res.content: story.append(Paragraph(clean_markdown(res.content), styles['CommentStyle']))
                story.append(Spacer(1, 0.5*cm))
        story.append(PageBreak())

    # Landscape Table
    story.append(NextPageTemplate('landscape'))
    story.append(PageBreak())
    story.append(Paragraph(f'<a name="evaluation"/>Grille d\'auto-évaluation : {activity.code}', styles['Heading2Style']))
    header = [Paragraph("<b>Apprentissage Critique (AC)</b>", styles['TableTextStyle']), "Concerné", "Pas du tout", "Très peu", "Peu", "Souvent", "Très souvent"]
    table_data = [header]
    if activity.learning_outcomes:
        for lo in sorted(activity.learning_outcomes, key=lambda x: x.code):
            table_data.append([Paragraph(f"<b>{lo.code}</b> : {lo.label}", styles['TableTextStyle']), "", "", "", "", "", ""])
    t_eval = Table(table_data, colWidths=[14.0*cm, 1.7*cm, 2.2*cm, 2.2*cm, 2.2*cm, 2.2*cm, 2.2*cm])
    t_eval.setStyle(TableStyle([('GRID', (0,0), (-1,-1), 0.5, colors.grey), ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#e7f5ff")), ('VALIGN', (0,0), (-1,-1), 'MIDDLE')]))
    story.append(t_eval)

    doc.build(story); buffer.seek(0)
    return buffer

# --- FICHES RESSOURCES (VERSION RICHE RESTAURÉE) ---
def generate_resource_pdf(resource: Resource, session: Session):
    buffer = BytesIO()
    primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2")
    styles = get_styles(primary_color)
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=1.5*cm, leftMargin=1.5*cm, topMargin=1.5*cm, bottomMargin=1.5*cm)
    story = []
    
    story.append(Paragraph(f"Ressource {resource.code} : {resource.label}", styles['TitleStyle']))
    owner, intervenants = get_governance_info(session, resource.code, ResponsibilityEntityType.RESOURCE)
    story.append(Paragraph(f"<b>Responsable :</b> {owner}", styles['NormalStyle']))
    if intervenants: story.append(Paragraph(f"<b>Intervenant(s) :</b> {', '.join(intervenants)}", styles['NormalStyle']))
    story.append(Spacer(1, 0.5*cm))
    
    if resource.description:
        story.append(Paragraph("Objectifs et Descriptif", styles['Heading2Style']))
        story.append(Paragraph(clean_markdown(resource.description), styles['NormalStyle']))
    if resource.content:
        story.append(Paragraph("Contenus pédagogiques", styles['Heading2Style']))
        story.append(Paragraph(clean_markdown(resource.content), styles['NormalStyle']))
    if resource.learning_outcomes:
        story.append(Paragraph("Apprentissages Critiques Liés", styles['Heading2Style']))
        for lo in sorted(resource.learning_outcomes, key=lambda x: x.code):
            story.append(Paragraph(f"• {lo.code} : {lo.label}", styles['NormalStyle']))

    doc.build(story); buffer.seek(0)
    return buffer

# --- BILAN DE STAGE COMPLET ---
def generate_internship_report(session: Session, student_uid: str):
    internship = session.exec(select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)).first()
    student = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
    if not internship or not student: return None
    rubric = session.exec(select(EvaluationRubric).join(Activity).where(Activity.type == ActivityType.STAGE)).first()
    if not rubric: return None
    evals = session.exec(select(InternshipEvaluation).where(InternshipEvaluation.internship_id == internship.id)).all()
    
    buffer = BytesIO(); primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2"); styles = get_styles(primary_color)
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=2*cm, leftMargin=2*cm); story = []
    story.append(Paragraph("BILAN ÉVALUATIF DE STAGE", styles['TitleStyle']))
    story.append(Divider(color=colors.HexColor(primary_color), thickness=2)); story.append(Spacer(1, 1*cm))
    
    info_data = [[Paragraph(f"<b>ÉTUDIANT</b> : {student.full_name}<br/><b>ENTREPRISE</b> : {internship.company_name or 'N/A'}", styles['TableTextStyle']), Paragraph(f"<b>MAÎTRE DE STAGE</b> : {internship.supervisor_name or 'N/A'}<br/><b>CONTACT</b> : {internship.supervisor_email or ''}", styles['TableTextStyle'])]]
    t_info = Table(info_data, colWidths=[8*cm, 8*cm])
    t_info.setStyle(TableStyle([('BOX', (0,0), (-1,-1), 1, colors.HexColor(primary_color)), ('VALIGN', (0,0), (-1,-1), 'TOP'), ('BOTTOMPADDING', (0,0), (-1,-1), 10)]))
    story.append(t_info); story.append(Spacer(1, 1*cm))
    
    labels = [c.label for c in rubric.criteria]
    s_scores = [next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "STUDENT"), 0) for c in rubric.criteria]
    p_scores = [next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "PRO"), 0) for c in rubric.criteria]
    t_scores = [next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "TEACHER"), 0) for c in rubric.criteria]
    
    radar_img = generate_radar_chart(labels, s_scores, p_scores, t_scores)
    if radar_img: story.append(Image(radar_img, width=14*cm, height=12*cm))
    
    story.append(PageBreak())
    t_scores_calc = [e.score for e in evals if e.evaluator_role == "TEACHER"]
    final_grade = (sum(t_scores_calc) / len(t_scores_calc) * 0.2) if t_scores_calc else 0
    story.append(Table([[Paragraph("Détail des Acquisitions", styles['Heading2Style']), Paragraph(f"NOTE FINALE : {final_grade:.2f} / 20", ParagraphStyle('gr', parent=styles['TitleStyle'], alignment=2, fontSize=16))]], colWidths=[10*cm, 6*cm]))
    
    table_data = [["Compétence", "Élève", "Pro", "Prof"]]
    for c in rubric.criteria:
        s_s = next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "STUDENT"), 0)
        p_s = next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "PRO"), 0)
        t_s = next((e.score for e in evals if e.criterion_id == c.id and e.evaluator_role == "TEACHER"), 0)
        table_data.append([Paragraph(c.label, styles['TableTextStyle']), f"{int(s_s)}%", f"{int(p_s)}%", f"{int(t_s)}%"])
    t_eval = Table(table_data, colWidths=[10*cm, 2*cm, 2*cm, 2*cm])
    t_eval.setStyle(TableStyle([('GRID', (0,0), (-1,-1), 0.5, colors.grey), ('BACKGROUND', (0,0), (-1,0), colors.HexColor(primary_color)), ('TEXTCOLOR', (0,0), (-1,0), colors.white), ('BACKGROUND', (1,1), (1,-1), colors.HexColor("#e7f5ff")), ('BACKGROUND', (2,1), (2,-1), colors.HexColor("#fff4e6")), ('BACKGROUND', (3,1), (3,-1), colors.HexColor("#ebfbee"))]))
    story.append(t_eval); story.append(Spacer(1, 1*cm))
    
    story.append(PageBreak()); story.append(Paragraph("Commentaires Détaillés", styles['Heading2Style']))
    for c in rubric.criteria:
        s_c = next((e.comment for e in evals if e.criterion_id == c.id and e.evaluator_role == "STUDENT" and e.comment), None)
        p_c = next((e.comment for e in evals if e.criterion_id == c.id and e.evaluator_role == "PRO" and e.comment), None)
        t_c = next((e.comment for e in evals if e.criterion_id == c.id and e.evaluator_role == "TEACHER" and e.comment), None)
        if s_c or p_c or t_c:
            story.append(Paragraph(f"<b>Critère :</b> {c.label}", styles['NormalStyle']))
            if s_c: story.append(Paragraph(f"Élève : {s_c}", styles['CommentStyle']))
            if p_c: story.append(Paragraph(f"Pro : {p_c}", styles['CommentStyle']))
            if t_c: story.append(Paragraph(f"Prof : {t_c}", styles['CommentStyle']))
            story.append(Spacer(1, 0.3*cm))

    # Team gov info
    story.append(Spacer(1, 1*cm)); story.append(Paragraph("Équipe Pédagogique", styles['Heading2Style']))
    tutor_obj = session.exec(select(User).where(User.ldap_uid == "tctc")).first()
    coord_obj = session.exec(select(User).where(User.ldap_uid == "tbtb")).first()
    story.append(Paragraph(f"Tuteur : {tutor_obj.full_name if tutor_obj else 'tctc'}", styles['NormalStyle']))
    story.append(Paragraph(f"Coordination : {coord_obj.full_name if coord_obj else 'tbtb'}", styles['NormalStyle']))

    doc.build(story); buffer.seek(0)
    return buffer

def generate_governance_report_pdf(session: Session, filter_type: str = None):
    from ..models import ResponsibilityMatrix, User, ResponsibilityEntityType, Resource, Activity
    
    # Configuration
    primary_color = get_config_value(session, "APP_PRIMARY_COLOR", "#1971c2")
    logo_url = get_config_value(session, "APP_LOGO_URL", "")
    styles = get_styles(primary_color)
    
    # 1. Fetch Data
    stmt = select(ResponsibilityMatrix)
    if filter_type:
        stmt = stmt.where(ResponsibilityMatrix.entity_type == filter_type)
    matrix = session.exec(stmt).all()
    
    # 2. Group by Entity
    grouped_data = {}
    for entry in matrix:
        e_type = str(entry.entity_type).split('.')[-1]
        key = (e_type, entry.entity_id)
        if key not in grouped_data: grouped_data[key] = []
        grouped_data[key].append(entry)
        
    # 3. Sort entities by type then ID
    sorted_keys = sorted(grouped_data.keys(), key=lambda x: (x[0], x[1]))
    
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=landscape(A4), rightMargin=1.5*cm, leftMargin=1.5*cm, topMargin=1.5*cm, bottomMargin=1.5*cm)
    story = []
    
    # Header with Logo (consistent with other fiches)
    header_data = []
    logo_path = logo_url
    if logo_url and logo_url.startswith("http"):
        try:
            response = requests.get(logo_url, timeout=5, verify=False)
            if response.status_code == 200:
                temp_logo = f"/tmp/logo_gov_{datetime.now().timestamp()}.png"
                with open(temp_logo, 'wb') as f: f.write(response.content)
                logo_path = temp_logo
        except: pass

    if logo_path and os.path.exists(logo_path):
        try:
            img = Image(logo_path)
            aspect = img.imageWidth / img.imageHeight
            img.drawHeight = 1.5*cm
            img.drawWidth = 1.5*cm * aspect
            header_data.append([img, Paragraph(f"Rapport de Gouvernance Pédagogique<br/>Généré le {datetime.now().strftime('%d/%m/%Y à %H:%M')}", styles['NormalStyle'])])
        except:
            header_data.append([Paragraph("Skills Hub", styles['TitleStyle']), Paragraph(f"Gouvernance - Généré le {datetime.now().strftime('%d/%m/%Y')}", styles['NormalStyle'])])
    else:
        header_data.append([Paragraph("Skills Hub BUT TC", styles['TitleStyle']), Paragraph(f"Gouvernance - Généré le {datetime.now().strftime('%d/%m/%Y')}", styles['NormalStyle'])])

    t_header = Table(header_data, colWidths=[18*cm, 8.7*cm])
    t_header.setStyle(TableStyle([('VALIGN', (0,0), (-1,-1), 'MIDDLE'), ('ALIGN', (1,0), (1,0), 'RIGHT')]))
    story.append(t_header)
    story.append(Spacer(1, 0.5*cm))
    story.append(Divider(colors.HexColor(primary_color), 2, width=26.7))
    story.append(Spacer(1, 1*cm))
    
    title = "RAPPORT DE GOUVERNANCE PÉDAGOGIQUE"
    if filter_type == "RESOURCE": title += " : RESSOURCES"
    elif filter_type == "ACTIVITY": title += " : SAÉ & ACTIVITÉS"
    story.append(Paragraph(title, styles['TitleStyle']))
    story.append(Spacer(1, 0.5*cm))
    
    type_map = {"RESOURCE": "Ressource", "ACTIVITY": "SAÉ / Activité", "STUDENT": "Tutorat"}
    role_map = {"OWNER": "Responsable", "INTERVENANT": "Intervenant", "TUTOR": "Tuteur"}

    for e_type_str, e_id in sorted_keys:
        # Get entity Label
        label = e_id
        if e_type_str == "RESOURCE":
            res = session.exec(select(Resource).where(Resource.code == e_id)).first()
            if res: label = f"Ressource {res.code} : {res.label}"
        elif e_type_str == "ACTIVITY":
            act = session.get(Activity, int(e_id)) if e_id.isdigit() else None
            if act: label = f"{act.type} {act.code} : {act.label}"
            
        story.append(Paragraph(label, styles['GroupHeaderStyle']))
        story.append(Divider(colors.grey, 0.5, width=26.7))
        story.append(Spacer(1, 0.2*cm))
        
        # Sort responsibilities: OWNER first
        resps = sorted(grouped_data[(e_type_str, e_id)], key=lambda x: 0 if x.role_type == ResponsibilityType.OWNER else 1)
        
        table_data = [["Rôle", "Intervenant", "Email"]]
        for entry in resps:
            user = session.exec(select(User).where(User.ldap_uid == entry.user_id)).first()
            r_type_str = str(entry.role_type).split('.')[-1]
            table_data.append([
                role_map.get(r_type_str, r_type_str),
                user.full_name if user else entry.user_id,
                user.email if user else "N/A"
            ])
            
        t = Table(table_data, colWidths=[5*cm, 10*cm, 11.7*cm])
        t.setStyle(TableStyle([
            ('GRID', (0,0), (-1,-1), 0.2, colors.grey),
            ('BACKGROUND', (0,0), (-1,0), colors.HexColor(primary_color + "22")), # Light version of primary
            ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
            # Highlight OWNER row
            ('BACKGROUND', (0,1), (-1,1), colors.HexColor("#fff9db")), # Light yellow for owner
            ('FONTNAME', (0,1), (-1,1), 'Helvetica-Bold'),
        ]))
        story.append(t)
        story.append(Spacer(1, 0.8*cm))
        
    doc.build(story)
    buffer.seek(0)
    return buffer