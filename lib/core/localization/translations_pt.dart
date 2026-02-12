// Traduções PT-BR/PT-PT
final Map<String, String> translationsPT = {
  // Auth
  'login_title': 'Bem-vindo ao As-Built',
  'login_subtitle': 'Sistema de Gestão de Instalação de Turbinas Eólicas',
  'email': 'Email',
  'password': 'Palavra-passe',
  'login_button': 'Entrar',
  'login_error': 'Erro no login',
  'user_not_found': 'Utilizador não encontrado',
  'wrong_password': 'Palavra-passe incorreta',
  'invalid_email': 'Email inválido',
  'user_disabled': 'Conta desativada',
  'invalid_credentials': 'Credenciais inválidas',

  // Dashboard
  'dashboard_title': 'Painel de Controlo',
  'search_turbines': 'Pesquisar turbinas...',
  'filters': 'Filtros',
  'status': 'Estado',
  'progress': 'Progresso',
  'create_new_project': 'Criar Novo Projeto',
  'no_turbines_found': 'Nenhuma turbina encontrada',
  'total_turbines': 'Total de Turbinas',
  'average_progress': 'Progresso Médio',
  'in_installation': 'Em Instalação',
  'installed': 'Instaladas',

  // Status da Turbina
  'status_All': 'Todas',
  'status_Planejada': 'Planeada',
  'status_Em Instalação': 'Em Instalação',
  'status_Instalada': 'Instalada',
  'status_Comissionada': 'Comissionada',
  'status_Em Manutenção': 'Em Manutenção',

  // Project Dialog
  'create_project_title': 'Criar Novo Projeto',
  'project_name': 'Nome do Projeto',
  'project_id': 'ID do Projeto',
  'location': 'Localização',
  'project_manager': 'Gestor do Projeto',
  'site_manager': 'Gestor do Local',
  'turbine_type': 'Tipo de Turbina',
  'foundation_type': 'Tipo de Fundação',
  'tower_sections': 'Seções da Torre',
  'site_opening_date': 'Data de Abertura do Local',
  'estimated_grid_availability': 'Disponibilidade Estimada da Rede',
  'estimated_handover': 'Entrega Estimada',
  'select_date': 'Selecionar data',
  'cancel': 'Cancelar',
  'create': 'Criar',
  'required_field': 'Campo obrigatório',
  'project_created_success': 'Projeto criado com sucesso!',
  'project_create_error': 'Erro ao criar projeto',

  // Project Phases
  'project_phases': 'Fases do Projeto',
  'no_phases_found': 'Nenhuma fase encontrada',
  'phases_completed': 'fases concluídas',
  'phase': 'Fase',
  'optional': 'Opcional',
  'not_started': 'Não iniciada',
  'start': 'Início',
  'end': 'Fim',
  'start_date': 'Data de Início',
  'end_date': 'Data de Fim',
  'phase_marked_na': 'Fase marcada como não aplicável',
  'mark_phase_na_if_not_needed':
      'Marque se esta fase não for necessária neste projeto',
  'add_notes_optional': 'Adicionar observações (opcional)...',
  'phase_dates_required': 'Data de início e fim são obrigatórias',
  'phase_updated_success': 'Fase atualizada com sucesso!',
  'view_phases': 'Ver Fases',

  // Turbine Dialog
  'add_turbine_title': 'Adicionar Turbina',
  'vui_unit_id': 'VUI / ID da Unidade',
  'turbine_model': 'Modelo da Turbina',
  'turbine_status': 'Estado da Turbina',
  'installation_date': 'Data de Instalação',
  'notes': 'Notas',
  'add_turbine': 'Adicionar Turbina',
  'turbine_created_success': 'Turbina criada com sucesso!',
  'turbine_create_error': 'Erro ao criar turbina',
  'project_name_hint': 'ex., Parque Eólico Alfa',
  'project_id_hint': 'ex., SP-40195',
  'location_hint': 'ex., Portugal',
  'turbine_type_hint': 'ex., V150',
  'foundation_type_hint': 'ex., Gravidade',

  // Turbine Details
  'turbine_details': 'Detalhes da Turbina',
  'components': 'Componentes',
  'installation_progress': 'Progresso de Instalação',
  'component_name': 'Nome do Componente',
  'installation_order': 'Ordem de Instalação',
  'installed_date': 'Data de Instalação',
  'actions': 'Ações',
  'mark_not_applicable': 'Marcar como N/A',
  'replace_component': 'Substituir Componente',
  'add_custom_component': 'Adicionar Componente Personalizado',

  // Component Categories
  'category_Nacelle': 'Nacela',
  'category_Rotor': 'Rotor',
  'category_Tower': 'Torre',
  'category_Electrical': 'Elétrico',
  'category_Control': 'Controlo',
  'category_Safety': 'Segurança',
  'category_Other': 'Outro',

  // Component Status
  'not_installed': 'Não Instalado',
  'installing': 'Em Instalação',
  'installed_status': 'Instalado',
  'not_applicable': 'Não Aplicável',

  'component_status_Pendente': 'Pendente',
  'component_status_Em Progresso': 'Em Progresso',
  'component_status_Concluído': 'Concluído',
  'component_status_Bloqueado': 'Bloqueado',
  'component_status_N/A': 'N/A',

  // Component Actions
  'na_dialog_title': 'Marcar Componente como Não Aplicável',
  'na_dialog_message':
      'Tem a certeza que este componente não é aplicável a esta turbina?',
  'na_dialog_warning':
      'Este componente não será contado no cálculo de progresso.',
  'confirm': 'Confirmar',
  'component_marked_na': 'Componente marcado como N/A',

  // Replace Component
  'replace_dialog_title': 'Substituir Componente',
  'replace_reason': 'Motivo da Substituição',
  'reason_damage': 'Dano',
  'reason_defect': 'Defeito',
  'reason_failure': 'Avaria',
  'reason_age': 'Antiguidade',
  'reason_other': 'Outro',
  'replacement_notes': 'Observações da Substituição',
  'new_installation_date': 'Nova Data de Instalação',
  'replace': 'Substituir',
  'component_replaced_success': 'Componente substituído com sucesso!',
  'component_replace_error': 'Erro ao substituir componente',

  // Add Custom Component
  'add_component_dialog_title': 'Adicionar Componente Personalizado',
  'component_category': 'Categoria',
  'suggested_order': 'Ordem Sugerida',
  'component_added_success': 'Componente adicionado com sucesso!',
  'component_add_error': 'Erro ao adicionar componente',

  // Common
  'save': 'Guardar',
  'delete': 'Eliminar',
  'edit': 'Editar',
  'close': 'Fechar',
  'yes': 'Sim',
  'no': 'Não',
  'loading': 'A carregar...',
  'error': 'Erro',
  'success': 'Sucesso',

  // Menu
  'logout': 'Terminar Sessão',
  'settings': 'Definições',
  'language': 'Idioma',
  'portuguese': 'Português',
  'english': 'Inglês',

  // Dashboard - AppBar & Navigation
  'dashboard': 'Painel de Controlo',
  'as_built_dashboard': 'Painel As-Built',

  // Dashboard - Empty State
  'no_projects_yet': 'Ainda Sem Projetos',
  'create_first_project': 'Crie o seu primeiro projeto para começar',

  // Dashboard - Sections
  'turbines': 'Turbinas',

  // Dashboard - Actions
  'create_project': 'Criar Projeto',

  // Dashboard - No Results
  'no_turbines_yet': 'Ainda sem turbinas',
  'click_button_add_turbine':
      'Clique no botão abaixo para adicionar a primeira turbina',
  'try_adjusting_search': 'Tente ajustar a pesquisa ou filtros',

  // Dashboard - Delete Dialog
  'delete_turbine': 'Eliminar Turbina?',
  'delete_turbine_confirm': 'Tem a certeza que quer eliminar a turbina',
  'delete_all_components_warning':
      'Isto também eliminará todos os 34 componentes',
  'turbine_deleted': 'Turbina eliminada',

  // Menu Drawer
  'wind_turbine_management': 'Gestão de Turbinas Eólicas',
  'new_project': 'Novo Projeto',

  //Menu de Criaação de Turbinas
  'turbine_name': 'Nome da Turbina',
  'turbine_name_hint': 'ex: WTG-01, PAD-15',
  'sequence': 'Sequência',
  'installation_sequence': 'Sequência de Instalação',
  'location_optional': 'Localização (opcional)',
  'location_hint_turbine': 'ex: Setor A-Norte',
  'components_auto_created': '34 componentes serão criados automaticamente',
  'creating': 'A criar...',
  'create_turbine': 'Criar Turbina',

  // Turbine Details Screen
  'turbine_not_found': 'Turbina não encontrada',
  'refresh_progress': 'Atualizar Progresso',
  'total': 'Total',
  'in_progress': 'Em Progresso',
  'complete': 'Concluído',
  'completed': 'concluídos',

  // Wizard
  'create_project_wizard': 'Assistente de Criação de Projeto',
  'step': 'Passo',
  'project_info': 'Informação',
  'review': 'Revisão',
  'basic_project_information': 'Informação Básica do Projeto',
  'define_project_phases': 'Definir Fases do Projeto',
  'phases_optional_explanation':
      'Defina as datas de início e fim para cada fase. Fases opcionais podem ser marcadas como N/A.',
  'review_and_confirm': 'Rever e Confirmar',
  'project_information': 'Informação do Projeto',
  'phases_defined': 'Fases definidas',
  'phases_na': 'Fases N/A',
  'project_creation_info':
      'O projeto será criado com todas as informações e fases definidas. Pode editar as fases posteriormente se necessário.',
  'back': 'Voltar',
  'next': 'Próximo',
  'select_project': 'Selecionar projeto',

  // Timeline
  'phases_timeline': 'Timeline das Fases',
  'no_phases_with_dates': 'Nenhuma fase tem datas definidas ainda',
  'insufficient_date_data': 'Dados de datas insuficientes',
  'pending': 'Pendente',

  "phase_Início do Projeto": "Início do Projeto",
  "phase_Trabalhos Civis": "Trabalhos Civis",
  "phase_Tools Contêiner": "Tools Contêiner",
  "phase_Instalações": "Instalações",
  "phase_Subcontratados": "Subcontratados",
  "phase_Recepção Componentes Principais": "Recepção Componentes Principais",
  "phase_Recepção Acessórios": "Recepção Acessórios",
  "phase_Recepção SWG": "Recepção SWG",
  "phase_Recepção Cabos MV": "Recepção Cabos MV",
  "phase_Preparação de Componentes": "Preparação de Componentes",
  "phase_Pré-Instalação": "Pré-Instalação",
  "phase_Instalação Principal": "Instalação Principal",
  "phase_Trabalhos Elétricos": "Trabalhos Elétricos",
  "phase_Inspeções": "Inspeções",
  "phase_Inspeções do Cliente": "Inspeções do Cliente",
  "phase_Pré-Comissionamento": "Pré-Comissionamento",
  "phase_Comissionamento": "Comissionamento",
  "phase_Testes às Turbinas": "Testes às Turbinas",
  "phase_Handover": "Handover",
  "phase_Observações Finais": "Observações Finais",

  // Phase names (formato notificações) - ADICIONA ISTO
  "phase_project_start": "Início do Projeto",
  "phase_civil_works": "Trabalhos Civis",
  "phase_tools_container": "Tools Contêiner",
  "phase_installations": "Instalações",
  "phase_subcontractors": "Subcontratados",
  "phase_main_components_receipt": "Recepção Componentes Principais",
  "phase_accessories_receipt": "Recepção Acessórios",
  "phase_swg_receipt": "Recepção SWG",
  "phase_mv_cables_receipt": "Recepção Cabos MV",
  "phase_component_preparation": "Preparação de Componentes",
  "phase_pre_installation": "Pré-Instalação",
  "phase_main_installation": "Instalação Principal",
  "phase_electrical_works": "Trabalhos Elétricos",
  "phase_inspections": "Inspeções",
  "phase_client_inspections": "Inspeções do Cliente",
  "phase_pre_commissioning": "Pré-Comissionamento",
  "phase_commissioning": "Comissionamento",
  "phase_turbine_tests": "Testes às Turbinas",
  "phase_handover": "Handover",
  "phase_final_observations": "Observações Finais",

  // ============================================================================
  // 🔔 SISTEMA DE NOTIFICAÇÕES - NOVO
  // ============================================================================

  // Notificações - Geral
  'notifications': 'Notificações',
  'active_alerts': 'alertas ativos',
  'no_notifications': 'Sem notificações',
  'notifications_disabled': 'Notificações desativadas',
  'enable': 'Ativar',
  'dismiss': 'Dispensar',
  'alert_dismissed': 'Alerta dispensado',
  'mute_7_days': 'Silenciar 7 dias',
  'mute_30_days': 'Silenciar 30 dias',
  'project_muted_7_days': 'Projeto silenciado por 7 dias',
  'project_muted_30_days': 'Projeto silenciado por 30 dias',

  // Prioridades
  'all': 'Todos',
  'critical': 'Crítico',
  'warning': 'Atenção',
  'info': 'Info',

  // Tempo
  'days_ago': 'dias atrás',
  'hours_ago': 'horas atrás',
  'minutes_ago': 'minutos atrás',
  'just_now': 'agora',
  'days': 'dias',

  // Settings
  'notification_settings': 'Configurações de Notificações',
  'general': 'Geral',
  'alert_types': 'Tipos de Alertas',
  'thresholds': 'Limites',
  'maintenance': 'Manutenção',

  // Settings - Geral
  'enable_notifications': 'Ativar notificações',
  'enable_notifications_desc':
      'Receber alertas sobre fases, componentes e turbinas',
  'show_badge_appbar': 'Mostrar badge no AppBar',
  'show_badge_appbar_desc': 'Exibir número de alertas ativos',
  'show_in_dashboard': 'Mostrar no Dashboard',
  'show_in_dashboard_desc': 'Exibir cards de alertas no dashboard',

  // Settings - Tipos
  'phase_alerts': 'Alertas de Fases',
  'phase_alerts_desc': 'Fases atrasadas ou próximas do prazo',
  'component_alerts': 'Alertas de Componentes',
  'component_alerts_desc': 'Componentes sem progresso ou dados em falta',
  'turbine_alerts': 'Alertas de Turbinas',
  'turbine_alerts_desc': 'Turbinas com baixo progresso',

  // Settings - Thresholds
  'phase_warning_days': 'Avisar antes do prazo',
  'phase_warning_days_desc': 'Dias antes do fim da fase para gerar alerta',
  'component_stalled_days': 'Componente sem progresso',
  'component_stalled_days_desc': 'Dias sem progresso para considerar parado',
  'turbine_stalled_days': 'Turbina sem progresso',
  'turbine_stalled_days_desc': 'Dias sem progresso para considerar parada',

  // Settings - Manutenção
  'cleanup_old_data': 'Limpar dados antigos',
  'cleanup_old_data_desc':
      'Remove alertas dispensados e projetos silenciados expirados',
  'cleanup_success': 'Dados antigos removidos com sucesso',
  'cleanup': 'Limpar',
  'reset_settings': 'Resetar configurações',
  'reset_settings_desc': 'Voltar às configurações padrão',
  'reset_settings_confirm':
      'Tem certeza que deseja resetar todas as configurações?',
  'settings_reset_success': 'Configurações resetadas com sucesso',
  'reset': 'Resetar',
  'notification_settings_info':
      'As configurações são guardadas localmente no dispositivo',

  // Notification messages - TÍTULOS
  "phase_overdue_title": "Fase atrasada há {days} dias",
  "phase_approaching_title": "Fase próxima do prazo ({days} dias)",
  "phase_not_started_title": "Fase obrigatória não iniciada",
  "phase_no_end_date_title": "Fase sem data de conclusão",

  // Notification messages - DESCRIÇÕES
  "phase_overdue_desc": "A fase \"{phase}\" deveria ter terminado em {date}",
  "phase_approaching_desc": "A fase \"{phase}\" termina em {date}",
  "phase_not_started_desc":
      "A fase obrigatória \"{phase}\" ainda não tem datas definidas",
  "phase_no_end_date_desc":
      "A fase \"{phase}\" iniciou há {days} dias mas não tem data de fim",

  // Módulos
  'as_built': 'As-Built',
  'installation': 'Instalação',
  'installation_module': 'Módulo de Instalação',

  // Navegação
  'reports': 'Relatórios',
  'team': 'Equipe',
  'help': 'Ajuda',

  // Abas do Módulo de Instalação
  'schedule': 'Cronograma',
  'teams': 'Equipes',
  'materials': 'Materiais',
  'quality_control': 'Controle de Qualidade',

  // Status de Instalação
  'scheduled': 'Agendado',
  'active': 'Ativo',
  'standby': 'Standby',

  // Materiais
  'in_stock': 'Em Estoque',
  'low_stock': 'Estoque Baixo',
  'out_of_stock': 'Fora de Estoque',

  // Qualidade
  'approved': 'Aprovado',
  'rejected': 'Reprovado',
  'inspector': 'Inspetor',
  'inspection_date': 'Data de Inspeção',

  // Mensagens
  'coming_soon': 'Em Breve',
  'coming_soon_message':
      'Esta funcionalidade está em desenvolvimento e estará disponível em breve!',
  'confirm_logout': 'Confirmar Logout',
  'confirm_logout_message': 'Tem certeza que deseja sair?',

  // Ajuda
  'help_center': 'Central de Ajuda',
  'phone': 'Telefone',
  'documentation': 'Documentação',

  // ============================================================================
  // COMPONENTES / TIPOS
  // ============================================================================
  'component_foundation': 'Fundação',
  'component_tower': 'Torre',
  'component_nacelle': 'Nacelle',
  'component_rotor': 'Rotor',
  'component_blade': 'Pá',
  'component_hub': 'Hub',

  // ============================================================================
  // EQUIPES
  // ============================================================================
  'team_alpha': 'Equipe Alpha',
  'team_beta': 'Equipe Beta',
  'team_gamma': 'Equipe Gamma',
  'team_members': 'membros',
  'supervisor': 'Supervisor',
  'current_task': 'Tarefa Atual',

  // ============================================================================
  // TAREFAS
  // ============================================================================
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

  // ============================================================================
  // MATERIAIS
  // ============================================================================
  'material_m30_bolts': 'Parafusos M30',
  'material_steel_cable_50mm': 'Cabo de Aço 50mm',
  'material_concrete_c40': 'Concreto C40',

  // ============================================================================
  // UNIDADES
  // ============================================================================
  'unit_units': 'unidades',
  'unit_meters': 'metros',
  'unit_cubic_meters': 'm³',
  'unit_kg': 'kg',
  'unit_liters': 'litros',

  // ============================================================================
  // INSPEÇÕES
  // ============================================================================
  'inspection_foundation_inspection': 'Inspeção de Fundação',
  'inspection_tower_alignment': 'Alinhamento Torre',
  'inspection_electrical_test': 'Teste Elétrico',

  // ============================================================================
  // NOTAS DE INSPEÇÃO
  // ============================================================================
  'inspection_notes_foundation': 'Fundação dentro das especificações',
  'inspection_notes_awaiting': 'Aguardando segunda medição',
  'inspection_notes_rework': 'Requer retrabalho no painel',

  // Fases
  'phase_reception': 'Receção',
  'phase_installation': 'Instalação',
  'phase_electrical': 'Elétrico',

  // Status
  'status_completed': 'Concluído',
  'status_in_progress': 'Em Progresso',
  'status_pending': 'Pendente',
  'na': 'N/A',

  // Tarefas de cada fase
  'reception_checklist': 'Checklist de Receção',
  'pre_installation_tasks': 'Tarefas de Pré-Instalação',
  'installation_tasks': 'Tarefas de Instalação',
  'electrical_tasks': 'Tarefas Elétricas',
  'commissioning_tasks': 'Tarefas de Comissionamento',

  // Componentes
  'site_preparation': 'Preparação do Local',
  'foundation_check': 'Verificação da Fundação',
  'crane_setup': 'Montagem da Grua',
  'tower_installation': 'Instalação da Torre',
  'nacelle_installation': 'Instalação da Nacelle',
  'rotor_installation': 'Instalação do Rotor',
  'cable_installation': 'Instalação de Cabos',
  'transformer_connection': 'Ligação do Transformador',
  'electrical_tests': 'Testes Elétricos',
  'functional_tests': 'Testes Funcionais',
  'safety_checks': 'Verificações de Segurança',
  'final_inspection': 'Inspeção Final',

  // Receção
  'received': 'Recebido',
  'pending_reception': 'Aguardando Receção',
  'pre_assembly': 'Pré-Montagem',
  'assembly': 'Montagem',
  'final_phases': 'Fases Finais',

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
  // 📝 CAMPOS E AÇÕES
  // ────────────────────────────────────────────────────────────────────────
  'item_name': 'Nome do Item',
  'add': 'Adicionar',
  'item_number': 'Número do Item',
  'serial_number': 'Número de Série',
  'startDate': 'Data de Início',
  'endDate': 'Data de Fim',
  'startTime': 'Hora de Início',
  'endTime': 'Hora de Fim',
  'photos': 'Fotos',
  'add_photo': 'Adicionar Foto',
  'observations': 'Observações',

  // Ações
  'mark_as_na': 'Marcar como N/A',
  'mark_phase_na_confirm': 'Tem certeza que deseja marcar como não aplicável?',
  'data_saved_successfully': 'Dados salvos com sucesso!',

  // ────────────────────────────────────────────────────────────────────────
  // 📊 STATUS
  // ────────────────────────────────────────────────────────────────────────
  'blocked': 'Bloqueado',

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

  // ────────────────────────────────────────────────────────────────────────
  // 📈 PROGRESSO
  // ────────────────────────────────────────────────────────────────────────
  'mark_if_not_installed': 'Marque se este componente não existe neste site',

  // ────────────────────────────────────────────────────────────────────────
  // 📝 CAMPOS
  // ────────────────────────────────────────────────────────────────────────
  'no_notes': 'Sem observações',
  'no_photos': 'Sem fotos',

  // ────────────────────────────────────────────────────────────────────────
  // 🔬 COMISSIONAMENTO - FASES PRINCIPAIS
  // ────────────────────────────────────────────────────────────────────────
  'commissioning': 'Comissionamento',
  'pre_commissioning_tests': 'Testes Pré-Comissionamento',
  'final_acceptance': 'Aceitação Final',

  // ────────────────────────────────────────────────────────────────────────
  // 🔬 COMISSIONAMENTO - SUB-FASES
  // ────────────────────────────────────────────────────────────────────────
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

  // N/A
  'component_not_used': 'Este componente não é utilizado',

  // Ações
  'component_updated_success': 'Componente atualizado com sucesso!',

  // Replace
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

  // ════════════════════════════════════════════════════════════════════════
  // 🆕 FASE EDIT DIALOG - CAMPOS ADICIONAIS
  // ════════════════════════════════════════════════════════════════════════
  'progresso': 'Progresso',
  'guardar': 'Guardar',
  'cancelar': 'Cancelar',
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
  'naoAplicavel': 'Não Aplicável (N/A)',
  'faseNaoAplicavel': 'Esta fase não é aplicável',
  'motivoNA': 'Motivo N/A',
  'indiqueMotivoNA': 'Indique o motivo...',
  'motivoObrigatorio': 'Motivo obrigatório',
  'adicionar': 'Adicionar',
  'nenhumaFoto': 'Nenhuma foto adicionada',

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

  // ══════════════════════════════════════════════════════════════════════════
  // 📝 TRADUÇÕES PARA WIZARD DE CRIAÇÃO DE PROJETO
  // ══════════════════════════════════════════════════════════════════════════

  // Tab 1 - Campos novos
  'address': 'Morada',
  'gps_coordinates': 'Coordenadas GPS',

  // Tab 2 - Fases
  'project_execution_phases': 'Fases de Execução do Projeto',
  'grid_availability_info': 'Data estimada de disponibilidade da rede elétrica',

  // Nomes das fases (traduzidos)
  'phase_mobilizacao': 'Início do Projeto',
  'phase_fundacoes': 'Trabalhos Civis',
  'phase_instalacoes': 'Instalações',
  'phase_logistica': 'Logística',
  'phase_instalacao_eletrica': 'Instalação Elétrica',
  'phase_instalacao_mecanica': 'Instalação Mecânica',
  'phase_comissionamento': 'Comissionamento',
  'phase_testes': 'Testes',
  'phase_entrega': 'Entrega',
  'phase_garantia': 'Garantia',
  'phase_facilities': 'Instalações',

  // Turbina - Dialog de Criação
  'number_of_middle_sections': 'Número de Seções Intermediárias',
  'middle_section': 'Seção Intermediária',
  'middle_sections': 'seções intermediárias',
  'middle_sections_info': 'Define quantas seções intermediárias a torre possui',
  'torqueTensioning': 'Torque & Tensionamento',

  // Reports
  'generate_report': 'Gerar Relatório',
  'report_format': 'Formato do Relatório',
  'select_phases': 'Selecionar Fases',
  'select_all': 'Selecionar Tudo',
  'clear_all': 'Limpar Tudo',
  'report_email_info': 'O relatório será enviado para o seu email',
  'generate_and_send': 'Gerar e Enviar',
  'generating': 'A gerar...',
  'report_sent_success': 'Relatório gerado e enviado com sucesso!',

  // Grua
  "register_activity": "Registar Atividade",
  "activity_type": "Tipo de Atividade",
  "mobilizacao": "Mobilização",
  "trabalho": "Trabalho Efetivo",
  "paragem": "Tempo de Paragem",
  "transferencia": "Transferência entre Pads",
  "desmobilizacao": "Desmobilização",
  "wind": "Vento Excessivo",
  "mechanical": "Avaria Mecânica",
  "waiting_components": "Espera por Componentes",
  "safety": "Segurança/HSE",
  "origin_pad": "Pad de Origem",
  "destination_pad": "Pad de Destino",
  "logistics_crane": "Logística & Gruas",

  // Botões Mobile - Instalação
  'logout_confirmation': 'Tens a certeza que queres terminar sessão?',
  'no_projects_available': 'Nenhum projeto disponível',

  // ════════════════════════════════════════════════════════════════════════
  // 🏗️ SISTEMA DE GRUAS (NOVO)
  // ════════════════════════════════════════════════════════════════════════

  // Geral
  'cranes': 'Gruas',
  'crane': 'Grua',
  'crane_management': 'Gestão de Gruas',
  'crane_management_subtitle': 'Gerir gruas e registar atividades',
  'crane_activities': 'Atividades da Grua',

  // Lista de Gruas
  'no_cranes_yet': 'Ainda não há gruas',
  'add_first_crane': 'Adiciona a primeira grua deste projeto',
  'add_crane': 'Adicionar Grua',
  'crane_model': 'Modelo da Grua',
  'crane_model_required': 'O modelo da grua é obrigatório',
  'multiple_cranes_info':
      'Podes adicionar várias gruas. Cada uma terá o seu próprio registo de atividades.',
  'crane_added_success': 'Grua adicionada com sucesso',

  // Eliminar Grua
  'delete_crane': 'Eliminar Grua',
  'delete_crane_confirm': 'Tens a certeza que queres eliminar a grua',
  'delete_crane_warning':
      'Esta ação irá eliminar a grua e TODAS as suas atividades. Esta operação não pode ser desfeita.',
  'crane_deleted_success': 'Grua eliminada com sucesso',

  // Atividades
  'activities': 'atividades',
  'no_activities_yet': 'Ainda não há atividades',
  'add_first_activity': 'Adiciona a primeira atividade desta grua',

  // Ações
  'delete_activity': 'Eliminar Atividade',
  'delete_activity_confirm':
      'Tens a certeza que queres eliminar esta atividade?',
  'activity_deleted_success': 'Atividade eliminada com sucesso',

  // ════════════════════════════════════════════════════════════════════════
  // 🌐 GRUAS GERAIS DO PROJETO (não atribuídas a pads)
  // ════════════════════════════════════════════════════════════════════════

  // Geral
  'general_cranes': 'Gruas Gerais',
  'general_crane': 'Grua Geral',
  'general_cranes_management': 'Gestão de Gruas Gerais',
  'general_cranes_subtitle': 'Gruas não atribuídas a nenhuma turbina',
  'general_crane_activities': 'Atividades da Grua Geral',

  // Lista
  'no_general_cranes_yet': 'Ainda não há gruas gerais',
  'add_first_general_crane':
      'Adiciona a primeira grua geral do projeto. Estas gruas são usadas para operações que não estão atribuídas a nenhuma turbina específica.',
  'add_general_crane': 'Adicionar Grua Geral',
  'general_cranes_info':
      'Gruas gerais são usadas para operações do projeto que não estão ligadas a uma turbina específica (ex: transporte, montagem de subestação, etc.)',
  'description_optional': 'Descrição (opcional)',
  'crane_usage_example': 'Ex: Transporte de componentes grandes',

  // Sucesso/Erro
  'general_crane_added_success': 'Grua geral adicionada com sucesso',
  'delete_general_crane': 'Eliminar Grua Geral',
  'general_crane_deleted_success': 'Grua geral eliminada com sucesso',

  // ════════════════════════════════════════════════════════════════════════
  // 📊 RELATÓRIOS - GRUAS
  // ════════════════════════════════════════════════════════════════════════

  'cranes_pads_report': 'Gruas (Pads)',
  'cranes_general_report': 'Gruas Gerais',

  // ══════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ══════════════════════════════════════════════════════════════
  'email_phase_complete': 'Email quando fase completa',
  'email_phase_complete_desc':
      'Receber notificação por email ao completar uma fase',
  'deadline_alerts': 'Alertas de prazos',
  'deadline_alerts_desc': 'Notificações sobre prazos próximos',
  'turbine_changes': 'Mudanças em turbinas',
  'turbine_changes_desc': 'Notificar quando houver alterações em turbinas',
  'weekly_reports': 'Relatórios semanais',
  'weekly_reports_desc': 'Receber resumo semanal por email',
  'date_format': 'Formato de Data',
  'theme': 'Tema',
  'light_theme': 'Claro',
  'dark_theme': 'Escuro',
  'data': 'Dados',
  'export_all_data': 'Exportar todos os dados',
  'export_all_data_desc': 'Download completo em JSON',
  'clear_cache': 'Limpar cache',
  'clear_cache_desc': 'Libertar espaço de armazenamento',
  'clear_cache_confirm': 'Tem certeza que deseja limpar o cache?',
  'cache_cleared': 'Cache limpo com sucesso',
  'account': 'Conta',
  'change_password': 'Alterar password',
  'change_password_desc': 'Altere a sua password de acesso',
  'clear': 'Limpar',

// ══════════════════════════════════════════════════════════════
// TEAM MANAGEMENT SCREEN
// ══════════════════════════════════════════════════════════════
  'team_management': 'Gestão de Equipas',
  'team_management_desc': 'Gerir empresas e contractors envolvidos no projeto',
  'civil_construction': 'Construção Civil',
  'electrical': 'Eletricidade',
  'turbine_assembly': 'Montagem de Turbinas',
  'transport': 'Transporte',
  'add_category': 'Adicionar Categoria',
  'no_companies_yet': 'Nenhuma empresa adicionada',
  'add_company': 'Adicionar Empresa',
  'company_name': 'Nome da Empresa',
  'contact': 'Contacto',
  'name_required': 'Nome é obrigatório',
  'company_added': 'Empresa adicionada com sucesso',
  'edit_company': 'Editar Empresa',
  'company_updated': 'Empresa atualizada',
  'delete_company': 'Eliminar Empresa',
  'delete_company_confirm': 'Tem certeza que deseja eliminar',
  'company_deleted': 'Empresa eliminada',

  // ══════════════════════════════════════════════════════════════
  // HELP SCREEN
  // ══════════════════════════════════════════════════════════════
  'quick_start_guide': 'Guia de Início Rápido',
  'quick_start_guide_desc': 'Primeiros passos com a aplicação',
  'how_to_add_turbines': 'Como adicionar turbinas',
  'how_to_add_turbines_desc': 'Guia passo a passo',
  'phase_management': 'Gestão de Fases',
  'phase_management_desc': 'Gerir fases de instalação',
  'reports_help': 'Relatórios',
  'reports_help_desc': 'Como gerar e exportar relatórios',
  'cranes_logistics': 'Gruas e Logística',
  'cranes_logistics_desc': 'Gestão de gruas e transporte',
  'video_tutorials': 'Tutoriais em Vídeo',
  'overview_video_desc': 'Visão geral da aplicação',
  'components_video_desc': 'Adicionar e gerir componentes',
  'reports_video_desc': 'Gerar relatórios Excel e PDF',
  'support': 'Suporte',
  'contact_support': 'Contactar Suporte',
  'live_chat': 'Chat ao Vivo',
  'online': 'Online',
  'avg_response_2min': 'Resposta média em 2 minutos',
  'report_bug': 'Reportar Problema',
  'report_bug_desc': 'Ajude-nos a melhorar',
  'about': 'Sobre',
  'wind_turbine_installation': 'Instalação de Turbinas Eólicas',
  'version': 'Versão',
  'updated': 'Atualizado',
  'terms_of_service': 'Termos de Serviço',
  'privacy_policy': 'Política de Privacidade',
  'licenses': 'Licenças',
  'updates': 'Atualizações',
  'app_up_to_date': 'A aplicação está atualizada',
  'check_updates': 'Verificar atualizações',
  'keyboard_shortcuts': 'Atalhos de Teclado',
  'search': 'Pesquisar',
  'print': 'Imprimir',
  'undo': 'Desfazer',
  'redo': 'Refazer',
  'view_all_shortcuts': 'Ver todos os atalhos',
  'opening_video': 'A abrir vídeo',
  'opening': 'A abrir',
  'bug_title': 'Título do Problema',
  'bug_description': 'Descrição',
  'bug_reported': 'Problema reportado com sucesso',
  'submit': 'Submeter',
  'full_docs_available': 'Documentação completa disponível online',
  'checking_updates': 'A verificar atualizações...',

  // Conteúdos de documentação (exemplos básicos)
  'quick_start_content':
      'Bem-vindo ao As-Built! Esta aplicação permite gerir a instalação de turbinas eólicas de forma eficiente.\n\n1. Crie um novo projeto\n2. Adicione turbinas\n3. Registe fases de instalação\n4. Gere relatórios',
  'add_turbines_content':
      'Para adicionar uma turbina:\n\n1. Clique no botão + no canto inferior direito\n2. Preencha o nome (ex: WTG-01)\n3. Selecione o tipo de turbina\n4. Clique em Criar',
  'phases_content':
      'As fases de instalação são:\n\n• Receção\n• Preparação\n• Pré-Assemblagem\n• Assemblagem\n• Torque & Tensionamento\n• Fases Finais',
  'reports_content':
      'Para gerar relatórios:\n\n1. Clique no botão de relatórios\n2. Selecione as fases desejadas\n3. Escolha Excel ou PDF\n4. Clique em Gerar',
  'cranes_content':
      'Gerir gruas:\n\n1. Aceda ao menu Gruas\n2. Registe mobilizações/desmobilizações\n3. Acompanhe atividades\n4. Gere relatórios específicos',

  // ══════════════════════════════════════════════════════════════
  // 🆕 TRADUÇÕES ADICIONAIS
  // ══════════════════════════════════════════════════════════════
  'turbine_overview': 'Visão Geral da Turbina',
  'component_status': 'Status do Componente',
  'no_components_yet': 'Nenhum componente adicionado',
  'add_first_component': 'Adicione o primeiro componente desta turbina',
  'view_photos': 'Ver Fotos',
  'edit_observations': 'Editar Observações',
  'installation_complete': 'Instalação Completa',
  'mark_installation_complete': 'Marcar Instalação como Completa',
  'installation_complete_confirm':
      'Tem certeza que deseja marcar a instalação como completa?',
  'installation_marked_complete': 'Instalação marcada como completa',
  'resume_installation': 'Retomar Instalação',
  'resume_installation_confirm': 'Tem certeza que deseja retomar a instalação?',
  'installation_resumed': 'Instalação retomada',
  'add_first_turbine': 'Adicione a primeira turbina do projeto',
  'switch_to_light': 'Mudar para Tema Claro',
  'switch_to_dark': 'Mudar para Tema Escuro',
  'theme_changed': 'Tema alterado com sucesso',
  'select_time': 'Selecionar Hora',
  'no_data_available': 'Nenhum dado disponível',
  'saved': 'Salvo',
  'saving': 'Salvando...',
  'edit_phase': 'Editar Fase',
  'add_phase': 'Adicionar Fase',
  'phase_added_success': 'Fase adicionada com sucesso',
  'delete_phase': 'Eliminar Fase',
  'delete_phase_confirm': 'Tem certeza que deseja eliminar esta fase?',
  'phase_deleted_success': 'Fase eliminada com sucesso',
  'no_phases_yet': 'Nenhuma fase adicionada',
  'add_first_phase': 'Adicione a primeira fase deste projeto',
  'phase_name': 'Nome da Fase',
  'phase_name_required': 'O nome da fase é obrigatório',
  'phase_start_date': 'Data de Início da Fase',
  'phase_end_date': 'Data de Fim da Fase',
  'phase_progress': 'Progresso da Fase',
  'phase_progress_required': 'O progresso da fase é obrigatório',
  'phase_not_applicable': 'Fase Não Aplicável',
  'mark_phase_not_applicable': 'Marcar esta fase como não aplicável (N/A)',
  'phase_na_reason_required': 'O motivo para N/A é obrigatório',
  'phase_details': 'Detalhes da Fase',
  'phase_details_for': 'Detalhes da Fase para {phaseName}',
  'no_phases_defined': 'Nenhuma fase definida',
  'productivity_shortcuts': 'Atalhos de Produtividade',
  'navigation_shortcuts': 'Atalhos de Navegação',
  'appearance_shortcuts': 'Atalhos de Aparência',
  'toggle_language': 'Alternar Idioma',
  'toggle_theme': 'Alternar Tema',
  'shortcuts_tip':
      'Dica: Use estes atalhos para navegar mais rapidamente pela aplicação!',
  'select_project_first': 'Selecione um projeto primeiro',
  'dark_theme_activated': 'Tema escuro ativado',
  'light_theme_activated': 'Tema claro ativado',
};
