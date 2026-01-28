// lib/i18n/installation_translations.dart

class InstallationTranslations {
  static const Map<String, Map<String, String>> translations = {
    // ────── TIPOS DE FASE ──────
    'reception': {
      'pt': 'Receção',
      'en': 'Reception',
    },
    'preparation': {
      'pt': 'Preparação',
      'en': 'Preparation',
    },
    'preInstallation': {
      'pt': 'Pré-Instalação',
      'en': 'Pre-Installation',
    },
    'installation': {
      'pt': 'Instalação',
      'en': 'Installation',
    },
    'electricalWorks': {
      'pt': 'Trabalhos Elétricos',
      'en': 'Electrical Works',
    },
    'mechanicalWorks': {
      'pt': 'Trabalhos Mecânicos',
      'en': 'Mechanical Works',
    },
    'finish': {
      'pt': 'Limpeza e Pintura',
      'en': 'Cleaning and Painting',
    },
    'supervisorInspection': {
      'pt': 'Inspeção Supervisor',
      'en': 'Supervisor Inspection',
    },
    'punchlist': {
      'pt': 'Punch-List',
      'en': 'Punch-List',
    },
    'clientInspection': {
      'pt': 'Inspeção Cliente',
      'en': 'Client Inspection',
    },
    'clientPunchlist': {
      'pt': 'Punch-List Cliente',
      'en': 'Client Punch-List',
    },

    // ────── TRABALHOS MECÂNICOS ──────
    'torque': {
      'pt': 'Torque',
      'en': 'Torque',
    },
    'tensioning': {
      'pt': 'Tensionamento',
      'en': 'Tensioning',
    },

    // ────── STATUS ──────
    'pending': {
      'pt': 'Pendente',
      'en': 'Pending',
    },
    'inProgress': {
      'pt': 'Em Curso',
      'en': 'In Progress',
    },
    'complete': {
      'pt': 'Completo',
      'en': 'Complete',
    },
    'na': {
      'pt': 'N/A',
      'en': 'N/A',
    },

    // ────── CAMPOS ──────
    'startDate': {
      'pt': 'Data Início',
      'en': 'Start Date',
    },
    'endDate': {
      'pt': 'Data Fim',
      'en': 'End Date',
    },
    'receptionTime': {
      'pt': 'Hora Receção',
      'en': 'Reception Time',
    },
    'startTime': {
      'pt': 'Hora Início',
      'en': 'Start Time',
    },
    'endTime': {
      'pt': 'Hora Fim',
      'en': 'End Time',
    },
    'photos': {
      'pt': 'Fotos',
      'en': 'Photos',
    },
    'observations': {
      'pt': 'Observações',
      'en': 'Observations',
    },
    'position': {
      'pt': 'Posição',
      'en': 'Position',
    },

    // ────── LIGAÇÕES ──────
    'foundation_bottom': {
      'pt': 'Fundação/Bottom',
      'en': 'Foundation/Bottom',
    },
    'bottom_middle1': {
      'pt': 'Bottom/Middle 1',
      'en': 'Bottom/Middle 1',
    },
    'middle1_middle2': {
      'pt': 'Middle 1/Middle 2',
      'en': 'Middle 1/Middle 2',
    },
    'middle2_top': {
      'pt': 'Middle 2/Top',
      'en': 'Middle 2/Top',
    },
    'top_nozzle': {
      'pt': 'Top/Nozzle',
      'en': 'Top/Nozzle',
    },
    'nozzle_flange': {
      'pt': 'Nozzle/Flange',
      'en': 'Nozzle/Flange',
    },

    // 🆕 ────── CAMPOS DO DIALOG (NOVOS) ──────
    'progresso': {
      'pt': 'Progresso',
      'en': 'Progress',
    },
    'guardar': {
      'pt': 'Guardar',
      'en': 'Save',
    },
    'cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'dataInicio': {
      'pt': 'Data Início',
      'en': 'Start Date',
    },
    'dataFim': {
      'pt': 'Data Fim',
      'en': 'End Date',
    },
    'hora': {
      'pt': 'Hora',
      'en': 'Time',
    },
    'horaInicio': {
      'pt': 'Hora Início',
      'en': 'Start Time',
    },
    'horaFim': {
      'pt': 'Hora Fim',
      'en': 'End Time',
    },
    'fotos': {
      'pt': 'Fotos',
      'en': 'Photos',
    },
    'observacoesOpcionais': {
      'pt': 'Observações opcionais...',
      'en': 'Optional notes...',
    },
    'posicaoBlade': {
      'pt': 'Posição Blade',
      'en': 'Blade Position',
    },
    'readonly': {
      'pt': 'readonly',
      'en': 'readonly',
    },
    'serial': {
      'pt': 'Serial',
      'en': 'Serial',
    },
    'item': {
      'pt': 'Item',
      'en': 'Item',
    },
    'naoAplicavel': {
      'pt': 'Não Aplicável (N/A)',
      'en': 'Not Applicable (N/A)',
    },
    'faseNaoAplicavel': {
      'pt': 'Esta fase não é aplicável',
      'en': 'This phase is not applicable',
    },
    'motivoNA': {
      'pt': 'Motivo N/A',
      'en': 'N/A Reason',
    },
    'indiqueMotivoNA': {
      'pt': 'Indique o motivo...',
      'en': 'Enter reason...',
    },
    'motivoObrigatorio': {
      'pt': 'Motivo obrigatório',
      'en': 'Reason required',
    },
    'adicionar': {
      'pt': 'Adicionar',
      'en': 'Add',
    },
    'nenhumaFoto': {
      'pt': 'Nenhuma foto adicionada',
      'en': 'No photos added',
    },
  };

  static String getString(String key, String locale) {
    final translation = translations[key]?[locale];
    return translation ?? key; // ✅ SEMPRE retorna String, nunca null
  }

// ============================================================================
// 🇵🇹 PORTUGUÊS (pt.dart)
// ============================================================================
  static const Map<String, String> ptTranslations = {
// Módulos
    'as_built': 'As-Built',
    'installation': 'Instalação',
    'installation_module': 'Módulo de Instalação',

    // Navegação
    'dashboard': 'Dashboard',
    'new_project': 'Novo Projeto',
    'reports': 'Relatórios',
    'team': 'Equipe',
    'settings': 'Configurações',
    'help': 'Ajuda',
    'logout': 'Sair',

    // Abas do Módulo de Instalação
    'schedule': 'Cronograma',
    'teams': 'Equipes',
    'materials': 'Materiais',
    'quality_control': 'Controle de Qualidade',

    // Status de Instalação
    'in_progress': 'Em Progresso',
    'scheduled': 'Agendado',
    'completed': 'Concluído',
    'active': 'Ativo',
    'standby': 'Standby',

    // Materiais
    'in_stock': 'Em Estoque',
    'low_stock': 'Estoque Baixo',
    'out_of_stock': 'Fora de Estoque',

    // Qualidade
    'approved': 'Aprovado',
    'pending': 'Pendente',
    'rejected': 'Reprovado',
    'inspector': 'Inspetor',
    'inspection_date': 'Data de Inspeção',
    'notes': 'Observações',

    // Mensagens
    'coming_soon': 'Em Breve',
    'coming_soon_message':
        'Esta funcionalidade está em desenvolvimento e estará disponível em breve!',
    'confirm_logout': 'Confirmar Logout',
    'confirm_logout_message': 'Tem certeza que deseja sair?',
    'cancel': 'Cancelar',

    // Ajuda
    'help_center': 'Central de Ajuda',
    'email': 'Email',
    'phone': 'Telefone',
    'documentation': 'Documentação',
    'close': 'Fechar',

    // ────────────────────────────────────────────────────────────────────────
    // 🏗️ FASES DA INSTALAÇÃO (11 FASES COMPLETAS)
    // ────────────────────────────────────────────────────────────────────────
    'reception': 'Receção',
    'preparation': 'Preparação',
    'preInstallation': 'Pré-Instalação',
    'electricalWorks': 'Trabalhos Elétricos',
    'mechanicalWorks': 'Trabalhos Mecânicos',
    'finish': 'Limpeza e Pintura',
    'supervisorInspection': 'Inspeção Supervisor',
    'punchlist': 'Punch-List',
    'clientInspection': 'Inspeção Cliente',
    'clientPunchlist': 'Punch-List Cliente',

    // ────────────────────────────────────────────────────────────────────────
    // 📊 STATUS DAS FASES
    // ────────────────────────────────────────────────────────────────────────
    'inProgress': 'Em Curso',
    'complete': 'Completo',
    'na': 'N/A',

    // ────────────────────────────────────────────────────────────────────────
    // 🔧 TRABALHOS MECÂNICOS (Sub-categorias)
    // ────────────────────────────────────────────────────────────────────────
    'torque': 'Torque',
    'tensioning': 'Tensionamento',

    // ────────────────────────────────────────────────────────────────────────
    // 📅 CAMPOS E ATRIBUTOS
    // ────────────────────────────────────────────────────────────────────────
    'startDate': 'Data Início',
    'endDate': 'Data Fim',
    'receptionTime': 'Hora Receção',
    'startTime': 'Hora Início',
    'endTime': 'Hora Fim',
    'photos': 'Fotos',
    'observations': 'Observações',
    'position': 'Posição',

    // ────────────────────────────────────────────────────────────────────────
    // 🔗 LIGAÇÕES (CONEXÕES DA TORRE)
    // ────────────────────────────────────────────────────────────────────────
    'foundation_bottom': 'Fundação/Bottom',
    'bottom_middle1': 'Bottom/Middle 1',
    'middle1_middle2': 'Middle 1/Middle 2',
    'middle2_middle3': 'Middle 2/Middle 3',
    'middle3_top': 'Middle 3/Top',
    'top_yaw': 'Top/Yaw Ring',

    // ────────────────────────────────────────────────────────────────────────
    // 🏗️ FASES
    // ────────────────────────────────────────────────────────────────────────
    'final_phases': 'Fases Finais',
    'pre_assembly': 'Pré-Montagem',
    'assembly': 'Montagem',

    // ────────────────────────────────────────────────────────────────────────
    // 🔧 COMPONENTES
    // ────────────────────────────────────────────────────────────────────────
    'spare_parts': 'Spare Parts',
    'bodies_parts': 'Bodies Parts',
    'mv_cable': 'MV Cable',
    'swg': 'SWG',
    'top_cooler': 'Top Cooler',
    'tower_bottom': 'Bottom',
    'tower_middle': 'Middle',
    'tower_top': 'Top',
    'nacelle': 'Nacelle',
    'drive_train': 'Drive Train',
    'hub': 'Hub',
    'blade': 'Blade',

    // ────────────────────────────────────────────────────────────────────────
    // 📝 CAMPOS
    // ────────────────────────────────────────────────────────────────────────
    'vui_unit_id': 'VUI / ID da Unidade',
    'item_number': 'Número do Item',
    'serial_number': 'Número de Série',
    'add_photo': 'Adicionar Foto',
    'optional': 'opcional',
    'item_name': 'Nome do Item',
    'add': 'Adicionar',
    'adicionar': 'Adicionar',
    'add_notes_optional': 'Adicionar observações (opcional)...',
    'no_notes': 'Sem observações',
    'no_photos': 'Sem fotos',
    'nenhumaFoto': 'Nenhuma foto adicionada',

    // ────────────────────────────────────────────────────────────────────────
    // 📝 CAMPOS E AÇÕES - DIALOG
    // ────────────────────────────────────────────────────────────────────────
    'guardar': 'Guardar',
    'cancelar': 'Cancelar',
    'limpar_campos': 'Limpar Campos',
    'limpar': 'Limpar',
    'limpar_e_guardar': 'Limpar e Guardar',
    'confirm_limpar': 'Limpar Campos',
    'confirm_limpar_message':
        'Tem certeza que deseja limpar todos os campos?\n\nOs dados preenchidos serão apagados permanentemente.',
    'campos_limpos_sucesso': 'Campos limpos com sucesso',
    'erro_limpar_campos': 'Erro ao limpar campos',

    // Ações
    'mark_as_na': 'Marcar como N/A',
    'naoAplicavel': 'Não Aplicável (N/A)',
    'faseNaoAplicavel': 'Esta fase não é aplicável',
    'motivoNA': 'Motivo N/A',
    'indiqueMotivoNA': 'Indique o motivo...',
    'motivoObrigatorio': 'Motivo obrigatório',
    'mark_phase_na_confirm':
        'Tem certeza que deseja marcar como não aplicável?',
    'phase_marked_na': 'Marcado como N/A',
    'data_saved_successfully': 'Dados salvos com sucesso!',
    'save': 'Salvar',
    'confirm': 'Confirmar',

    // ────────────────────────────────────────────────────────────────────────
    // 📊 INFO
    // ────────────────────────────────────────────────────────────────────────
    'try_adjusting_search': 'Tente ajustar a pesquisa ou filtros',
    'turbine_model': 'Modelo',
    'sequence': 'Sequência',
    'progress': 'Progresso',
    'progresso': 'Progresso',

    // ────────────────────────────────────────────────────────────────────────
    // 📊 STATUS
    // ────────────────────────────────────────────────────────────────────────
    'blocked': 'Bloqueado',
    'not_applicable': 'N/A',
    'status': 'Status',

    // ────────────────────────────────────────────────────────────────────────
    // 🔒 BLOQUEIO
    // ────────────────────────────────────────────────────────────────────────
    'block': 'Bloquear',
    'unblock': 'Desbloquear',
    'block_component': 'Bloquear Componente',
    'unblock_component': 'Desbloquear Componente',
    'block_reason_required': 'Por favor, indique o motivo do bloqueio:',
    'enter_block_reason': 'Escreva o motivo...',
    'confirm_unblock': 'Tem certeza que deseja desbloquear este componente?',
    'blocked_by': 'Bloqueado por',
    'component_blocked': 'Componente bloqueado com sucesso',
    'component_unblocked': 'Componente desbloqueado com sucesso',
    'reason_required': 'É necessário indicar o motivo',
    'reason': 'Motivo',
    'date': 'Data',
    'dataInicio': 'Data Início',
    'dataFim': 'Data Fim',
    'hora': 'Hora',
    'horaInicio': 'Hora Início',
    'horaFim': 'Hora Fim',
    'fotos': 'Fotos',
    'observacoesOpcionais': 'Observações opcionais...',
    'posicaoBlade': 'Posição Blade',
    'readonly': 'readonly',
    'serial': 'Serial',
    'item': 'Item',

    // ────────────────────────────────────────────────────────────────────────
    // 📈 PROGRESSO
    // ────────────────────────────────────────────────────────────────────────
    'mark_if_not_installed': 'Marque se este componente não existe neste site',

    // ────────────────────────────────────────────────────────────────────────
    // 🔬 COMISSIONAMENTO - FASES PRINCIPAIS
    // ────────────────────────────────────────────────────────────────────────
    'commissioning': 'Comissionamento',
    'pre_commissioning_tests': 'Testes Pré-Comissionamento',
    'final_acceptance': 'Aceitação Final',

    // ────────────────────────────────────────────────────────────────────────
    // 🔬 COMISSIONAMENTO - SUB-FASES
    // ────────────────────────────────────────────────────────────────────────
    'electrical_tests': 'Testes Elétricos',
    'mechanical_tests': 'Testes Mecânicos',
    'safety_tests': 'Testes de Segurança',
    'cold_commissioning': 'Comissionamento a Frio',
    'hot_commissioning': 'Comissionamento a Quente',
    'performance_tests': 'Testes de Performance',
    'customer_acceptance': 'Aceitação do Cliente',
    'handover': 'Entrega',

    // ────────────────────────────────────────────────────────────────────────
    // 📋 CAMPOS COMUNS
    // ────────────────────────────────────────────────────────────────────────
    'responsible': 'Responsável',
    'enter_responsible_name': 'Nome do responsável',

    // ────────────────────────────────────────────────────────────────────────
    // 🎯 AÇÕES
    // ────────────────────────────────────────────────────────────────────────
    'replace': 'Substituir',
    'loading_turbines': 'A carregar turbinas...',
    'error_loading_turbines': 'Erro ao carregar turbinas',
    'no_turbines_created': 'Nenhuma turbina criada',
    'create_turbines_in_asbuilt': 'Crie turbinas no módulo As-Built primeiro',
    'retry': 'Tentar novamente',
    'syncing_from_installation': 'Sincronizando da Instalação...',

    // ────────────────────────────────────────────────────────────────────────
    // 🎯 AS-BUILT DIALOG - PORTUGUÊS
    // ────────────────────────────────────────────────────────────────────────
    'component_status_Pendente': 'Pendente',
    'component_status_Em Progresso': 'Em Progresso',
    'component_status_Concluído': 'Concluído',
    'component_status_Bloqueado': 'Bloqueado',
    'component_status_N/A': 'N/A',
    'component_not_used': 'Este componente não é utilizado',
    'component_updated_success': 'Componente atualizado com sucesso!',
    'error': 'Erro',
    'replace_component': 'Substituir Componente',
    'component_to_replace': 'Componente a substituir',
    'reason_for_replacement': 'Motivo da substituição',
    'justification': 'Justificação',
    'explain_replacement': 'Explique o motivo da substituição...',
    'replacement_warning':
        'Atenção: Esta ação criará um novo componente e marcará o atual como substituído.',
    'damage': 'Dano',
    'defect': 'Defeito',
    'failure': 'Avaria',
    'age_obsolescence': 'Antiguidade',
    'other': 'Outro',
    'justification_required': 'Justificação é obrigatória',
    'component_replaced_success': 'Componente substituído com sucesso',

    // 🆕 NOVOS COMPONENTES - ELECTRICAL SYSTEMS
    'transformador': 'Transformador',
    'gerador': 'Gerador',
    'ground_control': 'Ground Control',
    'light_control': 'Light Control',
    'light_battery': 'Light Battery',
    'ups': 'UPS',

    // 🆕 NOVOS COMPONENTES - MECHANICAL SYSTEMS
    'gearbox': 'Gearbox',
    'coupling': 'Coupling',
    'service_lift': 'Service Lift',
    'lift_cables': 'Lift Cables',

    // 🆕 NOVOS COMPONENTES - AUXILIARY SYSTEMS
    'resq': 'ResQ',
    'aviation_light_1': 'Aviation Light 1',
    'aviation_light_2': 'Aviation Light 2 (Opcional)',
    'grua_interna': 'Grua Interna',
    'cms': 'CMS',

    // 🆕 NOVOS COMPONENTES - CIVIL WORKS
    'anchor_bolts': 'Anchor Bolts',

    // ═══════════════════════════════════════════════════════════════════════════
    // TRADUÇÕES PORTUGUÊS - TORQUE & TENSIONING
    // ═══════════════════════════════════════════════════════════════════════════

    // ══════════════════════════════════════════════════════════════════════════
    // GERAL
    // ══════════════════════════════════════════════════════════════════════════
    'torqueTensioning': 'Torque & Tensionamento',
    'torqueTensioningShort': 'Torque & Tensão',
    'conexao': 'Conexão',
    'conexoes': 'Conexões',
    'conexaoExtra': 'Conexão Extra',
    'conexoesExtras': 'Conexões Extras',
    'conexaoStandard': 'Conexão Standard',
    'conexoesStandard': 'Conexões Standard',

    // ══════════════════════════════════════════════════════════════════════════
    // STATUS
    // ══════════════════════════════════════════════════════════════════════════
    'pendente': 'Pendente',
    'emProgresso': 'Em Progresso',
    'concluido': 'Concluído',
    'completo': 'Completo',
    'incompleto': 'Incompleto',
    'progressoMedio': 'Progresso Médio',

    // ══════════════════════════════════════════════════════════════════════════
    // CATEGORIAS
    // ══════════════════════════════════════════════════════════════════════════
    'civilWorks': 'Civil Works',
    'torre': 'Torre',
    'rotor': 'Rotor',
    'outro': 'Outro',
    'categoria': 'Categoria',
    'categorias': 'Categorias',

    // ══════════════════════════════════════════════════════════════════════════
    // COMPONENTES
    // ══════════════════════════════════════════════════════════════════════════
    'fundacao': 'Fundação',
    'bottom': 'Bottom',
    'middle': 'Middle',
    'top': 'Top',
    'bladeA': 'Blade A',
    'bladeB': 'Blade B',
    'bladeC': 'Blade C',
    'driveTrain': 'Drive Train',
    'componenteOrigem': 'Componente Origem',
    'componenteDestino': 'Componente Destino',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 1: DADOS TÉCNICOS
    // ══════════════════════════════════════════════════════════════════════════
    'dadosTecnicos': 'Dados Técnicos',
    'tensionamento': 'Tensionamento',
    'tensao': 'Tensão',
    'valor': 'Valor',
    'unidade': 'Unidade',
    'especificacoes': 'Especificações',
    'especificacoesParafusos': 'Especificações dos Parafusos',
    'metrica': 'Métrica',
    'quantidade': 'Quantidade',
    'tipo': 'Tipo',
    'tipoParafuso': 'Tipo de Parafuso',

    // Unidades Torque
    'nm': 'Nm',
    'knm': 'kNm',
    'ftlb': 'ft-lb',

    // Unidades Tensionamento
    'kn': 'kN',
    'lbf': 'lbf',
    'mpa': 'MPa',

    // Tipos de Parafuso
    'stud': 'Stud',
    'bolt': 'Bolt',
    'hexBolt': 'Hex Bolt',
    'screw': 'Screw',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 2: RASTREABILIDADE PARAFUSOS
    // ══════════════════════════════════════════════════════════════════════════
    'rastreabilidade': 'Rastreabilidade',
    'rastreabilidadeParafusos': 'Rastreabilidade dos Parafusos',
    'batch': 'Batch / Lote',
    'lote': 'Lote',
    'vui': 'VUI',
    'serialNumber': 'Serial Number',
    'numeroSerie': 'Número de Série',
    'itemNumber': 'Item Number',
    'partNumber': 'Part Number',
    'numeroPeca': 'Número de Peça',

    // Helpers
    'loteFabricacao': 'Lote de fabricação dos parafusos',
    'codigoVUI': 'Código VUI dos parafusos',
    'serialParafusos': 'Número de série dos parafusos',
    'partNumberParafusos': 'Número de peça dos parafusos',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 3: EQUIPAMENTO
    // ══════════════════════════════════════════════════════════════════════════
    'equipamento': 'Equipamento',
    'equipamentos': 'Equipamentos',
    'chaveTorque': 'Chave de Torque',
    'equipamentoTensionamento': 'Equipamento de Tensionamento',
    'idEquipamento': 'ID do Equipamento',
    'dataCalibracao': 'Data de Calibração',
    'ultimaCalibracao': 'Data da última calibração',
    'calibracaoValida': 'Calibração válida até',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 4: PROCEDIMENTOS & QUALIDADE
    // ══════════════════════════════════════════════════════════════════════════
    'procedimentos': 'Procedimentos',
    'qualidade': 'Qualidade',
    'procedimentosQualidade': 'Procedimentos & Qualidade',
    'workInstruction': 'Work Instruction',
    'numeroWI': 'Work Instruction Number',
    'numeroInstrucao': 'Número da instrução de trabalho',
    'qualityCheck': 'Quality Check',
    'numeroQC': 'Quality Check / ITP Number',
    'numeroControlo': 'Número do controlo de qualidade',
    'inspetor': 'Inspetor',
    'nomeInspetor': 'Nome do Inspetor',
    'nomeCertificacao': 'Nome e certificação do inspetor',
    'assinatura': 'Assinatura',
    'assinaturaDigital': 'Assinatura Digital',
    'assinar': 'Assinar Digitalmente',
    'verAssinatura': 'Ver Assinatura',
    'assinadoEm': 'Assinado em',
    'assinaturaEmDesenvolvimento': 'Assinatura digital em desenvolvimento',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 5: CONDIÇÕES AMBIENTAIS
    // ══════════════════════════════════════════════════════════════════════════
    'condicoesAmbientais': 'Condições Ambientais',
    'temperatura': 'Temperatura',
    'temperaturaCelsius': 'Temperatura (°C)',
    'humidade': 'Humidade',
    'humidadeRelativa': 'Humidade Relativa (%)',
    'condicoesMeteorologicas': 'Condições Meteorológicas',
    'condicoesMeteo': 'Condições Meteorológicas',

    // Condições Meteorológicas
    'ceuLimpo': 'Céu limpo',
    'sol': 'Sol',
    'nublado': 'Nublado',
    'chuvaLeve': 'Chuva leve',
    'chuvaForte': 'Chuva forte',
    'ventoForte': 'Vento forte',
    'neve': 'Neve',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 6: FOTOS & OBSERVAÇÕES
    // ══════════════════════════════════════════════════════════════════════════

    'fotosObservacoes': 'Fotos & Observações',
    'foto': 'Foto',
    'adicionarFoto': 'Adicionar Foto',
    'tirarFoto': 'Tirar Foto',
    'galeria': 'Galeria',
    'camara': 'Câmara',
    'camera': 'Câmara',
    'deletarFoto': 'Deletar Foto',
    'confirmarDeletarFoto': 'Tem a certeza que deseja deletar esta foto?',
    'observacoes': 'Observações',
    'notasTecnicas': 'Notas Técnicas',
    'detalhesExecucao': 'Detalhes sobre a execução',
    'maxFotos': 'Máximo 10 fotos',

    // ══════════════════════════════════════════════════════════════════════════
    // DATAS & EXECUÇÃO
    // ══════════════════════════════════════════════════════════════════════════
    'execucao': 'Execução',
    'executadoPor': 'Executado por',
    'selecionarData': 'Selecionar data',

    // ══════════════════════════════════════════════════════════════════════════
    // ACTIONS
    // ══════════════════════════════════════════════════════════════════════════

    'adicionarConexaoExtra': 'Adicionar Conexão Extra',
    'novaConexaoExtra': 'Nova Conexão Extra',
    'adicionarConexaoCustomizada': 'Adicione uma conexão customizada',
    'editar': 'Editar',
    'aGuardar': 'A guardar...',
    'deletar': 'Deletar',
    'confirmar': 'Confirmar',
    'criar': 'Criar',
    'aCriar': 'A criar...',
    'voltar': 'Voltar',
    'fechar': 'Fechar',

    // ══════════════════════════════════════════════════════════════════════════
    // DIALOGS & CONFIRMAÇÕES
    // ══════════════════════════════════════════════════════════════════════════
    'deletarConexaoExtra': 'Deletar Conexão Extra',
    'confirmarDeletarConexao': 'Tem a certeza que deseja deletar a conexão',
    'acaoNaoPodeSerDesfeita': 'Esta ação não pode ser desfeita.',
    'conexaoNaoPodeSerDeletada': 'Conexões standard não podem ser deletadas',
    'conexoesExtrasPodeDeletar':
        'Conexões extras podem ser deletadas a qualquer momento',

    // ══════════════════════════════════════════════════════════════════════════
    // MENSAGENS DE SUCESSO
    // ══════════════════════════════════════════════════════════════════════════
    'conexaoCriada': 'Conexão criada!',
    'conexaoAtualizada': 'Conexão atualizada com sucesso!',
    'conexaoDeletada': 'Conexão deletada',
    'fotoAdicionada': 'Foto adicionada',
    'fotoDeletada': 'Foto deletada',
    'dadosGuardados': 'Dados guardados com sucesso!',

    // ══════════════════════════════════════════════════════════════════════════
    // MENSAGENS DE ERRO
    // ══════════════════════════════════════════════════════════════════════════
    'erroCarregarConexoes': 'Erro ao carregar conexões',
    'erroCriarConexao': 'Erro ao criar conexão',
    'erroAtualizarConexao': 'Erro ao atualizar conexão',
    'erroDeletarConexao': 'Erro ao deletar conexão',
    'erroAdicionarFoto': 'Erro ao adicionar foto',
    'erroDeletarFoto': 'Erro ao deletar foto',
    'erroGuardar': 'Erro ao guardar',
    'utilizadorNaoAutenticado': 'Utilizador não autenticado',

    // ══════════════════════════════════════════════════════════════════════════
    // VALIDAÇÕES
    // ══════════════════════════════════════════════════════════════════════════
    'campoObrigatorio': 'Campo obrigatório',
    'valorInvalido': 'Valor inválido',
    'numeroInvalido': 'Número inválido',

    // ══════════════════════════════════════════════════════════════════════════
    // PLACEHOLDERS & HINTS
    // ══════════════════════════════════════════════════════════════════════════
    'exemploTorque': '1200',
    'exemploTensionamento': '850',
    'exemploMetrica': 'M36, M42, 2 inch',
    'exemploQuantidade': '72',
    'exemploBatch': 'BATCH-2024-A-001',
    'exemploVUI': 'VUI-M36-12345',
    'exemploSerial': 'SN-BOLT-98765-2024',
    'exemploPartNumber': 'PN-M36X120-HEX-STUD',
    'exemploEquipamentoId': 'TORQUE-WRENCH-005',
    'exemploEquipamentoSerial': 'SN-TW-2023-0456',
    'exemploWI': 'WI-TOWER-BOLTING-001-Rev3',
    'exemploQC': 'QC-WTG01-TOWER-20260124-001',
    'exemploInspetor': 'João Silva - Cert. QC-Level-2',
    'exemploTemperatura': '18.5',
    'exemploHumidade': '65',
    'exemploObservacoes': 'Torque aplicado em 3 passes conforme WI-001...',
    'exemploComponenteOrigem': 'Platform, Transformer',
    'exemploComponenteDestino': 'Tower Bottom, Nacelle Base',
    'exemploDescricao': 'Plataforma de acesso ao bottom',

    // ══════════════════════════════════════════════════════════════════════════
    // DESCRIÇÕES & HELPERS
    // ══════════════════════════════════════════════════════════════════════════
    'deOndeParteConexao': 'De onde parte a conexão',
    'paraOndeVaiConexao': 'Para onde vai a conexão',
    'agrupaConexoesSimilares': 'Agrupa conexões similares',
    'detalhesSobreConexao': 'Detalhes sobre esta conexão',

    // ══════════════════════════════════════════════════════════════════════════
    // ESTATÍSTICAS
    // ══════════════════════════════════════════════════════════════════════════
    'total': 'Total',
    'completas': 'Completas',
    'pendentes': 'Pendentes',
    'estatisticas': 'Estatísticas',

    // ══════════════════════════════════════════════════════════════════════════
    // ESTADOS VAZIOS
    // ══════════════════════════════════════════════════════════════════════════
    'nenhumaConexao': 'Nenhuma conexão',
    'nenhumaConexaoCategoria': 'Nenhuma conexão nesta categoria',

    // ══════════════════════════════════════════════════════════════════════════
    // OUTROS
    // ══════════════════════════════════════════════════════════════════════════
    'descricao': 'Descrição',
    'opcional': 'Opcional',
    'obrigatorio': 'Obrigatório',
    'carregando': 'A carregar...',
    'erro': 'Erro',
    'sucesso': 'Sucesso',
    'atencao': 'Atenção',
    'informacao': 'Informação',
    'componentes': 'Componentes',
    'timeline_view': 'Cronograma',
    'timeline': 'Cronograma',
  };

// ============================================================================
// 🇬🇧 INGLÊS (en.dart)
// ============================================================================
  static const Map<String, String> enTranslations = {
    // Modules
    'as_built': 'As-Built',
    'installation': 'Installation',
    'installation_module': 'Installation Module',

    // Navigation
    'dashboard': 'Dashboard',
    'new_project': 'New Project',
    'reports': 'Reports',
    'team': 'Team',
    'settings': 'Settings',
    'help': 'Help',
    'logout': 'Logout',

    // Installation Module Tabs
    'schedule': 'Schedule',
    'teams': 'Teams',
    'materials': 'Materials',
    'quality_control': 'Quality Control',

    // Installation Status
    'in_progress': 'In Progress',
    'scheduled': 'Scheduled',
    'completed': 'Completed',
    'active': 'Active',
    'standby': 'Standby',

    // Materials
    'in_stock': 'In Stock',
    'low_stock': 'Low Stock',
    'out_of_stock': 'Out of Stock',

    // Quality
    'approved': 'Approved',
    'pending': 'Pending',
    'rejected': 'Rejected',
    'inspector': 'Inspector',
    'inspection_date': 'Inspection Date',
    'notes': 'Notes',

    // Messages
    'coming_soon': 'Coming Soon',
    'coming_soon_message':
        'This feature is under development and will be available soon!',
    'confirm_logout': 'Confirm Logout',
    'confirm_logout_message': 'Are you sure you want to logout?',
    'cancel': 'Cancel',

    // Help
    'help_center': 'Help Center',
    'email': 'Email',
    'phone': 'Phone',
    'documentation': 'Documentation',
    'close': 'Close',

    // ────────────────────────────────────────────────────────────────────────
    // 🏗️ INSTALLATION PHASES (11 COMPLETE PHASES)
    // ────────────────────────────────────────────────────────────────────────
    'reception': 'Reception',
    'preparation': 'Preparation',
    'preInstallation': 'Pre-Installation',
    'electricalWorks': 'Electrical Works',
    'mechanicalWorks': 'Mechanical Works',
    'finish': 'Cleaning and Painting',
    'supervisorInspection': 'Supervisor Inspection',
    'punchlist': 'Punch-List',
    'clientInspection': 'Client Inspection',
    'clientPunchlist': 'Client Punch-List',
    'pre_assembly': 'Pre-Assembly',
    'assembly': 'Assembly',
    'final_phases': 'Final Phases',

    // ────────────────────────────────────────────────────────────────────────
    // 📊 PHASE STATUS
    // ────────────────────────────────────────────────────────────────────────
    'inProgress': 'In Progress',
    'complete': 'Complete',
    'na': 'N/A',

    // ────────────────────────────────────────────────────────────────────────
    // 🔧 COMPONENTS
    // ────────────────────────────────────────────────────────────────────────
    'spare_parts': 'Spare Parts',
    'bodies_parts': 'Bodies Parts',
    'mv_cable': 'MV Cable',
    'swg': 'SWG',
    'top_cooler': 'Top Cooler',
    'tower_bottom': 'Bottom',
    'tower_middle': 'Middle',
    'tower_top': 'Top',
    'nacelle': 'Nacelle',
    'drive_train': 'Drive Train',
    'hub': 'Hub',
    'blade': 'Blade',

    // ────────────────────────────────────────────────────────────────────────
    // 🔧 MECHANICAL WORKS (Sub-categories)
    // ────────────────────────────────────────────────────────────────────────
    'torque': 'Torque',
    'tensioning': 'Tensioning',

    // ────────────────────────────────────────────────────────────────────────
    // 📅 FIELDS AND ATTRIBUTES
    // ────────────────────────────────────────────────────────────────────────
    'startDate': 'Start Date',
    'endDate': 'End Date',
    'receptionTime': 'Reception Time',
    'startTime': 'Start Time',
    'endTime': 'End Time',
    'photos': 'Photos',
    'observations': 'Observations',
    'position': 'Position',

    // ────────────────────────────────────────────────────────────────────────
    // 🔗 CONNECTIONS (TOWER CONNECTIONS)
    // ────────────────────────────────────────────────────────────────────────
    'foundation_bottom': 'Foundation/Bottom',
    'bottom_middle1': 'Bottom/Middle 1',
    'middle1_middle2': 'Middle 1/Middle 2',
    'middle2_middle3': 'Middle 2/Middle 3',
    'middle3_top': 'Middle 3/Top',
    'top_yaw': 'Top/Yaw Ring',

    // ────────────────────────────────────────────────────────────────────────
    // 📝 FIELDS
    // ────────────────────────────────────────────────────────────────────────
    'vui_unit_id': 'VUI / Unit ID',
    'item_number': 'Item Number',
    'serial_number': 'Serial Number',
    'add_photo': 'Add Photo',
    'optional': 'optional',
    'item_name': 'Item Name',
    'add': 'Add',
    'adicionar': 'Add',
    'add_notes_optional': 'Add notes (optional)...',
    'no_notes': 'No notes',
    'no_photos': 'No photos',
    'nenhumaFoto': 'No photos added',

    // ────────────────────────────────────────────────────────────────────────
    // 📝 FIELDS AND ACTIONS - DIALOG
    // ────────────────────────────────────────────────────────────────────────
    'guardar': 'Save',
    'cancelar': 'Cancel',
    'limpar_campos': 'Clear Fields',
    'limpar': 'Clear',
    'limpar_e_guardar': 'Clear and Save',
    'confirm_limpar': 'Clear Fields',
    'confirm_limpar_message':
        'Are you sure you want to clear all fields?\n\nThe filled data will be permanently deleted.',
    'campos_limpos_sucesso': 'Fields cleared successfully',
    'erro_limpar_campos': 'Error clearing fields',

    // ────────────────────────────────────────────────────────────────────────
    // 🎯 ACTIONS
    // ────────────────────────────────────────────────────────────────────────
    'mark_as_na': 'Mark as N/A',
    'naoAplicavel': 'Not Applicable (N/A)',
    'faseNaoAplicavel': 'This phase is not applicable',
    'motivoNA': 'N/A Reason',
    'indiqueMotivoNA': 'Enter reason...',
    'motivoObrigatorio': 'Reason required',
    'mark_phase_na_confirm':
        'Are you sure you want to mark this phase as not applicable?',
    'phase_marked_na': 'Phase marked as N/A',
    'data_saved_successfully': 'Data saved successfully!',

    // ────────────────────────────────────────────────────────────────────────
    // 📊 INFO
    // ────────────────────────────────────────────────────────────────────────
    'turbine_model': 'Model',
    'sequence': 'Sequence',
    'progress': 'Progress',
    'progresso': 'Progress',
    'try_adjusting_search': 'Try adjusting your search or filters',

    // ────────────────────────────────────────────────────────────────────────
    // 📊 STATUS
    // ────────────────────────────────────────────────────────────────────────
    'blocked': 'Blocked',
    'not_applicable': 'N/A',
    'status': 'Status',

    // ────────────────────────────────────────────────────────────────────────
    // 🔒 BLOCKING
    // ────────────────────────────────────────────────────────────────────────
    'block': 'Block',
    'unblock': 'Unblock',
    'block_component': 'Block Component',
    'unblock_component': 'Unblock Component',
    'block_reason_required': 'Please provide a reason for blocking:',
    'enter_block_reason': 'Enter reason...',
    'confirm_unblock': 'Are you sure you want to unblock this component?',
    'blocked_by': 'Blocked by',
    'component_blocked': 'Component blocked successfully',
    'component_unblocked': 'Component unblocked successfully',
    'reason_required': 'Reason is required',
    'reason': 'Reason',
    'date': 'Date',
    'dataInicio': 'Start Date',
    'dataFim': 'End Date',
    'hora': 'Time',
    'horaInicio': 'Start Time',
    'horaFim': 'End Time',
    'fotos': 'Photos',
    'observacoesOpcionais': 'Optional notes...',
    'posicaoBlade': 'Blade Position',
    'readonly': 'readonly',
    'serial': 'Serial',
    'item': 'Item',

    // ────────────────────────────────────────────────────────────────────────
    // 📈 PROGRESS
    // ────────────────────────────────────────────────────────────────────────
    'mark_if_not_installed':
        'Check if this component does not exist on this site',

    // ────────────────────────────────────────────────────────────────────────
    // 🔬 COMMISSIONING - MAIN PHASES
    // ────────────────────────────────────────────────────────────────────────
    'commissioning': 'Commissioning',
    'pre_commissioning_tests': 'Pre-Commissioning Tests',
    'final_acceptance': 'Final Acceptance',

    // ────────────────────────────────────────────────────────────────────────
    // 🔬 COMMISSIONING - SUB-PHASES
    // ────────────────────────────────────────────────────────────────────────
    'electrical_tests': 'Electrical Tests',
    'mechanical_tests': 'Mechanical Tests',
    'safety_tests': 'Safety Tests',
    'cold_commissioning': 'Cold Commissioning',
    'hot_commissioning': 'Hot Commissioning',
    'performance_tests': 'Performance Tests',
    'customer_acceptance': 'Customer Acceptance',
    'handover': 'Handover',

    // ────────────────────────────────────────────────────────────────────────
    // 📋 COMMON FIELDS
    // ────────────────────────────────────────────────────────────────────────
    'responsible': 'Responsible',
    'enter_responsible_name': 'Responsible name',

    // ────────────────────────────────────────────────────────────────────────
    // 🎯 ACTIONS
    // ────────────────────────────────────────────────────────────────────────
    'replace': 'Replace',
    'save': 'Save',
    'confirm': 'Confirm',
    'loading_turbines': 'Loading turbines...',
    'error_loading_turbines': 'Error loading turbines',
    'no_turbines_created': 'No turbines created',
    'create_turbines_in_asbuilt': 'Create turbines in As-Built module first',
    'retry': 'Retry',
    'syncing_from_installation': 'Syncing from Installation...',

    // ────────────────────────────────────────────────────────────────────────
    // 🎯 AS-BUILT DIALOG - ENGLISH
    // ────────────────────────────────────────────────────────────────────────
    'component_status_Pendente': 'Pending',
    'component_status_Em Progresso': 'In Progress',
    'component_status_Concluído': 'Completed',
    'component_status_Bloqueado': 'Blocked',
    'component_status_N/A': 'N/A',
    'component_not_used': 'This component is not used',
    'component_updated_success': 'Component updated successfully!',
    'error': 'Error',
    'replace_component': 'Replace Component',
    'component_to_replace': 'Component to replace',
    'reason_for_replacement': 'Reason for replacement',
    'justification': 'Justification',
    'explain_replacement': 'Explain the reason for replacement...',
    'replacement_warning':
        'Warning: This action will create a new component and mark the current one as replaced.',
    'damage': 'Damage',
    'defect': 'Defect',
    'failure': 'Failure',
    'age_obsolescence': 'Age/Obsolescence',
    'other': 'Other',
    'justification_required': 'Justification is required',
    'component_replaced_success': 'Component replaced successfully',

    // 🆕 NEW COMPONENTS - ELECTRICAL SYSTEMS
    'transformador': 'Transformer',
    'gerador': 'Generator',
    'ground_control': 'Ground Control',
    'light_control': 'Light Control',
    'light_battery': 'Light Battery',
    'ups': 'UPS',

    // 🆕 NEW COMPONENTS - MECHANICAL SYSTEMS
    'gearbox': 'Gearbox',
    'coupling': 'Coupling',
    'service_lift': 'Service Lift',
    'lift_cables': 'Lift Cables',

    // 🆕 NEW COMPONENTS - AUXILIARY SYSTEMS
    'resq': 'ResQ',
    'aviation_light_1': 'Aviation Light 1',
    'aviation_light_2': 'Aviation Light 2 (Optional)',
    'grua_interna': 'Internal Crane',
    'cms': 'CMS',

    // 🆕 NEW COMPONENTS - CIVIL WORKS
    'anchor_bolts': 'Anchor Bolts',

    // REPORT
    'generate_report': 'Gerar Relatório',
    'report_format': 'Formato do Relatório',
    'select_phases': 'Selecionar Fases',
    'select_all': 'Selecionar Tudo',
    'clear_all': 'Limpar Tudo',
    'torqueTensioning': 'Torque & Tensionamento',
    'report_email_info': 'O relatório será enviado para o seu email',
    'generate_and_send': 'Gerar e Enviar',
    'generating': 'A gerar...',
    'report_sent_success': 'Relatório gerado e enviado com sucesso!',

    // ═══════════════════════════════════════════════════════════════════════════
    // ENGLISH TRANSLATIONS - TORQUE & TENSIONING
    // ═══════════════════════════════════════════════════════════════════════════

    // ══════════════════════════════════════════════════════════════════════════
    // GENERAL
    // ══════════════════════════════════════════════════════════════════════════
    'torqueTensioningShort': 'Torque & Tension',
    'conexao': 'Connection',
    'conexoes': 'Connections',
    'conexaoExtra': 'Extra Connection',
    'conexoesExtras': 'Extra Connections',
    'conexaoStandard': 'Standard Connection',
    'conexoesStandard': 'Standard Connections',

    // ══════════════════════════════════════════════════════════════════════════
    // STATUS
    // ══════════════════════════════════════════════════════════════════════════
    'pendente': 'Pending',
    'emProgresso': 'In Progress',
    'concluido': 'Completed',
    'completo': 'Complete',
    'incompleto': 'Incomplete',
    'progressoMedio': 'Average Progress',

    // ══════════════════════════════════════════════════════════════════════════
    // CATEGORIES
    // ══════════════════════════════════════════════════════════════════════════
    'civilWorks': 'Civil Works',
    'torre': 'Tower',
    'rotor': 'Rotor',
    'outro': 'Other',
    'categoria': 'Category',
    'categorias': 'Categories',

    // ══════════════════════════════════════════════════════════════════════════
    // COMPONENTS
    // ══════════════════════════════════════════════════════════════════════════
    'fundacao': 'Foundation',
    'bottom': 'Bottom',
    'middle': 'Middle',
    'top': 'Top',
    'bladeA': 'Blade A',
    'bladeB': 'Blade B',
    'bladeC': 'Blade C',
    'driveTrain': 'Drive Train',
    'componenteOrigem': 'Source Component',
    'componenteDestino': 'Destination Component',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 1: TECHNICAL DATA
    // ══════════════════════════════════════════════════════════════════════════
    'dadosTecnicos': 'Technical Data',
    'tensionamento': 'Tensioning',
    'tensao': 'Tension',
    'valor': 'Value',
    'unidade': 'Unit',
    'especificacoes': 'Specifications',
    'especificacoesParafusos': 'Bolt Specifications',
    'metrica': 'Metric',
    'quantidade': 'Quantity',
    'tipo': 'Type',
    'tipoParafuso': 'Bolt Type',

    // Torque Units
    'nm': 'Nm',
    'knm': 'kNm',
    'ftlb': 'ft-lb',

    // Tensioning Units
    'kn': 'kN',
    'lbf': 'lbf',
    'mpa': 'MPa',

    // Bolt Types
    'stud': 'Stud',
    'bolt': 'Bolt',
    'hexBolt': 'Hex Bolt',
    'screw': 'Screw',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 2: BOLT TRACEABILITY
    // ══════════════════════════════════════════════════════════════════════════
    'rastreabilidade': 'Traceability',
    'rastreabilidadeParafusos': 'Bolt Traceability',
    'batch': 'Batch / Lot',
    'lote': 'Lot',
    'vui': 'VUI',
    'serialNumber': 'Serial Number',
    'numeroSerie': 'Serial Number',
    'itemNumber': 'Item Number',
    'partNumber': 'Part Number',
    'numeroPeca': 'Part Number',

    // Helpers
    'loteFabricacao': 'Bolt manufacturing lot',
    'codigoVUI': 'Bolt VUI code',
    'serialParafusos': 'Bolt serial number',
    'partNumberParafusos': 'Bolt part number',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 3: EQUIPMENT
    // ══════════════════════════════════════════════════════════════════════════
    'equipamento': 'Equipment',
    'equipamentos': 'Equipment',
    'chaveTorque': 'Torque Wrench',
    'equipamentoTensionamento': 'Tensioning Equipment',
    'idEquipamento': 'Equipment ID',
    'dataCalibracao': 'Calibration Date',
    'ultimaCalibracao': 'Last calibration date',
    'calibracaoValida': 'Calibration valid until',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 4: PROCEDURES & QUALITY
    // ══════════════════════════════════════════════════════════════════════════
    'procedimentos': 'Procedures',
    'qualidade': 'Quality',
    'procedimentosQualidade': 'Procedures & Quality',
    'workInstruction': 'Work Instruction',
    'numeroWI': 'Work Instruction Number',
    'numeroInstrucao': 'Work instruction number',
    'qualityCheck': 'Quality Check',
    'numeroQC': 'Quality Check / ITP Number',
    'numeroControlo': 'Quality control number',
    'inspetor': 'Inspector',
    'nomeInspetor': 'Inspector Name',
    'nomeCertificacao': 'Inspector name and certification',
    'assinatura': 'Signature',
    'assinaturaDigital': 'Digital Signature',
    'assinar': 'Sign Digitally',
    'verAssinatura': 'View Signature',
    'assinadoEm': 'Signed on',
    'assinaturaEmDesenvolvimento': 'Digital signature under development',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 5: ENVIRONMENTAL CONDITIONS
    // ══════════════════════════════════════════════════════════════════════════
    'condicoesAmbientais': 'Environmental Conditions',
    'temperatura': 'Temperature',
    'temperaturaCelsius': 'Temperature (°C)',
    'humidade': 'Humidity',
    'humidadeRelativa': 'Relative Humidity (%)',
    'condicoesMeteorologicas': 'Weather Conditions',
    'condicoesMeteo': 'Weather Conditions',

    // Weather Conditions
    'ceuLimpo': 'Clear sky',
    'sol': 'Sunny',
    'nublado': 'Cloudy',
    'chuvaLeve': 'Light rain',
    'chuvaForte': 'Heavy rain',
    'ventoForte': 'Strong wind',
    'neve': 'Snow',

    // ══════════════════════════════════════════════════════════════════════════
    // TAB 6: PHOTOS & OBSERVATIONS
    // ══════════════════════════════════════════════════════════════════════════
    'fotosObservacoes': 'Photos & Observations',
    'foto': 'Photo',
    'adicionarFoto': 'Add Photo',
    'tirarFoto': 'Take Photo',
    'galeria': 'Gallery',
    'camara': 'Camera',
    'camera': 'Camera',
    'deletarFoto': 'Delete Photo',
    'confirmarDeletarFoto': 'Are you sure you want to delete this photo?',
    'observacoes': 'Observations',
    'notasTecnicas': 'Technical Notes',
    'detalhesExecucao': 'Execution details',
    'maxFotos': 'Maximum 10 photos',

    // ══════════════════════════════════════════════════════════════════════════
    // DATES & EXECUTION
    // ══════════════════════════════════════════════════════════════════════════
    'execucao': 'Execution',
    'executadoPor': 'Executed by',
    'selecionarData': 'Select date',

    // ══════════════════════════════════════════════════════════════════════════
    // ACTIONS
    // ══════════════════════════════════════════════════════════════════════════
    'adicionarConexaoExtra': 'Add Extra Connection',
    'novaConexaoExtra': 'New Extra Connection',
    'adicionarConexaoCustomizada': 'Add a custom connection',
    'editar': 'Edit',
    'aGuardar': 'Saving...',
    'deletar': 'Delete',
    'confirmar': 'Confirm',
    'criar': 'Create',
    'aCriar': 'Creating...',
    'voltar': 'Back',
    'fechar': 'Close',

    // ══════════════════════════════════════════════════════════════════════════
    // DIALOGS & CONFIRMATIONS
    // ══════════════════════════════════════════════════════════════════════════
    'deletarConexaoExtra': 'Delete Extra Connection',
    'confirmarDeletarConexao': 'Are you sure you want to delete the connection',
    'acaoNaoPodeSerDesfeita': 'This action cannot be undone.',
    'conexaoNaoPodeSerDeletada': 'Standard connections cannot be deleted',
    'conexoesExtrasPodeDeletar': 'Extra connections can be deleted at any time',

    // ══════════════════════════════════════════════════════════════════════════
    // SUCCESS MESSAGES
    // ══════════════════════════════════════════════════════════════════════════
    'conexaoCriada': 'Connection created!',
    'conexaoAtualizada': 'Connection updated successfully!',
    'conexaoDeletada': 'Connection deleted',
    'fotoAdicionada': 'Photo added',
    'fotoDeletada': 'Photo deleted',
    'dadosGuardados': 'Data saved successfully!',

    // ══════════════════════════════════════════════════════════════════════════
    // ERROR MESSAGES
    // ══════════════════════════════════════════════════════════════════════════
    'erroCarregarConexoes': 'Error loading connections',
    'erroCriarConexao': 'Error creating connection',
    'erroAtualizarConexao': 'Error updating connection',
    'erroDeletarConexao': 'Error deleting connection',
    'erroAdicionarFoto': 'Error adding photo',
    'erroDeletarFoto': 'Error deleting photo',
    'erroGuardar': 'Error saving',
    'utilizadorNaoAutenticado': 'User not authenticated',

    // ══════════════════════════════════════════════════════════════════════════
    // VALIDATIONS
    // ══════════════════════════════════════════════════════════════════════════
    'campoObrigatorio': 'Required field',
    'valorInvalido': 'Invalid value',
    'numeroInvalido': 'Invalid number',

    // ══════════════════════════════════════════════════════════════════════════
    // PLACEHOLDERS & HINTS
    // ══════════════════════════════════════════════════════════════════════════
    'exemploTorque': '1200',
    'exemploTensionamento': '850',
    'exemploMetrica': 'M36, M42, 2 inch',
    'exemploQuantidade': '72',
    'exemploBatch': 'BATCH-2024-A-001',
    'exemploVUI': 'VUI-M36-12345',
    'exemploSerial': 'SN-BOLT-98765-2024',
    'exemploPartNumber': 'PN-M36X120-HEX-STUD',
    'exemploEquipamentoId': 'TORQUE-WRENCH-005',
    'exemploEquipamentoSerial': 'SN-TW-2023-0456',
    'exemploWI': 'WI-TOWER-BOLTING-001-Rev3',
    'exemploQC': 'QC-WTG01-TOWER-20260124-001',
    'exemploInspetor': 'John Smith - Cert. QC-Level-2',
    'exemploTemperatura': '18.5',
    'exemploHumidade': '65',
    'exemploObservacoes': 'Torque applied in 3 passes as per WI-001...',
    'exemploComponenteOrigem': 'Platform, Transformer',
    'exemploComponenteDestino': 'Tower Bottom, Nacelle Base',
    'exemploDescricao': 'Access platform to bottom section',

    // ══════════════════════════════════════════════════════════════════════════
    // DESCRIPTIONS & HELPERS
    // ══════════════════════════════════════════════════════════════════════════
    'deOndeParteConexao': 'Where the connection starts from',
    'paraOndeVaiConexao': 'Where the connection goes to',
    'agrupaConexoesSimilares': 'Groups similar connections',
    'detalhesSobreConexao': 'Details about this connection',

    // ══════════════════════════════════════════════════════════════════════════
    // STATISTICS
    // ══════════════════════════════════════════════════════════════════════════
    'total': 'Total',
    'completas': 'Complete',
    'pendentes': 'Pending',
    'estatisticas': 'Statistics',

    // ══════════════════════════════════════════════════════════════════════════
    // EMPTY STATES
    // ══════════════════════════════════════════════════════════════════════════
    'nenhumaConexao': 'No connections',
    'nenhumaConexaoCategoria': 'No connections in this category',

    // ══════════════════════════════════════════════════════════════════════════
    // OTHERS
    // ══════════════════════════════════════════════════════════════════════════
    'descricao': 'Description',
    'opcional': 'Optional',
    'obrigatorio': 'Required',
    'carregando': 'Loading...',
    'erro': 'Error',
    'sucesso': 'Success',
    'atencao': 'Warning',
    'informacao': 'Information',
    'componentes': 'Components',
    'timeline_view': 'Timeline',
    'timeline': 'Timeline',
  };
}
