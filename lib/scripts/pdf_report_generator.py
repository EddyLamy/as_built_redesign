#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF Report Generator for As-Built Installation Reports
Generates professional PDF reports with tables and formatting
"""

import sys
import json
import io

# Ensure UTF-8 encoding for stdout on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, PageBreak
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from datetime import datetime


# ══════════════════════════════════════════════════════════════════════════
# FUNÇÕES DE TRADUÇÃO (NO TOPO, ANTES DE TUDO)
# ══════════════════════════════════════════════════════════════════════════

def translate_tipo(tipo, language='pt'):
    """Traduzir tipo de atividade"""
    translations = {
        'mobilizacao': 'Mobilização',
        'trabalho': 'Trabalho',
        'paragem': 'Paragem',
        'transferencia': 'Transferência',
        'desmobilizacao': 'Desmobilização'
    }
    return translations.get(tipo, tipo)


def translate_motivo(motivo, language='pt'):
    """Traduzir motivo de paragem"""
    if not motivo:
        return ''
    
    translations = {
        'wind': 'Vento',
        'mechanical': 'Problema Mecânico',
        'waiting_components': 'Aguardar Componentes',
        'safety': 'Segurança'
    }
    return translations.get(motivo, motivo)


# ══════════════════════════════════════════════════════════════════════════
# FUNÇÕES DE GRUAS
# ══════════════════════════════════════════════════════════════════════════

def add_gruas_pads_section(story, styles, gruas_data, language='pt'):
    """Adicionar secção de Gruas de Pads ao PDF"""
    
    print(f"DEBUG: add_gruas_pads_section called with {len(gruas_data) if gruas_data else 0} items")
    
    # Título
    story.append(Paragraph("GRUAS (PADS)", styles['Heading1']))
    story.append(Spacer(1, 12))
    
    if not gruas_data:
        story.append(Paragraph("Nenhuma atividade registada.", styles['Normal']))
        print("[WARN] Nenhuma atividade de Gruas de Pads")
        return
    
    # Preparar dados para tabela
    table_data = [[
        'Turbina',
        'Grua',
        'Tipo',
        'Início',
        'Fim',
        'Duração',
        'Obs'
    ]]
    
    for item in gruas_data:
        obs = item.get('observacoes', '')
        obs_truncated = obs[:30] + '...' if len(obs) > 30 else obs
        
        table_data.append([
            item.get('turbinaId', ''),
            item.get('gruaModelo', ''),
            translate_tipo(item.get('tipo', ''), language),
            f"{item.get('dataInicio', '')} {item.get('horaInicio', '')}",
            f"{item.get('dataFim', '')} {item.get('horaFim', '')}",
            item.get('duracao', ''),
            obs_truncated
        ])
    
    # Criar tabela
    table = Table(table_data, colWidths=[60, 90, 70, 80, 80, 50, 100])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#4472C4')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('FONTSIZE', (0, 1), (-1, -1), 8),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),
    ]))
    
    story.append(table)
    story.append(Spacer(1, 12))
    
    # Resumo
    total_atividades = len(gruas_data)
    story.append(Paragraph(f"<b>Total de atividades:</b> {total_atividades}", styles['Normal']))
    
    print(f"[OK] Seção 'Gruas (Pads)' adicionada com {total_atividades} registros")


def add_gruas_gerais_section(story, styles, gruas_data, language='pt'):
    """Adicionar secção de Gruas Gerais ao PDF"""
    
    print(f"DEBUG: add_gruas_gerais_section called with {len(gruas_data) if gruas_data else 0} items")
    
    # Título
    story.append(Paragraph("GRUAS GERAIS", styles['Heading1']))
    story.append(Spacer(1, 12))
    
    if not gruas_data:
        story.append(Paragraph("Nenhuma atividade registada.", styles['Normal']))
        print("[WARN] Nenhuma atividade de Gruas Gerais")
        return
    
    # Preparar dados para tabela
    table_data = [[
        'Grua',
        'Descrição',
        'Tipo',
        'Início',
        'Fim',
        'Duração',
        'Obs'
    ]]
    
    for item in gruas_data:
        desc = item.get('descricao', '')
        desc_truncated = desc[:20] + '...' if len(desc) > 20 else desc
        
        obs = item.get('observacoes', '')
        obs_truncated = obs[:30] + '...' if len(obs) > 30 else obs
        
        table_data.append([
            item.get('gruaModelo', ''),
            desc_truncated,
            translate_tipo(item.get('tipo', ''), language),
            f"{item.get('dataInicio', '')} {item.get('horaInicio', '')}",
            f"{item.get('dataFim', '')} {item.get('horaFim', '')}",
            item.get('duracao', ''),
            obs_truncated
        ])
    
    # Criar tabela
    table = Table(table_data, colWidths=[90, 80, 70, 80, 80, 50, 100])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#70AD47')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('FONTSIZE', (0, 1), (-1, -1), 8),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),
    ]))
    
    story.append(table)
    story.append(Spacer(1, 12))
    
    # Resumo
    total_atividades = len(gruas_data)
    story.append(Paragraph(f"<b>Total de atividades:</b> {total_atividades}", styles['Normal']))
    
    print(f"[OK] Seção 'Gruas Gerais' adicionada com {total_atividades} registros")


# ══════════════════════════════════════════════════════════════════════════
# FUNÇÃO PRINCIPAL
# ══════════════════════════════════════════════════════════════════════════

def generate_pdf_report(project_name, data_by_phase, selected_phases, output_path, language='pt'):
    """
    Gera relatório PDF com dados de instalação
    """
    
    doc = SimpleDocTemplate(
        output_path,
        pagesize=landscape(A4),
        rightMargin=2*cm,
        leftMargin=2*cm,
        topMargin=2*cm,
        bottomMargin=2*cm
    )
    
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
    
    story = []
    
    # TÍTULO
    title = Paragraph(f"Installation Report<br/>{project_name}", title_style)
    story.append(title)
    
    date_text = Paragraph(
        f"<font size=10>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</font>",
        styles['Normal']
    )
    story.append(date_text)
    story.append(Spacer(1, 1*cm))
    
    # DADOS POR FASE
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
        
        # Criar tabela (código existente...)
        table_data = _create_phase_table(phase, phase_data)
        
        if table_data:
            table = Table(table_data, repeatRows=1)
            
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1F4E78')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 10),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
                ('ALIGN', (0, 1), (1, -1), 'LEFT'),
                ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
                ('FONTSIZE', (0, 1), (-1, -1), 8),
                ('TOPPADDING', (0, 1), (-1, -1), 6),
                ('BOTTOMPADDING', (0, 1), (-1, -1), 6),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F5F5F5')]),
            ]))
            
            story.append(table)
            story.append(Spacer(1, 0.5*cm))
    
    # ====================================================================
    # ADICIONAR SECOES DE GRUAS
    # ====================================================================
    
    print("DEBUG: Processing crane sections")
    
    # Processar Gruas de Pads
    if 'gruasPads' in selected_phases:
        print("DEBUG: 'gruasPads' in selected_phases: True")
        if data_by_phase.get('gruasPads'):
            print("[OK] Adding 'Gruas de Pads' section")
            story.append(PageBreak())
            add_gruas_pads_section(story, styles, data_by_phase['gruasPads'], language)
        else:
            print("[WARN] 'gruasPads' selected but no data found")
    else:
        print("DEBUG: 'gruasPads' NOT in selected_phases")

    # Processar Gruas Gerais
    if 'gruasGerais' in selected_phases:
        print("DEBUG: 'gruasGerais' in selected_phases: True")
        if data_by_phase.get('gruasGerais'):
            print("[OK] Adding 'Gruas Gerais' section")
            story.append(PageBreak())
            add_gruas_gerais_section(story, styles, data_by_phase['gruasGerais'], language)
        else:
            print("[WARN] 'gruasGerais' selected but no data found")
    else:
        print("DEBUG: 'gruasGerais' NOT in selected_phases")
    
    # Gerar PDF
    doc.build(story)
    print(f"PDF gerado: {output_path}")


def _create_phase_table(phase, phase_data):
    """Cria dados da tabela para uma fase"""
    
    # (Código existente mantém-se igual)
    if phase == 'recepcao':
        headers = ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Descarga', 'Hora']
        columns = ['turbinaId', 'componentId', 'vui', 'serialNumber', 'itemNumber', 'dataDescarga', 'horaDescarga']
    
    elif phase in ['preparacao', 'preAssemblagem', 'assemblagem']:
        headers = ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Início', 'Hora Início', 'Data Fim', 'Hora Fim']
        columns = ['turbinaId', 'componentId', 'vui', 'serialNumber', 'itemNumber', 'dataInicio', 'horaInicio', 'dataFim', 'horaFim']
    
    elif phase == 'torqueTensionamento':
        headers = ['Turbina', 'Conexão', 'Torque Value', 'Torque Unit', 'Tensioning Value', 'Tensioning Unit', 'Data', 'Hora']
        columns = ['turbinaId', 'conexao', 'torqueValue', 'torqueUnit', 'tensioningValue', 'tensioningUnit', 'dataExecucao', 'horaExecucao']
    
    elif phase == 'fasesFinais':
        headers = ['Turbina', 'Fase', 'Data Início', 'Hora Início', 'Data Fim', 'Hora Fim', 'Status']
        columns = ['turbinaId', 'faseName', 'dataInicio', 'horaInicio', 'dataFim', 'horaFim', 'status']
    
    else:
        return None
    
    table_data = [headers]
    
    for item in phase_data:
        row = []
        for col_key in columns:
            value = item.get(col_key, '')
            row.append(str(value) if value else '')
        table_data.append(row)
    
    return table_data


# ══════════════════════════════════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    input_data = json.loads(sys.stdin.read())
    
    project_name = input_data['projectName']
    data_by_phase = input_data['dataByPhase']
    selected_phases = input_data['selectedPhases']
    output_path = input_data['outputPath']
    language = input_data.get('language', 'pt')
    
    generate_pdf_report(project_name, data_by_phase, selected_phases, output_path, language)