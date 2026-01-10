from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Frame, PageTemplate, NextPageTemplate
from reportlab.lib.units import cm
from io import BytesIO
from .models import Activity, Resource, LearningOutcome
from sqlmodel import Session, select
import re
import html

def get_styles():
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name='TitleStyle', fontSize=18, leading=22, spaceAfter=12, textColor=colors.HexColor("#1971c2"), fontWeight='Bold'))
    styles.add(ParagraphStyle(name='Heading2Style', fontSize=14, leading=18, spaceBefore=12, spaceAfter=6, textColor=colors.HexColor("#228be6"), fontWeight='Bold'))
    styles.add(ParagraphStyle(name='NormalStyle', fontSize=10, leading=14, spaceAfter=6))
    styles.add(ParagraphStyle(name='TableTextStyle', fontSize=9, leading=11))
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

def generate_activity_pdf(activity: Activity, session: Session):
    buffer = BytesIO()
    
    # 1. Define Document
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=1.5*cm, leftMargin=1.5*cm, topMargin=1.5*cm, bottomMargin=1.5*cm)
    
    # 2. Define Page Templates (Portrait and Landscape)
    # Portrait Frame
    frame_p = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id='normal')
    template_p = PageTemplate(id='portrait', frames=frame_p, pagesize=A4)
    
    # Landscape Frame
    l_width, l_height = landscape(A4)
    frame_l = Frame(1.5*cm, 1.5*cm, l_width - 3*cm, l_height - 3*cm, id='landscape_frame')
    template_l = PageTemplate(id='landscape', frames=frame_l, pagesize=landscape(A4))
    
    doc.addPageTemplates([template_p, template_l])
    
    story = []
    styles = get_styles()

    # --- PAGE 1: ACTIVITY OVERVIEW ---
    story.append(Paragraph(f"{activity.code} : {activity.label}", styles['TitleStyle']))
    story.append(Spacer(1, 0.5*cm))
    
    data = [["Type:", activity.type], ["Semestre:", f"S{activity.semester}"], ["Parcours:", activity.pathway]]
    t = Table(data, colWidths=[3*cm, 12*cm])
    t.setStyle(TableStyle([('FONTNAME', (0,0), (0,-1), 'Helvetica-Bold'), ('FONTSIZE', (0,0), (-1,-1), 10), ('ALIGN', (0,0), (-1,-1), 'LEFT')]))
    story.append(t)
    story.append(Spacer(1, 0.5*cm))

    if activity.description:
        story.append(Paragraph("Descriptif", styles['Heading2Style']))
        story.append(Paragraph(clean_markdown(activity.description), styles['NormalStyle']))

    story.append(Spacer(1, 1*cm))
    story.append(Paragraph("Sommaire interactif", styles['Heading2Style']))
    story.append(Paragraph('<a href="#evaluation" color="orange"><b><u>→ Accéder à la Grille d\'auto-évaluation (Mode Paysage - Fin de document)</u></b></a>', styles['NormalStyle']))
    story.append(Spacer(1, 0.5*cm))

    if activity.learning_outcomes:
        story.append(Paragraph("Apprentissages Critiques :", styles['NormalStyle']))
        for lo in activity.learning_outcomes:
            story.append(Paragraph(f'• <a href="#{lo.code}" color="blue"><u>{lo.code} : {lo.label}</u></a>', styles['NormalStyle']))
    
    res_codes = [r.strip() for r in activity.resources.split(',')] if activity.resources else []
    if res_codes:
        story.append(Spacer(1, 0.3*cm))
        story.append(Paragraph("Ressources mobilisées :", styles['NormalStyle']))
        for r_code in res_codes:
            res_obj = session.exec(select(Resource).where(Resource.code == r_code)).first()
            label = res_obj.label if res_obj else ""
            story.append(Paragraph(f'• <a href="#{r_code}" color="teal"><u>{r_code} : {label}</u></a>', styles['NormalStyle']))

    story.append(PageBreak())

    # --- SUBSEQUENT PAGES: DETAILS ---
    if activity.learning_outcomes:
        story.append(Paragraph("Détails des Apprentissages Critiques", styles['Heading2Style']))
        sorted_acs = sorted(activity.learning_outcomes, key=lambda x: x.code)
        for lo in sorted_acs:
            story.append(Paragraph(f'<a name="{lo.code}"/><b>{lo.code} : {lo.label}</b>', styles['Heading2Style']))
            if lo.description:
                story.append(Paragraph(clean_markdown(lo.description), styles['NormalStyle']))
            story.append(Spacer(1, 0.5*cm))
        story.append(PageBreak())

    if res_codes:
        story.append(Paragraph("Détails des Ressources", styles['Heading2Style']))
        for r_code in res_codes:
            res = session.exec(select(Resource).where(Resource.code == r_code)).first()
            if res:
                story.append(Paragraph(f'<a name="{res.code}"/><b>Ressource {res.code} : {res.label}</b>', styles['Heading2Style']))
                if res.description:
                    story.append(Paragraph("<i>Objectifs :</i>", styles['NormalStyle']))
                    story.append(Paragraph(clean_markdown(res.description), styles['NormalStyle']))
                if res.content:
                    story.append(Paragraph("<i>Contenu :</i>", styles['NormalStyle']))
                    story.append(Paragraph(clean_markdown(res.content), styles['NormalStyle']))
                story.append(Spacer(1, 0.5*cm))
        story.append(PageBreak())

    # --- FINAL PAGE: LANDSCAPE EVALUATION TABLE ---
    # Switch to Landscape template for the last page
    story.append(NextPageTemplate('landscape'))
    story.append(PageBreak())
    
    story.append(Paragraph(f'<a name="evaluation"/>Grille d\'auto-évaluation', styles['Heading2Style']))
    story.append(Paragraph("Cochez la fréquence de mobilisation de chaque compétence lors de cette activité (Utilisation optimale de la largeur paysage).", styles['NormalStyle']))
    story.append(Spacer(1, 0.5*cm))

    header = [
        Paragraph("<b>Apprentissage Critique (AC)</b>", styles['TableTextStyle']),
        Paragraph("<b>Concerné</b>", styles['TableTextStyle']),
        Paragraph("<b>Pas du tout</b>", styles['TableTextStyle']),
        Paragraph("<b>Très peu</b>", styles['TableTextStyle']),
        Paragraph("<b>Peu</b>", styles['TableTextStyle']),
        Paragraph("<b>Souvent</b>", styles['TableTextStyle']),
        Paragraph("<b>Très souvent</b>", styles['TableTextStyle'])
    ]
    table_data = [header]
    
    if activity.learning_outcomes:
        sorted_acs = sorted(activity.learning_outcomes, key=lambda x: x.code)
        for lo in sorted_acs:
            ac_label = Paragraph(f"<b>{lo.code}</b> : {lo.label}", styles['TableTextStyle'])
            table_data.append([ac_label, "", "", "", "", "", ""])

    # Optimized Widths for Landscape (Total ~26.7cm)
    col_widths = [14.0*cm, 1.7*cm, 2.2*cm, 2.2*cm, 2.2*cm, 2.2*cm, 2.2*cm]
    eval_table = Table(table_data, colWidths=col_widths, repeatRows=1)
    eval_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#e7f5ff")),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('ALIGN', (0, 0), (0, -1), 'LEFT'),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    
    story.append(eval_table)
    
    doc.build(story)
    buffer.seek(0)
    return buffer

def generate_resource_pdf(resource: Resource, session: Session):
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=1.5*cm, leftMargin=1.5*cm, topMargin=1.5*cm, bottomMargin=1.5*cm)
    story = []
    styles = get_styles()

    story.append(Paragraph(f"Ressource {resource.code} : {resource.label}", styles['TitleStyle']))
    story.append(Spacer(1, 0.5*cm))
    story.append(Paragraph(f"Parcours: {resource.pathway} | Volume : {resource.hours_details or 'N/A'}", styles['NormalStyle']))
    story.append(Spacer(1, 0.5*cm))

    if resource.description:
        story.append(Paragraph("Objectifs et Descriptif", styles['Heading2Style']))
        story.append(Paragraph(clean_markdown(resource.description), styles['NormalStyle']))
    if resource.content:
        story.append(Paragraph("Contenus pédagogiques", styles['Heading2Style']))
        story.append(Paragraph(clean_markdown(resource.content), styles['NormalStyle']))
    if resource.learning_outcomes:
        story.append(Spacer(1, 0.5*cm))
        story.append(Paragraph("Apprentissages Critiques Liés", styles['Heading2Style']))
        for lo in resource.learning_outcomes: story.append(Paragraph(f"• {lo.code} : {lo.label}", styles['NormalStyle']))

    doc.build(story)
    buffer.seek(0)
    return buffer
