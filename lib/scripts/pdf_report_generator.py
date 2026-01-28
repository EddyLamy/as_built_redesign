#!/usr/bin/env python3
"""
PDF Report Generator for As-Built Installation Reports
Generates professional PDF reports with tables and formatting
"""

import sys
import json
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, PageBreak
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from datetime import datetime

def generate_pdf_report(project_name, data_by_phase, selected_phases, output_path):
    """
    Gera relatório PDF com dados de instalação
    
    Args:
        project_name: Nome do projeto
        data_by_phase: Dict com dados organizados por fase
        selected_phases: Lista de fases selecionadas
        output_path: Caminho para salvar o arquivo
    """
    
    # Configurar documento (paisagem para caber mais colunas)
    doc = SimpleDocTemplate(
        output_path,
        pagesize=landscape(A4),
        rightMargin=2*cm,
        leftMargin=2*cm,
        topMargin=2*cm,
        bottomMargin=2*cm
    )
    
    # Estilos
    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#1F4E78'),
        spaceAfter=30,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    section_style = ParagraphStyle(
        'SectionTitle',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=colors.HexColor('#4472C4'),
        spaceAfter=12,
        spaceBefore=20,
        fontName='Helvetica-Bold'
    )
    
    # Story (conteúdo do PDF)
    story = []
    
    # ═══════════════════════════════════════════════════════════════
    # TÍTULO
    # ═══════════════════════════════════════════════════════════════
    
    title = Paragraph(f"Installation Report<br/>{project_name}", title_style)
    story.append(title)
    
    date_text = Paragraph(
        f"<font size=10>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</font>",
        styles['Normal']
    )
    story.append(date_text)
    story.append(Spacer(1, 1*cm))
    
    # ═══════════════════════════════════════════════════════════════
    # DADOS POR FASE
    # ═══════════════════════════════════════════════════════════════
    
    phase_names = {
        'recepcao': 'RECEÇÃO / DESCARGA',
        'preparacao': 'PREPARAÇÃO',
        'preAssemblagem': 'PRÉ-ASSEMBLAGEM',
        'assemblagem': 'ASSEMBLAGEM',
        'torqueTensionamento': 'TORQUE & TENSIONING',
        'fasesFinais': 'FASES FINAIS',
    }
    
    for phase in selected_phases:
        phase_data = data_by_phase.get(phase, [])
        
        if not phase_data:
            continue
        
        # Título da secção
        section_title = Paragraph(phase_names.get(phase, phase.upper()), section_style)
        story.append(section_title)
        
        # Criar tabela
        table_data = _create_phase_table(phase, phase_data)
        
        if table_data:
            # Criar tabela
            table = Table(table_data, repeatRows=1)
            
            # Estilo da tabela
            table.setStyle(TableStyle([
                # Cabeçalho
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1F4E78')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 10),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                
                # Dados
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
                ('ALIGN', (0, 1), (1, -1), 'LEFT'),
                ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
                ('FONTSIZE', (0, 1), (-1, -1), 8),
                ('TOPPADDING', (0, 1), (-1, -1), 6),
                ('BOTTOMPADDING', (0, 1), (-1, -1), 6),
                
                # Grid
                ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
                
                # Linhas alternadas
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F5F5F5')]),
            ]))
            
            story.append(table)
            story.append(Spacer(1, 0.5*cm))
    
    # Gerar PDF
    doc.build(story)
    print(f"✅ PDF gerado: {output_path}")


def _create_phase_table(phase, phase_data):
    """Cria dados da tabela para uma fase"""
    
    # Cabeçalhos
    if phase == 'recepcao':
        headers = ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Descarga']
        columns = ['turbinaId', 'componentId', 'vui', 'serialNumber', 'itemNumber', 'dataDescarga']
    
    elif phase in ['preparacao', 'preAssemblagem', 'assemblagem']:
        headers = ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Início', 'Data Fim']
        columns = ['turbinaId', 'componentId', 'vui', 'serialNumber', 'itemNumber', 'dataInicio', 'dataFim']
    
    elif phase == 'torqueTensionamento':
        headers = ['Turbina', 'Conexão', 'Torque Value', 'Torque Unit', 'Tensioning Value', 'Tensioning Unit', 'Data']
        columns = ['turbinaId', 'conexao', 'torqueValue', 'torqueUnit', 'tensioningValue', 'tensioningUnit', 'dataExecucao']
    
    elif phase == 'fasesFinais':
        headers = ['Turbina', 'Fase', 'Data Início', 'Data Fim', 'Status']
        columns = ['turbinaId', 'faseName', 'dataInicio', 'dataFim', 'status']
    
    else:
        return None
    
    # Criar dados da tabela
    table_data = [headers]
    
    for item in phase_data:
        row = []
        for col_key in columns:
            value = item.get(col_key, '')
            
            # Formatar datas
            if col_key in ['dataDescarga', 'dataInicio', 'dataFim', 'dataExecucao']:
                if hasattr(value, 'strftime'):
                    value = value.strftime('%d/%m/%Y')
                elif value:
                    value = str(value)
                else:
                    value = ''
            
            row.append(str(value) if value else '')
        
        table_data.append(row)
    
    return table_data


if __name__ == '__main__':
    # Receber dados do stdin (JSON)
    input_data = json.loads(sys.stdin.read())
    
    project_name = input_data['projectName']
    data_by_phase = input_data['dataByPhase']
    selected_phases = input_data['selectedPhases']
    output_path = input_data['outputPath']
    
    generate_pdf_report(project_name, data_by_phase, selected_phases, output_path)