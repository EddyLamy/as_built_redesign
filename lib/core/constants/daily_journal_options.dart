const String dailyJournalTemplateDocumentNo = 'M20 Vers. 1';
const String dailyJournalTemplateReference = 'F11';
const String dailyJournalTemplateCreatedBy = 'Joao Baptista';
const String dailyJournalTemplateApprovedBy = 'Joao Baptista';
const String dailyJournalTemplateDate = '17/05/2016';

const List<String> dailyJournalLocations = [
  'BASE COMPOUND',
  'MULTIPLE PADS',
  'PAD 01',
  'PAD 02',
  'PAD 03',
  'PAD 04',
  'PAD 05',
  'PAD 06',
  'PAD 07',
  'PAD 08',
  'PAD 09',
  'PAD 10',
  'PAD 11',
  'PAD 12',
  'PAD 13',
  'PAD 14',
  'PAD 15',
  'PAD 16',
  'PAD 17',
  'PAD 18',
  'PAD 19',
  'PAD 20',
  'PAD 21',
  'PAD 22',
  'PAD 23',
  'PAD 24',
  'PAD 25',
  'PAD 26',
];

const Map<String, List<String>> dailyJournalCategories = {
  'Crane': [
    'Assembly',
    'Transfer',
    'Disassembly',
    'Inspect',
    'Damage',
    'Repair',
    'Return elements',
    'Receive elements',
  ],
  'Transport': [
    'Delivery Office Container',
    'Delivery Hand Tools Container',
    'Delivery Lifting Tools Container',
    'Delivery LDST Tools Container',
    'Delivery Tools',
    'Delivery Consumables',
    'Return site parts',
    'Return tools',
    'Return containers',
    'Delivery Welfare Container',
  ],
  'Delivery_Main_Components': [
    'Blades',
    'Hub',
    'PTR',
    'DT',
    'Nacelle',
    'Bottom',
    'Bottom LDST',
    'M1',
    'M1 LDST',
    'M2',
    'M2 LDST',
    'M3',
    'M4',
    'Top',
    'Top Cooler',
    'Switch Gear',
    'Electrical Cabinets',
    'Tower Site Parts',
    'Nacelle Site Parts',
    'Hub Site Parts',
    'DT Site Parts',
    'PTR Site Parts',
    'HV Cable',
    'LV Cable',
    'Electrical components',
    'T1 (Envision)',
    'T2 (Envision)',
    'T3 (Envivion)',
    'T4 (Envision)',
    'T5 (Envision)',
    'T6 (Envision)',
    'Gearbox Vent (Envision)',
    'Spinner (Envision)',
  ],
  'Preparation': [
    'Prep Foundation (Switchgear, tower feets, ...)',
    'Prep Components to Erection',
    'Pre installation',
    'Blades',
    'Hub',
    'PTR',
    'DT',
    'Nacelle',
    'Temporary AV Lights',
    'Bottom',
    'Bottom LDST',
    'M1',
    'M1 LDST',
    'M2',
    'M2 LDST',
    'M3',
    'M4',
    'Top',
    'Top Cooler',
    'Top Cooler on nacelle',
    'Install Molly in the Nacelle',
    'Install Molly in PTR',
    'Install Wheel in the Hub',
    'Install Molly in the Hub',
    'T1 (Envision)',
    'T2 (Envision)',
    'T3 (Envivion)',
    'T4 (Envision)',
    'T5 (Envision)',
    'T6 (Envision)',
  ],
  'Installation.': [
    'SWG',
    'Bottom',
    'M1',
    'Grouting',
    'M2',
    'M3',
    'M4',
    'Top',
    'Nacelle',
    'PTR',
    'DT',
    'Hub',
    'Blade A',
    'Blade B',
    'Blade C',
    'Service Lift',
    'HV Cable',
    'LV cables',
    'Cabinets',
    'Tower AV Lights',
    'Platform for Cabinets (Envision)',
    'Conversor (Envision)',
    'Transformer (Envision)',
    'Kioske (Envision)',
    'T1 (Envision)',
    'T2 (Envision)',
    'T3 (Envivion)',
    'T4 (Envision)',
    'T5 (Envision)',
    'T6 (Envision)',
    'Gearbox Vent (Envision)',
    'Spinner (Envision)',
  ],
  'Mechanical': [
    'Torque Tower Bolts',
    'Torque Tower Top Nacelle',
    'Torque and Stretch DT',
    'Stretch PTR',
    'Torque Hub',
    'Retorque Tower Bolts (72h)',
    'Stretch Blades',
    'Stretch Foundations',
    'Generator alignment / coupling installation',
    'Mechanical Finishing',
    'Stretch Foundations (70%)',
  ],
  'Electrical': [
    'Options installation',
    'Cables Works',
    'Alignment wind sensor / wind vane / wind transmitter',
    'Install HV Cable',
    'Install LV Cable',
    'HV Cable connection',
    'Electrical Tests',
  ],
  'Finishing_Work': [
    'Internal work',
    'Cleaning / painting',
    'Stickers',
    'Documents',
    'Customer PPE',
  ],
  'Inspection': [
    'Service lift / internal crane / ladder',
    'Check generator & trafo plate',
    'Walk Down',
    'Punch list',
    'Mechanical (Envision)',
  ],
  'Commissionning_SCADA': [
    'Start Pre Commmissioning',
    'Pré Commmissioning',
    'End Pre Commmissioning',
    'SCADA Cabinets in PDL',
    'SCADA Connection',
    'Commmissioning',
    '1st KW',
  ],
  'General_Tasks': [
    'Housekeeping',
    'Civil Works (Client various activities)',
    'Assembly multiblade installer',
    'Disassembly multiblade installer',
  ],
};

String dailyJournalCategoryLabel(String value) {
  return value.replaceAll('_', ' ').replaceAll('.', '').trim();
}

const Map<String, String> _dailyJournalCategoryLabelsPt = {
  'Crane': 'Grua',
  'Transport': 'Transporte',
  'Delivery_Main_Components': 'Entrega de Componentes Principais',
  'Preparation': 'Preparação',
  'Installation.': 'Instalação',
  'Mechanical': 'Mecânico',
  'Electrical': 'Elétrico',
  'Finishing_Work': 'Trabalhos Finais',
  'Inspection': 'Inspeção',
  'Commissionning_SCADA': 'Comissionamento / SCADA',
  'General_Tasks': 'Tarefas Gerais',
};

const Map<String, String> _dailyJournalSubcategoryLabelsPt = {
  'Assembly': 'Montagem',
  'Transfer': 'Transferência',
  'Disassembly': 'Desmontagem',
  'Inspect': 'Inspecionar',
  'Damage': 'Dano',
  'Repair': 'Reparação',
  'Return elements': 'Devolver elementos',
  'Receive elements': 'Receber elementos',
  'Delivery Office Container': 'Entrega de contentor de escritório',
  'Delivery Hand Tools Container':
      'Entrega de contentor de ferramentas manuais',
  'Delivery Lifting Tools Container':
      'Entrega de contentor de ferramentas de elevação',
  'Delivery LDST Tools Container': 'Entrega de contentor de ferramentas LDST',
  'Delivery Tools': 'Entrega de ferramentas',
  'Delivery Consumables': 'Entrega de consumíveis',
  'Return site parts': 'Devolver peças do site',
  'Return tools': 'Devolver ferramentas',
  'Return containers': 'Devolver contentores',
  'Delivery Welfare Container': 'Entrega de contentor de apoio',
  'Blades': 'Pás',
  'Hub': 'Cubo',
  'Nacelle': 'Nacele',
  'Bottom': 'Base',
  'Top': 'Topo',
  'Top Cooler': 'Refrigerador superior',
  'Switch Gear': 'Quadro elétrico',
  'Electrical Cabinets': 'Armários elétricos',
  'Tower Site Parts': 'Peças de torre do site',
  'Nacelle Site Parts': 'Peças de nacele do site',
  'Hub Site Parts': 'Peças de cubo do site',
  'DT Site Parts': 'Peças de DT do site',
  'PTR Site Parts': 'Peças de PTR do site',
  'HV Cable': 'Cabo MT',
  'LV Cable': 'Cabo BT',
  'Electrical components': 'Componentes elétricos',
  'Prep Foundation (Switchgear, tower feets, ...)':
      'Preparar fundação (switchgear, pés de torre, ...)',
  'Prep Components to Erection': 'Preparar componentes para montagem',
  'Pre installation': 'Pré-instalação',
  'Temporary AV Lights': 'Luzes AV temporárias',
  'Top Cooler on nacelle': 'Refrigerador superior na nacele',
  'Install Molly in the Nacelle': 'Instalar Molly na nacele',
  'Install Molly in PTR': 'Instalar Molly no PTR',
  'Install Wheel in the Hub': 'Instalar roda no cubo',
  'Install Molly in the Hub': 'Instalar Molly no cubo',
  'Blade A': 'Pá A',
  'Blade B': 'Pá B',
  'Blade C': 'Pá C',
  'Service Lift': 'Elevador de serviço',
  'LV cables': 'Cabos BT',
  'Cabinets': 'Armários',
  'Tower AV Lights': 'Luzes AV da torre',
  'Platform for Cabinets (Envision)': 'Plataforma para armários (Envision)',
  'Torque Tower Bolts': 'Apertar parafusos da torre',
  'Torque Tower Top Nacelle': 'Apertar topo da torre e nacele',
  'Torque and Stretch DT': 'Torque e alongamento DT',
  'Stretch PTR': 'Alongar PTR',
  'Torque Hub': 'Apertar cubo',
  'Retorque Tower Bolts (72h)': 'Reaperto dos parafusos da torre (72h)',
  'Stretch Blades': 'Alongar pás',
  'Stretch Foundations': 'Alongar fundações',
  'Generator alignment / coupling installation':
      'Alinhamento do gerador / instalação do acoplamento',
  'Mechanical Finishing': 'Acabamentos mecânicos',
  'Stretch Foundations (70%)': 'Alongar fundações (70%)',
  'Options installation': 'Instalação de opções',
  'Cables Works': 'Trabalhos de cabos',
  'Alignment wind sensor / wind vane / wind transmitter':
      'Alinhamento do sensor de vento / veleta / transmissor de vento',
  'Install HV Cable': 'Instalar cabo MT',
  'Install LV Cable': 'Instalar cabo BT',
  'HV Cable connection': 'Ligação do cabo MT',
  'Electrical Tests': 'Testes elétricos',
  'Internal work': 'Trabalho interno',
  'Cleaning / painting': 'Limpeza / pintura',
  'Stickers': 'Autocolantes',
  'Documents': 'Documentos',
  'Customer PPE': 'EPI do cliente',
  'Service lift / internal crane / ladder':
      'Elevador de serviço / grua interna / escada',
  'Check generator & trafo plate': 'Verificar placa do gerador e transformador',
  'Walk Down': 'Walk Down',
  'Punch list': 'Lista de pendentes',
  'Start Pre Commmissioning': 'Iniciar pré-comissionamento',
  'Pré Commmissioning': 'Pré-comissionamento',
  'End Pre Commmissioning': 'Concluir pré-comissionamento',
  'SCADA Cabinets in PDL': 'Armários SCADA em PDL',
  'SCADA Connection': 'Ligação SCADA',
  'Commmissioning': 'Comissionamento',
  '1st KW': '1.º kW',
  'Housekeeping': 'Arrumação e limpeza',
  'Civil Works (Client various activities)':
      'Obras civis (várias atividades do cliente)',
  'Assembly multiblade installer': 'Montagem do instalador multiblade',
  'Disassembly multiblade installer': 'Desmontagem do instalador multiblade',
};

String dailyJournalLocationLabelLocalized(String value, String localeCode) {
  if (localeCode != 'pt') {
    return value;
  }

  if (value == 'BASE COMPOUND') {
    return 'Base do estaleiro';
  }

  if (value == 'MULTIPLE PADS') {
    return 'Múltiplas plataformas';
  }

  if (value.startsWith('PAD ')) {
    return value.replaceFirst('PAD ', 'Plataforma ');
  }

  return value;
}

String dailyJournalCategoryLabelLocalized(String value, String localeCode) {
  if (localeCode != 'pt') {
    return dailyJournalCategoryLabel(value);
  }

  return _dailyJournalCategoryLabelsPt[value] ??
      dailyJournalCategoryLabel(value);
}

String dailyJournalSubcategoryLabelLocalized(
  String value,
  String localeCode,
) {
  if (localeCode != 'pt') {
    return value;
  }

  return _dailyJournalSubcategoryLabelsPt[value] ?? value;
}
