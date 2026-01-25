from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle, PageBreak
from reportlab.lib.units import cm
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
import io
import json
from datetime import datetime

def generate_portfolio_pdf(user, ppp, pages, internships, accent_color="#1971c2"):
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=2*cm, leftMargin=2*cm, topMargin=2*cm, bottomMargin=2*cm)
    styles = getSampleStyleSheet()
    
    # Styles personnalisés
    title_style = ParagraphStyle('TitleStyle', parent=styles['Heading1'], fontSize=24, spaceAfter=20, textColor=colors.HexColor(accent_color), alignment=TA_CENTER)
    subtitle_style = ParagraphStyle('SubTitleStyle', parent=styles['Heading2'], fontSize=18, spaceBefore=15, spaceAfter=10, textColor=colors.HexColor(accent_color))
    normal_style = styles['Normal']
    normal_style.alignment = TA_JUSTIFY
    
    elements = []

    # --- COUVERTURE ---
    elements.append(Spacer(1, 5*cm))
    elements.append(Paragraph("PORTFOLIO DE COMPÉTENCES", title_style))
    elements.append(Paragraph("BUT Techniques de Commercialisation", ParagraphStyle('Inst', parent=styles['Normal'], alignment=TA_CENTER, fontSize=14)))
    elements.append(Spacer(1, 2*cm))
    elements.append(Paragraph(user.full_name, ParagraphStyle('Name', parent=title_style, fontSize=32)))
    elements.append(Spacer(1, 1*cm))
    elements.append(Paragraph(f"Contact : {user.email}", ParagraphStyle('Email', parent=styles['Normal'], alignment=TA_CENTER)))
    elements.append(Spacer(1, 10*cm))
    elements.append(Paragraph(f"Généré le {datetime.now().strftime('%d/%m/%Y')}", ParagraphStyle('Date', parent=styles['Normal'], alignment=TA_CENTER, fontSize=8, textColor=colors.gray)))
    elements.append(PageBreak())

    # --- PROJET PROFESSIONNEL (PPP) ---
    elements.append(Paragraph("Mon Projet Personnel et Professionnel (PPP)", subtitle_style))
    if ppp:
        elements.append(Paragraph("<b>Mes Ambitions :</b>", styles['Heading3']))
        elements.append(Paragraph(ppp.career_goals or "Non renseigné", normal_style))
        elements.append(Spacer(1, 0.5*cm))
        elements.append(Paragraph("<b>Ma Réflexion :</b>", styles['Heading3']))
        elements.append(Paragraph(ppp.content_json or "", normal_style))
    else:
        elements.append(Paragraph("Aucune donnée PPP renseignée.", normal_style))
    elements.append(Spacer(1, 1*cm))

    # --- EXPÉRIENCES PRO (STAGES) ---
    elements.append(Paragraph("Expériences Professionnelles", subtitle_style))
    if internships:
        for i in internships:
            data = [
                [Paragraph(f"<b>{i.company_name}</b>", normal_style)],
                [Paragraph(f"Période : Du {i.start_date.strftime('%d/%m/%Y') if i.start_date else '?'} au {i.end_date.strftime('%d/%m/%Y') if i.end_date else '?'}", normal_style)],
                [Paragraph(f"Tuteur Entreprise : {i.supervisor_name or 'N/A'}", normal_style)]
            ]
            t = Table(data, colWidths=[16*cm])
            t.setStyle(TableStyle([
                ('BOX', (0,0), (-1,-1), 0.5, colors.gray),
                ('BACKGROUND', (0,0), (-1,0), colors.whitesmoke),
                ('PADDING', (0,0), (-1,-1), 6),
            ]))
            elements.append(t)
            elements.append(Spacer(1, 0.5*cm))
    else:
        elements.append(Paragraph("Aucun stage enregistré.", normal_style))
    
    elements.append(PageBreak())

    # --- PAGES DE RÉFLEXION ---
    elements.append(Paragraph("Dossier de Compétences", subtitle_style))
    for p in pages:
        elements.append(Paragraph(p.title, styles['Heading3']))
        elements.append(Paragraph(f"Dernière mise à jour : {p.updated_at.strftime('%d/%m/%Y')}", ParagraphStyle('Small', fontSize=8, textColor=colors.gray)))
        
        # Parsing sommaire du contenu Editor.js
        try:
            content = json.loads(p.content_json)
            for block in content.get('blocks', []):
                if block['type'] == 'paragraph':
                    # Nettoyage sommaire des balises HTML pour ReportLab
                    text = block['data']['text'].replace('<br>', '<br/>')
                    elements.append(Paragraph(text, normal_style))
                elif block['type'] == 'header':
                    elements.append(Paragraph(block['data']['text'], styles[f"Heading{min(block['data']['level'], 4)}"]))
                elif block['type'] == 'quote':
                    elements.append(Spacer(1, 0.2*cm))
                    elements.append(Paragraph(f"<i>{block['data']['text']}</i>", ParagraphStyle('Quote', leftIndent=20, textColor=colors.darkgray)))
                    elements.append(Paragraph(f"<small>{block['data']['caption']}</small>", ParagraphStyle('Caption', leftIndent=20, fontSize=8, textColor=colors.gray)))
                elements.append(Spacer(1, 0.3*cm))
        except:
            elements.append(Paragraph("[Contenu non lisible]", normal_style))
        
        elements.append(Spacer(1, 1*cm))

    doc.build(elements)
    buffer.seek(0)
    return buffer
