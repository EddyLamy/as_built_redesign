#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Script para testar o layout do dashboard"""

import sys
import os
from datetime import datetime
from excel_report_generator import generate_excel_report

# Diretório de saída
OUTPUT_DIR = r"c:\src\AS_BUILT\as_built_redesign"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "dashboard_layout_test.xlsx")

# Dados de teste realistas
data_by_phase = {
    'recepcao': [
        {'turbina': 'T001', 'status': 'Concluído', 'dataReal': '2024-01-15'},
        {'turbina': 'T002', 'status': 'Em Progresso', 'dataReal': '2024-01-16'},
        {'turbina': 'T003', 'status': 'Planeado', 'dataReal': '2024-01-17'},
        {'turbina': 'T004', 'status': 'Concluído', 'dataReal': '2024-01-18'},
        {'turbina': 'T005', 'status': 'Concluído', 'dataReal': '2024-01-19'},
        {'turbina': 'T006', 'status': 'Concluído', 'dataReal': '2024-01-20'},
        {'turbina': 'T007', 'status': 'Em Progresso', 'dataReal': '2024-01-21'}
    ],
    'preparacao': [
        {'turbina': 'T001', 'status': 'Concluído', 'dataReal': '2024-01-22'},
        {'turbina': 'T002', 'status': 'Concluído', 'dataReal': '2024-01-23'},
        {'turbina': 'T003', 'status': 'Em Progresso', 'dataReal': '2024-01-24'},
        {'turbina': 'T004', 'status': 'Em Progresso', 'dataReal': '2024-01-25'},
        {'turbina': 'T005', 'status': 'Planeado', 'dataReal': '2024-01-26'}
    ],
    'preAssemblagem': [
        {'turbina': 'T001', 'status': 'Concluído', 'dataReal': '2024-02-01'},
        {'turbina': 'T002', 'status': 'Concluído', 'dataReal': '2024-02-02'},
        {'turbina': 'T003', 'status': 'Em Progresso', 'dataReal': '2024-02-03'}
    ],
    'assemblagem': [
        {'turbina': 'T001', 'status': 'Concluído', 'dataReal': '2024-02-10'},
        {'turbina': 'T002', 'status': 'Em Progresso', 'dataReal': '2024-02-11'}
    ],
    'torqueTensionamento': [
        {'turbina': 'T001', 'status': 'Concluído', 'dataReal': '2024-02-15'}
    ],
    'fasesFinal': [],
    'gruasPads': [
        {'tipo': 'Trabalho', 'duracao': '45h', 'grua': 'Grua 1'},
        {'tipo': 'Paragem', 'duracao': '5h', 'grua': 'Grua 1'},
        {'tipo': 'Trabalho', 'duracao': '38h', 'grua': 'Grua 2'},
        {'tipo': 'Paragem', 'duracao': '3h', 'grua': 'Grua 2'}
    ],
    'gruasGerais': [
        {'tipo': 'Trabalho', 'duracao': '30h', 'grua': 'Grua 3'},
        {'tipo': 'Paragem', 'duracao': '4h', 'grua': 'Grua 3'},
        {'tipo': 'Trabalho', 'duracao': '25h', 'grua': 'Grua 4'},
        {'tipo': 'Paragem', 'duracao': '2h', 'grua': 'Grua 4'}
    ]
}

# Todas as fases selecionadas para relatório completo
selected_phases = ['recepcao', 'preparacao', 'preAssemblagem', 'assemblagem', 'torqueTensionamento', 'fasesFinal']

print(f"Gerando relatório de teste: {OUTPUT_FILE}")
print(f"  - {len(data_by_phase['recepcao'])} itens em Recepção")
print(f"  - {len(data_by_phase['preparacao'])} itens em Preparação")
print(f"  - {len(data_by_phase['preAssemblagem'])} itens em Pré-Assemblagem")
print(f"  - {len(data_by_phase['assemblagem'])} itens em Assemblagem")
print(f"  - {len(data_by_phase['torqueTensionamento'])} itens em Torque")
print(f"  - {len(data_by_phase['gruasPads'])} eventos de Gruas Pads")
print(f"  - {len(data_by_phase['gruasGerais'])} eventos de Gruas Gerais")

# Gerar relatório
try:
    result = generate_excel_report(
        project_name="Teste Layout Dashboard",
        data_by_phase=data_by_phase,
        selected_phases=selected_phases,
        output_path=OUTPUT_FILE,
        language='pt',
        complete_report=True
    )
    print(f"\n✓ Relatório gerado com sucesso: {OUTPUT_FILE}")
    print(f"  Tamanho: {os.path.getsize(OUTPUT_FILE)} bytes")
except Exception as e:
    print(f"\n✗ Erro ao gerar relatório: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
