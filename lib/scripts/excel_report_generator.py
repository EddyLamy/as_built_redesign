#!/usr/bin/env python3
"""
Excel Report Generator for As-Built Installation Reports
Generates professional Excel reports with multiple phases
"""

import sys
import json
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from datetime import datetime

def generate_excel_report(project_name, data_by_phase, selected_phases, output_path):
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
    
    # Salvar
    wb.save(output_path)
    print(f"✅ Excel gerado: {output_path}")


def _get_phase_headers(phase):
    """Retorna cabeçalhos das colunas para cada fase"""
    
    if phase == 'recepcao':
        return ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Descarga']
    
    elif phase in ['preparacao', 'preAssemblagem', 'assemblagem']:
        return ['Turbina', 'Component', 'VUI', 'Serial Number', 'Item Number', 'Data Início', 'Data Fim']
    
    elif phase == 'torqueTensionamento':
        return ['Turbina', 'Conexão', 'Torque Value', 'Torque Unit', 'Tensioning Value', 'Tensioning Unit', 'Data']
    
    elif phase == 'fasesFinais':
        return ['Turbina', 'Fase', 'Data Início', 'Data Fim', 'Status']
    
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
            item.get('dataDescarga'),
        ]
    
    elif phase in ['preparacao', 'preAssemblagem', 'assemblagem']:
        return [
            item.get('turbinaId', ''),
            item.get('componentId', ''),
            item.get('vui', ''),
            item.get('serialNumber', ''),
            item.get('itemNumber', ''),
            item.get('dataInicio'),
            item.get('dataFim'),
        ]
    
    elif phase == 'torqueTensionamento':
        return [
            item.get('turbinaId', ''),
            item.get('conexao', ''),
            item.get('torqueValue', ''),
            item.get('torqueUnit', ''),
            item.get('tensioningValue', ''),
            item.get('tensioningUnit', ''),
            item.get('dataExecucao'),
        ]
    
    elif phase == 'fasesFinais':
        return [
            item.get('turbinaId', ''),
            item.get('faseName', ''),
            item.get('dataInicio'),
            item.get('dataFim'),
            item.get('status', ''),
        ]
    
    return [item.get('turbinaId', ''), item.get('componentId', '')]


if __name__ == '__main__':
    # Receber dados do stdin (JSON)
    input_data = json.loads(sys.stdin.read())
    
    project_name = input_data['projectName']
    data_by_phase = input_data['dataByPhase']
    selected_phases = input_data['selectedPhases']
    output_path = input_data['outputPath']
    
    generate_excel_report(project_name, data_by_phase, selected_phases, output_path)