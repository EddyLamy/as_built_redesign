#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Excel Report Generator for As-Built Installation Reports
Generates professional Excel reports with multiple phases
"""

import sys
import json
import io

# Ensure UTF-8 encoding for stdout on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from datetime import datetime
from openpyxl.utils import get_column_letter

def generate_excel_report(project_name, data_by_phase, selected_phases, output_path, language='pt'):
    """
    Gera relatório Excel com dados de instalação
    
    Args:
        project_name: Nome do projeto
        data_by_phase: Dict com dados organizados por fase
        selected_phases: Lista de fases selecionadas
        output_path: Caminho para salvar o arquivo
    """
    
    wb = Workbook()
    ws = wb.active
    ws.title = "Installation Report"
    
    # Configurar larguras de colunas
    ws.column_dimensions['A'].width = 20
    ws.column_dimensions['B'].width = 20
    ws.column_dimensions['C'].width = 20
    ws.column_dimensions['D'].width = 20
    ws.column_dimensions['E'].width = 20
    
    # Estilos
    header_fill = PatternFill(start_color="1F4E78", end_color="1F4E78", fill_type="solid")
    header_font = Font(bold=True, color="FFFFFF", size=12)
    section_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
    section_font = Font(bold=True, color="FFFFFF", size=11)
    border = Border(
        left=Side(style='thin'),
        right=Side(style='thin'),
        top=Side(style='thin'),
        bottom=Side(style='thin')
    )
    
    current_row = 1
    
    # ═══════════════════════════════════════════════════════════════
    # TÍTULO DO RELATÓRIO
    # ═══════════════════════════════════════════════════════════════
    ws.merge_cells(f'A{current_row}:E{current_row}')
    title_cell = ws[f'A{current_row}']
    title_cell.value = f"Installation Report - {project_name}"
    title_cell.font = Font(bold=True, size=16, color="1F4E78")
    title_cell.alignment = Alignment(horizontal='center', vertical='center')
    current_row += 1
    
    # Data de geração
    ws.merge_cells(f'A{current_row}:E{current_row}')
    date_cell = ws[f'A{current_row}']
    date_cell.value = f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    date_cell.font = Font(size=10, color="666666")
    date_cell.alignment = Alignment(horizontal='center')
    current_row += 2
    
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
        
        # ───────────────────────────────────────────────────────────
        # TÍTULO DA SECÇÃO
        # ───────────────────────────────────────────────────────────
        ws.merge_cells(f'A{current_row}:E{current_row}')
        section_cell = ws[f'A{current_row}']
        section_cell.value = phase_names.get(phase, phase.upper())
        section_cell.fill = section_fill
        section_cell.font = section_font
        section_cell.alignment = Alignment(horizontal='center', vertical='center')
        section_cell.border = border
        current_row += 1
        
        # ───────────────────────────────────────────────────────────
        # CABEÇALHO DA TABELA
        # ───────────────────────────────────────────────────────────
        headers = _get_phase_headers(phase)
        
        for col_idx, header in enumerate(headers, start=1):
            cell = ws.cell(row=current_row, column=col_idx)
            cell.value = header
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal='center', vertical='center')
            cell.border = border
        
        current_row += 1
        
        # ───────────────────────────────────────────────────────────
        # DADOS
        # ───────────────────────────────────────────────────────────
        for item in phase_data:
            row_data = _format_phase_row(phase, item)
            
            for col_idx, value in enumerate(row_data, start=1):
                cell = ws.cell(row=current_row, column=col_idx)
                cell.value = value
                cell.border = border
                cell.alignment = Alignment(horizontal='left', vertical='center')
                
                # Formatar datas
                if isinstance(value, datetime):
                    cell.number_format = 'DD/MM/YYYY HH:MM'
            
            current_row += 1
        
        # Espaço entre secções
        current_row += 2
    
    # ═══════════════════════════════════════════════════════════════
    # GRUAS DE PADS
    # ═══════════════════════════════════════════════════════════════
    print(f"DEBUG: Processing 'gruasPads' - in selected_phases: {'gruasPads' in selected_phases}")
    if 'gruasPads' in selected_phases:
        pads_data = data_by_phase.get('gruasPads')
        if pads_data:
            print(f"[OK] Adding 'Gruas de Pads' sheet with {len(pads_data)} items")
            _add_gruas_pads_sheet(wb, pads_data, language)
        else:
            print("[WARN] 'gruasPads' selected but no data found")
    
    # ═══════════════════════════════════════════════════════════════
    # GRUAS GERAIS
    # ═══════════════════════════════════════════════════════════════
    print(f"DEBUG: Processing 'gruasGerais' - in selected_phases: {'gruasGerais' in selected_phases}")
    if 'gruasGerais' in selected_phases:
        gerais_data = data_by_phase.get('gruasGerais')
        if gerais_data:
            print(f"[OK] Adding 'Gruas Gerais' sheet with {len(gerais_data)} items")
            _add_gruas_gerais_sheet(wb, gerais_data, language)
        else:
            print("[WARN] 'gruasGerais' selected but no data found")
    
    # Salvar
    wb.save(output_path)
    print(f"Excel gerado: {output_path}")


def _get_phase_headers(phase):
    """Retorna cabeçalhos das colunas para cada fase"""
    
    if phase == 'recepcao':
        return ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Descarga', 'Hora']
    
    elif phase in ['preparacao', 'preAssemblagem', 'assemblagem']:
        return ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Início', 'Hora Início', 'Data Fim', 'Hora Fim']
    
    elif phase == 'torqueTensionamento':
        return ['Turbina', 'Conexão', 'Torque Value', 'Torque Unit', 'Tensioning Value', 'Tensioning Unit', 'Data', 'Hora']
    
    elif phase == 'fasesFinais':
        return ['Turbina', 'Fase', 'Data Início', 'Hora Início', 'Data Fim', 'Hora Fim', 'Status']
    
    return ['Turbina', 'Component', 'Data']


def _format_phase_row(phase, item):
    """Formata uma linha de dados para a fase"""
    
    if phase == 'recepcao':
        return [
            item.get('turbinaId', ''),
            item.get('componentId', ''),
            item.get('vui', ''),
            item.get('serialNumber', ''),
            item.get('itemNumber', ''),
            item.get('dataDescarga', ''),
            item.get('horaDescarga', ''),
        ]
    
    elif phase in ['preparacao', 'preAssemblagem', 'assemblagem']:
        return [
            item.get('turbinaId', ''),
            item.get('componentId', ''),
            item.get('vui', ''),
            item.get('serialNumber', ''),
            item.get('itemNumber', ''),
            item.get('dataInicio', ''),
            item.get('horaInicio', ''),
            item.get('dataFim', ''),
            item.get('horaFim', ''),
        ]
    
    elif phase == 'torqueTensionamento':
        return [
            item.get('turbinaId', ''),
            item.get('conexao', ''),
            item.get('torqueValue', ''),
            item.get('torqueUnit', ''),
            item.get('tensioningValue', ''),
            item.get('tensioningUnit', ''),
            item.get('dataExecucao', ''),
            item.get('horaExecucao', ''),
        ]
    
    elif phase == 'fasesFinais':
        return [
            item.get('turbinaId', ''),
            item.get('faseName', ''),
            item.get('dataInicio', ''),
            item.get('horaInicio', ''),
            item.get('dataFim', ''),
            item.get('horaFim', ''),
            item.get('status', ''),
        ]
    
    return [item.get('turbinaId', ''), item.get('componentId', '')]


def _add_gruas_pads_sheet(wb, gruas_data, lang='pt'):
    """Criar sheet de Gruas de Pads"""
    print(f"[DEBUG] _add_gruas_pads_sheet called with {len(gruas_data)} items")
    sheet_name = 'Cranes (Pads)' if lang == 'en' else 'Gruas (Pads)'
    ws = wb.create_sheet(sheet_name)
    
    # Estilos
    header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
    header_font = Font(bold=True, color="FFFFFF", size=11)
    cell_fill = PatternFill(start_color="FFFFFF", end_color="FFFFFF", fill_type="solid")
    border = Border(
        left=Side(style='thin'),
        right=Side(style='thin'),
        top=Side(style='thin'),
        bottom=Side(style='thin')
    )
    
    # Headers traduzidos
    if lang == 'en':
        headers = [
            'Turbine',
            'Crane Model',
            'Activity Type',
            'Start Date',
            'Start Time',
            'End Date',
            'End Time',
            'Duration',
            'Reason',
            'Origin',
            'Destination',
            'Notes'
        ]
    else:
        headers = [
            'Turbina',
            'Modelo da Grua',
            'Tipo de Atividade',
            'Data Início',
            'Hora Início',
            'Data Fim',
            'Hora Fim',
            'Duração',
            'Motivo',
            'Origem',
            'Destino',
            'Observações'
        ]
    
    # Larguras das colunas
    column_widths = [12, 20, 15, 12, 10, 12, 10, 10, 15, 12, 12, 30]
    
    # ══════════════════════════════════════════════════════════════
    # ESCREVER HEADERS (1 LOOP)
    # ══════════════════════════════════════════════════════════════
    for col_idx, header in enumerate(headers, start=1):
        cell = ws.cell(row=1, column=col_idx)
        cell.value = header
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal='center', vertical='center')
        cell.border = border
    
    # ══════════════════════════════════════════════════════════════
    # DEFINIR LARGURAS (LOOP SEPARADO)
    # ══════════════════════════════════════════════════════════════
    for col_idx, width in enumerate(column_widths, start=1):
        column_letter = get_column_letter(col_idx)
        ws.column_dimensions[column_letter].width = width
    
    # ══════════════════════════════════════════════════════════════
    # ESCREVER DADOS
    # ══════════════════════════════════════════════════════════════
    for row_idx, item in enumerate(gruas_data, start=2):
        ws.cell(row=row_idx, column=1, value=item.get('turbinaId', '')).border = border
        ws.cell(row=row_idx, column=2, value=item.get('gruaModelo', '')).border = border
        ws.cell(row=row_idx, column=3, value=translate_tipo(item.get('tipo', ''), lang)).border = border
        ws.cell(row=row_idx, column=4, value=item.get('dataInicio', '')).border = border
        ws.cell(row=row_idx, column=5, value=item.get('horaInicio', '')).border = border
        ws.cell(row=row_idx, column=6, value=item.get('dataFim', '')).border = border
        ws.cell(row=row_idx, column=7, value=item.get('horaFim', '')).border = border
        ws.cell(row=row_idx, column=8, value=item.get('duracao', '')).border = border
        ws.cell(row=row_idx, column=9, value=translate_motivo(item.get('motivo', ''), lang)).border = border
        ws.cell(row=row_idx, column=10, value=item.get('origem', '')).border = border
        ws.cell(row=row_idx, column=11, value=item.get('destino', '')).border = border
        ws.cell(row=row_idx, column=12, value=item.get('observacoes', '')).border = border
    
    msg = f"✓ Sheet '{sheet_name}' created with {len(gruas_data)} records" if lang == 'en' else f"✓ Sheet '{sheet_name}' criada com {len(gruas_data)} registros"
    print(msg)


def _add_gruas_gerais_sheet(wb, gruas_data, lang='pt'):
    """Criar sheet de Gruas Gerais"""
    print(f"DEBUG: _add_gruas_gerais_sheet called with {len(gruas_data)} items")
    sheet_name = 'Cranes (General)' if lang == 'en' else 'Gruas Gerais'
    ws = wb.create_sheet(sheet_name)
    
    # Estilos
    header_fill = PatternFill(start_color="70AD47", end_color="70AD47", fill_type="solid")
    header_font = Font(bold=True, color="FFFFFF", size=11)
    border = Border(
        left=Side(style='thin'),
        right=Side(style='thin'),
        top=Side(style='thin'),
        bottom=Side(style='thin')
    )
    
    # Headers (SEM coluna Turbina, COM coluna Descrição)
    if lang == 'en':
        headers = [
            'Crane Model',
            'Description',
            'Activity Type',
            'Start Date',
            'Start Time',
            'End Date',
            'End Time',
            'Duration',
            'Reason',
            'Origin',
            'Destination',
            'Notes'
        ]
    else:
        headers = [
            'Modelo da Grua',
            'Descrição',
            'Tipo de Atividade',
            'Data Início',
            'Hora Início',
            'Data Fim',
            'Hora Fim',
            'Duração',
            'Motivo',
            'Origem',
            'Destino',
            'Observações'
    ]
    
    # Larguras das colunas
    column_widths = [20, 25, 15, 12, 10, 12, 10, 10, 15, 12, 12, 30]
    
    # ══════════════════════════════════════════════════════════════
    # ESCREVER HEADERS
    # ══════════════════════════════════════════════════════════════
    for col_idx, header in enumerate(headers, start=1):
        cell = ws.cell(row=1, column=col_idx)
        cell.value = header
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = Alignment(horizontal='center', vertical='center')
        cell.border = border
    
    # ══════════════════════════════════════════════════════════════
    # DEFINIR LARGURAS
    # ══════════════════════════════════════════════════════════════
    for col_idx, width in enumerate(column_widths, start=1):
        column_letter = get_column_letter(col_idx)
        ws.column_dimensions[column_letter].width = width
    
    # ══════════════════════════════════════════════════════════════
    # ESCREVER DADOS
    # ══════════════════════════════════════════════════════════════
    for row_idx, item in enumerate(gruas_data, start=2):
        ws.cell(row=row_idx, column=1, value=item.get('gruaModelo', '')).border = border
        ws.cell(row=row_idx, column=2, value=item.get('descricao', '')).border = border
        ws.cell(row=row_idx, column=3, value=translate_tipo(item.get('tipo', ''), lang)).border = border
        ws.cell(row=row_idx, column=4, value=item.get('dataInicio', '')).border = border
        ws.cell(row=row_idx, column=5, value=item.get('horaInicio', '')).border = border
        ws.cell(row=row_idx, column=6, value=item.get('dataFim', '')).border = border
        ws.cell(row=row_idx, column=7, value=item.get('horaFim', '')).border = border
        ws.cell(row=row_idx, column=8, value=item.get('duracao', '')).border = border
        ws.cell(row=row_idx, column=9, value=translate_motivo(item.get('motivo', ''), lang)).border = border
        ws.cell(row=row_idx, column=10, value=item.get('origem', '')).border = border
        ws.cell(row=row_idx, column=11, value=item.get('destino', '')).border = border
        ws.cell(row=row_idx, column=12, value=item.get('observacoes', '')).border = border
    
    print(f"✓ Sheet 'Gruas Gerais' criada com {len(gruas_data)} registros")


def translate_tipo(tipo, lang='pt'):
    """Traduzir tipo de atividade"""
    if lang == 'en':
        translations = {
            'mobilizacao': 'Mobilization',
            'trabalho': 'Work',
            'paragem': 'Stoppage',
            'transferencia': 'Transfer',
            'desmobilizacao': 'Demobilization'
        }
    else:  # pt
        translations = {
            'mobilizacao': 'Mobilização',
            'trabalho': 'Trabalho',
            'paragem': 'Paragem',
            'transferencia': 'Transferência',
            'desmobilizacao': 'Desmobilização'
        }
    return translations.get(tipo, tipo)


def translate_motivo(motivo, lang='pt'):
    """Traduzir motivo de paragem"""
    if not motivo:
        return ''
    
    if lang == 'en':
        translations = {
            'wind': 'Wind',
            'mechanical': 'Mechanical Issue',
            'waiting_components': 'Waiting Components',
            'safety': 'Safety'
        }
    else:  # pt
        translations = {
            'wind': 'Vento',
            'mechanical': 'Problema Mecânico',
            'waiting_components': 'Aguardar Componentes',
            'safety': 'Segurança'
        }
    return translations.get(motivo, motivo)


if __name__ == '__main__':
    input_data = json.loads(sys.stdin.read())
    
    project_name = input_data['projectName']
    data_by_phase = input_data['dataByPhase']
    selected_phases = input_data['selectedPhases']
    output_path = input_data['outputPath']
    language = input_data.get('language', 'pt')  # Language parameter
    
    generate_excel_report(project_name, data_by_phase, selected_phases, output_path, language)  # Pass language