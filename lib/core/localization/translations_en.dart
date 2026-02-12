// English translations
final Map<String, String> translationsEN = {
  // Auth
  'login_title': 'Welcome to As-Built',
  'login_subtitle': 'Wind Turbine Installation Management System',
  'email': 'Email',
  'password': 'Password',
  'login_button': 'Login',
  'login_error': 'Login error',
  'user_not_found': 'User not found',
  'wrong_password': 'Wrong password',
  'invalid_email': 'Invalid email',
  'user_disabled': 'Account disabled',
  'invalid_credentials': 'Invalid credentials',

  // Dashboard
  'dashboard_title': 'Dashboard',
  'search_turbines': 'Search turbines...',
  'filters': 'Filters',
  'status': 'Status',
  'progress': 'Progress',
  'create_new_project': 'Create New Project',
  'no_turbines_found': 'No turbines found',
  'total_turbines': 'Total Turbines',
  'average_progress': 'Average Progress',
  'in_installation': 'In Installation',
  'installed': 'Installed',

  // Turbine Status
  'status_All': 'All',
  'status_Planejada': 'Planned',
  'status_Em Instalação': 'In Installation',
  'status_Instalada': 'Installed',
  'status_Comissionada': 'Commissioned',
  'status_Em Manutenção': 'Under Maintenance',

  // Project Dialog
  'create_project_title': 'Create New Project',
  'project_name': 'Project Name',
  'project_id': 'Project ID',
  'location': 'Location',
  'project_manager': 'Project Manager',
  'site_manager': 'Site Manager',
  'turbine_type': 'Turbine Type',
  'foundation_type': 'Foundation Type',
  'tower_sections': 'Tower Sections',
  'site_opening_date': 'Site Opening Date',
  'estimated_grid_availability': 'Estimated Grid Availability',
  'estimated_handover': 'Estimated Handover',
  'select_date': 'Select date',
  'cancel': 'Cancel',
  'create': 'Create',
  'required_field': 'Required field',
  'project_created_success': 'Project created successfully!',
  'project_create_error': 'Error creating project',

  // Project Phases
  'project_phases': 'Project Phases',
  'no_phases_found': 'No phases found',
  'phases_completed': 'phases completed',
  'phase': 'Phase',
  'optional': 'Optional',
  'not_started': 'Not started',
  'start': 'Start',
  'end': 'End',
  'start_date': 'Start Date',
  'end_date': 'End Date',
  'phase_marked_na': 'Phase marked as not applicable',
  'mark_phase_na_if_not_needed':
      'Mark if this phase is not needed in this project',
  'add_notes_optional': 'Add notes (optional)...',
  'phase_dates_required': 'Start and end dates are required',
  'phase_updated_success': 'Phase updated successfully!',
  'view_phases': 'View Phases',

  // Turbine Dialog
  'add_turbine_title': 'Add Turbine',
  'vui_unit_id': 'VUI / Unit ID',
  'turbine_model': 'Turbine Model',
  'turbine_status': 'Turbine Status',
  'installation_date': 'Installation Date',
  'notes': 'Notes',
  'add_turbine': 'Add Turbine',
  'turbine_created_success': 'Turbine created successfully!',
  'turbine_create_error': 'Error creating turbine',
  'project_name_hint': 'e.g., Wind Farm Alpha',
  'project_id_hint': 'e.g., SP-40195',
  'location_hint': 'e.g., Portugal',
  'turbine_type_hint': 'e.g., V150',
  'foundation_type_hint': 'e.g., Gravity',

  // Turbine Details
  'turbine_details': 'Turbine Details',
  'components': 'Components',
  'installation_progress': 'Installation Progress',
  'component_name': 'Component Name',
  'installation_order': 'Installation Order',
  'installed_date': 'Installed Date',
  'actions': 'Actions',
  'mark_not_applicable': 'Mark as N/A',
  'replace_component': 'Replace Component',
  'add_custom_component': 'Add Custom Component',

  // Component Categories
  'category_Nacelle': 'Nacelle',
  'category_Rotor': 'Rotor',
  'category_Tower': 'Tower',
  'category_Electrical': 'Electrical',
  'category_Control': 'Control',
  'category_Safety': 'Safety',
  'category_Other': 'Other',

  // Component Status
  'not_installed': 'Not Installed',
  'installing': 'Installing',
  'installed_status': 'Installed',
  'not_applicable': 'Not Applicable',

  'component_status_Pendente': 'Pending',
  'component_status_Em Progresso': 'In Progress',
  'component_status_Concluído': 'Completed',
  'component_status_Bloqueado': 'Blocked',
  'component_status_N/A': 'N/A',

  // Component Actions
  'na_dialog_title': 'Mark Component as Not Applicable',
  'na_dialog_message':
      'Are you sure this component is not applicable to this turbine?',
  'na_dialog_warning':
      'This component will not be counted in progress calculation.',
  'confirm': 'Confirm',
  'component_marked_na': 'Component marked as N/A',

  // Replace Component
  'replace_dialog_title': 'Replace Component',
  'replace_reason': 'Replacement Reason',
  'reason_damage': 'Damage',
  'reason_defect': 'Defect',
  'reason_failure': 'Failure',
  'reason_age': 'Age',
  'reason_other': 'Other',
  'replacement_notes': 'Replacement Notes',
  'new_installation_date': 'New Installation Date',
  'replace': 'Replace',
  'component_replaced_success': 'Component replaced successfully!',
  'component_replace_error': 'Error replacing component',

  // Add Custom Component
  'add_component_dialog_title': 'Add Custom Component',
  'component_category': 'Category',
  'suggested_order': 'Suggested Order',
  'component_added_success': 'Component added successfully!',
  'component_add_error': 'Error adding component',

  // Common
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'close': 'Close',
  'yes': 'Yes',
  'no': 'No',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',

  // Menu
  'logout': 'Logout',
  'settings': 'Settings',
  'language': 'Language',
  'portuguese': 'Portuguese',
  'english': 'English',

  // Dashboard - AppBar & Navigation
  'dashboard': 'Dashboard',
  'as_built_dashboard': 'As-Built Dashboard',

  // Dashboard - Empty State
  'no_projects_yet': 'No Projects Yet',
  'create_first_project': 'Create your first project to get started',

  // Dashboard - Sections
  'turbines': 'Turbines',

  // Dashboard - Actions
  'create_project': 'Create Project',

  // Dashboard - No Results
  'no_turbines_yet': 'No turbines yet',
  'click_button_add_turbine':
      'Click the button below to add your first turbine',
  'try_adjusting_search': 'Try adjusting your search or filters',

  // Dashboard - Delete Dialog
  'delete_turbine': 'Delete Turbine?',
  'delete_turbine_confirm': 'Are you sure you want to delete turbine',
  'delete_all_components_warning': 'This will also delete all 34 components',
  'turbine_deleted': 'Turbine deleted',

  // Menu Drawer
  'wind_turbine_management': 'Wind Turbine Management',
  'new_project': 'New Project',

  //Menu de Criação de Turbinas
  'turbine_name': 'Turbine Name',
  'turbine_name_hint': 'e.g., WTG-01, PAD-15',
  'sequence': 'Sequence',
  'installation_sequence': 'Installation Sequence',
  'location_optional': 'Location (optional)',
  'location_hint_turbine': 'e.g., Sector A-North',
  'components_auto_created': '34 components will be auto-created',
  'creating': 'Creating...',
  'create_turbine': 'Create Turbine',

  // Turbine Details Screen
  'turbine_not_found': 'Turbine not found',
  'refresh_progress': 'Refresh Progress',
  'total': 'Total',
  'in_progress': 'In Progress',
  'complete': 'Complete',
  'completed': 'completed',

  // Wizard
  'create_project_wizard': 'Create Project Wizard',
  'step': 'Step',
  'project_info': 'Information',
  'review': 'Review',
  'basic_project_information': 'Basic Project Information',
  'define_project_phases': 'Define Project Phases',
  'phases_optional_explanation':
      'Set start and end dates for each phase. Optional phases can be marked as N/A.',
  'review_and_confirm': 'Review and Confirm',
  'project_information': 'Project Information',
  'phases_defined': 'Phases defined',
  'phases_na': 'N/A phases',
  'project_creation_info':
      'The project will be created with all information and defined phases. You can edit phases later if needed.',
  'back': 'Back',
  'next': 'Next',
  'select_project': 'Select project',

  // Timeline
  'phases_timeline': 'Phases Timeline',
  'no_phases_with_dates': 'No phases have dates defined yet',
  'insufficient_date_data': 'Insufficient date data',
  'pending': 'Pending',

  // Phase names
  'phase_Início do Projeto': 'Project Start',
  'phase_Trabalhos Civis': 'Civil Works',
  'phase_Tools Contêiner': 'Tools Container',
  'phase_Instalações': 'Installations',
  'phase_Subcontratados': 'Subcontractors',
  'phase_Recepção Componentes Principais': 'Main Components Reception',
  'phase_Recepção Acessórios': 'Accessories Reception',
  'phase_Recepção SWG': 'SWG Reception',
  'phase_Recepção Cabos MV': 'MV Cables Reception',
  'phase_Preparação de Componentes': 'Components Preparation',
  'phase_Pré-Instalação': 'Pre-Installation',
  'phase_Instalação Principal': 'Main Installation',
  'phase_Trabalhos Elétricos': 'Electrical Works',
  'phase_Inspeções': 'Inspections',
  'phase_Inspeções do Cliente': 'Client Inspections',
  'phase_Pré-Comissionamento': 'Pre-Commissioning',
  'phase_Comissionamento': 'Commissioning',
  'phase_Testes às Turbinas': 'Turbine Tests',
  'phase_Handover': 'Handover',
  'phase_Observações Finais': 'Final Observations',

  // Phase names (notifications format) - ADD THIS
  'phase_project_start': 'Project Start',
  'phase_civil_works': 'Civil Works',
  'phase_tools_container': 'Tools Container',
  'phase_installations': 'Installations',
  'phase_subcontractors': 'Subcontractors',
  'phase_main_components_receipt': 'Main Components Reception',
  'phase_accessories_receipt': 'Accessories Reception',
  'phase_swg_receipt': 'SWG Reception',
  'phase_mv_cables_receipt': 'MV Cables Reception',
  'phase_component_preparation': 'Components Preparation',
  'phase_pre_installation': 'Pre-Installation',
  'phase_main_installation': 'Main Installation',
  'phase_electrical_works': 'Electrical Works',
  'phase_inspections': 'Inspections',
  'phase_client_inspections': 'Client Inspections',
  'phase_pre_commissioning': 'Pre-Commissioning',
  'phase_commissioning': 'Commissioning',
  'phase_turbine_tests': 'Turbine Tests',
  'phase_handover': 'Handover',
  'phase_final_observations': 'Final Observations',

  // ============================================================================
  // 🔔 NOTIFICATION SYSTEM - NEW
  // ============================================================================

  // Notifications - General
  'notifications': 'Notifications',
  'active_alerts': 'active alerts',
  'no_notifications': 'No notifications',
  'notifications_disabled': 'Notifications disabled',
  'enable': 'Enable',
  'dismiss': 'Dismiss',
  'alert_dismissed': 'Alert dismissed',
  'mute_7_days': 'Mute 7 days',
  'mute_30_days': 'Mute 30 days',
  'project_muted_7_days': 'Project muted for 7 days',
  'project_muted_30_days': 'Project muted for 30 days',

  // Priorities
  'all': 'All',
  'critical': 'Critical',
  'warning': 'Warning',
  'info': 'Info',

  // Time
  'days_ago': 'days ago',
  'hours_ago': 'hours ago',
  'minutes_ago': 'minutes ago',
  'just_now': 'just now',
  'days': 'days',

  // Settings
  'notification_settings': 'Notification Settings',
  'general': 'General',
  'alert_types': 'Alert Types',
  'thresholds': 'Thresholds',
  'maintenance': 'Maintenance',

  // Settings - General
  'enable_notifications': 'Enable notifications',
  'enable_notifications_desc':
      'Receive alerts about phases, components and turbines',
  'show_badge_appbar': 'Show badge in AppBar',
  'show_badge_appbar_desc': 'Display number of active alerts',
  'show_in_dashboard': 'Show in Dashboard',
  'show_in_dashboard_desc': 'Display alert cards in dashboard',

  // Settings - Types
  'phase_alerts': 'Phase Alerts',
  'phase_alerts_desc': 'Overdue or approaching phases',
  'component_alerts': 'Component Alerts',
  'component_alerts_desc': 'Stalled components or missing data',
  'turbine_alerts': 'Turbine Alerts',
  'turbine_alerts_desc': 'Turbines with low progress',

  // Settings - Thresholds
  'phase_warning_days': 'Warn before deadline',
  'phase_warning_days_desc': 'Days before phase end to generate alert',
  'component_stalled_days': 'Component without progress',
  'component_stalled_days_desc': 'Days without progress to consider stalled',
  'turbine_stalled_days': 'Turbine without progress',
  'turbine_stalled_days_desc': 'Days without progress to consider stalled',

  // Settings - Maintenance
  'cleanup_old_data': 'Clean old data',
  'cleanup_old_data_desc':
      'Removes dismissed alerts and expired muted projects',
  'cleanup_success': 'Old data successfully removed',
  'cleanup': 'Clean',
  'reset_settings': 'Reset settings',
  'reset_settings_desc': 'Return to default settings',
  'reset_settings_confirm': 'Are you sure you want to reset all settings?',
  'settings_reset_success': 'Settings reset successfully',
  'reset': 'Reset',
  'notification_settings_info': 'Settings are saved locally on the device',

  // Notification messages - TITLES
  'phase_overdue_title': 'Phase overdue by {days} days',
  'phase_approaching_title': 'Phase deadline in {days} days',
  'phase_not_started_title': 'Mandatory phase not started',
  'phase_no_end_date_title': 'Phase without completion date',

  // Notification messages - DESCRIPTIONS
  'phase_overdue_desc': "Phase '{phase}' should have ended on {date}",
  'phase_approaching_desc': "Phase '{phase}' ends on {date}",
  'phase_not_started_desc':
      "Mandatory phase '{phase}' has no dates defined yet",
  'phase_no_end_date_desc':
      "Phase '{phase}' started {days} days ago but has no end date",

  // Modules
  'as_built': 'As-Built',
  'installation': 'Installation',
  'installation_module': 'Installation Module',

  // Navigation,
  'reports': 'Reports',
  'team': 'Team',
  'help': 'Help',

  // Installation Module Tabs
  'schedule': 'Schedule',
  'teams': 'Teams',
  'materials': 'Materials',
  'quality_control': 'Quality Control',

  // Installation Status
  'scheduled': 'Scheduled',
  'active': 'Active',
  'standby': 'Standby',

  // Materials
  'in_stock': 'In Stock',
  'low_stock': 'Low Stock',
  'out_of_stock': 'Out of Stock',

  // Quality
  'approved': 'Approved',
  'rejected': 'Rejected',
  'inspector': 'Inspector',
  'inspection_date': 'Inspection Date',

  // Messages
  'coming_soon': 'Coming Soon',
  'coming_soon_message':
      'This feature is under development and will be available soon!',
  'confirm_logout': 'Confirm Logout',
  'confirm_logout_message': 'Are you sure you want to logout?',

  // Help
  'help_center': 'Help Center',
  'phone': 'Phone',
  'documentation': 'Documentation',

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

  // Phases
  'phase_reception': 'Reception',
  'phase_installation': 'Installation',
  'phase_electrical': 'Electrical',

  // Status
  'status_completed': 'Completed',
  'status_in_progress': 'In Progress',
  'status_pending': 'Pending',
  'inProgress': 'In Progress',
  'na': 'N/A',

  // Phase tasks
  'reception_checklist': 'Reception Checklist',
  'pre_installation_tasks': 'Pre-Installation Tasks',
  'installation_tasks': 'Installation Tasks',
  'electrical_tasks': 'Electrical Tasks',
  'commissioning_tasks': 'Commissioning Tasks',

  // Components
  'site_preparation': 'Site Preparation',
  'foundation_check': 'Foundation Check',
  'crane_setup': 'Crane Setup',
  'tower_installation': 'Tower Installation',
  'nacelle_installation': 'Nacelle Installation',
  'rotor_installation': 'Rotor Installation',
  'cable_installation': 'Cable Installation',
  'transformer_connection': 'Transformer Connection',
  'electrical_tests': 'Electrical Tests',
  'functional_tests': 'Functional Tests',
  'safety_checks': 'Safety Checks',
  'final_inspection': 'Final Inspection',

  // Reception
  'received': 'Received',
  'pending_reception': 'Pending Reception',

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
  'pre_assembly': 'Pre-Assembly',
  'assembly': 'Assembly',
  'final_phases': 'Final Phases',

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
  // 📝 FIELDS AND ACTIONS
  // ────────────────────────────────────────────────────────────────────────
  'item_name': 'Item Name',
  'add': 'Add',
  'item_number': 'Item Number',
  'serial_number': 'Serial Number',
  'add_photo': 'Add Photo',

  // Actions
  'mark_as_na': 'Mark as N/A',
  'mark_phase_na_confirm': 'Are you sure you want to mark as not applicable?',
  'data_saved_successfully': 'Data saved successfully!',

  // ────────────────────────────────────────────────────────────────────────
  // 📊 STATUS
  // ────────────────────────────────────────────────────────────────────────
  'blocked': 'Blocked',

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

  // ────────────────────────────────────────────────────────────────────────
  // 📈 PROGRESS
  // ────────────────────────────────────────────────────────────────────────
  'mark_if_not_installed':
      'Check if this component does not exist on this site',

  // ────────────────────────────────────────────────────────────────────────
  // 📝 FIELDS
  // ────────────────────────────────────────────────────────────────────────
  'no_notes': 'No notes',
  'no_photos': 'No photos',

  // ────────────────────────────────────────────────────────────────────────
  // 🔬 COMMISSIONING - MAIN PHASES
  // ────────────────────────────────────────────────────────────────────────
  'commissioning': 'Commissioning',
  'pre_commissioning_tests': 'Pre-Commissioning Tests',
  'final_acceptance': 'Final Acceptance',

  // ────────────────────────────────────────────────────────────────────────
  // 🔬 COMMISSIONING - SUB-PHASES
  // ────────────────────────────────────────────────────────────────────────
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

  // N/A
  'component_not_used': 'This component is not used',

  // Actions
  'component_updated_success': 'Component updated successfully!',

  // Replace
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

  // ════════════════════════════════════════════════════════════════════════
  // 🆕 FASE EDIT DIALOG - ADDITIONAL FIELDS
  // ════════════════════════════════════════════════════════════════════════
  'progresso': 'Progress',
  'guardar': 'Save',
  'cancelar': 'Cancel',
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
  'naoAplicavel': 'Not Applicable (N/A)',
  'faseNaoAplicavel': 'This phase is not applicable',
  'motivoNA': 'N/A Reason',
  'indiqueMotivoNA': 'Enter reason...',
  'motivoObrigatorio': 'Reason required',
  'adicionar': 'Add',
  'nenhumaFoto': 'No photos added',

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

  // ══════════════════════════════════════════════════════════════════════════
  // 📝 TRANSLATIONS FOR PROJECT CREATION WIZARD
  // ══════════════════════════════════════════════════════════════════════════

  // Tab 1 - New fields
  'address': 'Address',
  'gps_coordinates': 'GPS Coordinates',

  // Tab 2 - Phases
  'project_execution_phases': 'Project Execution Phases',
  'grid_availability_info': 'Estimated grid availability date',

  // Phase names (translated)
  'phase_mobilizacao': 'Project Start',
  'phase_fundacoes': 'Civil Works',
  'phase_instalacoes': 'Installations',
  'phase_logistica': 'Logistics',
  'phase_instalacao_eletrica': 'Electrical Installation',
  'phase_instalacao_mecanica': 'Mechanical Installation',
  'phase_comissionamento': 'Commissioning',
  'phase_testes': 'Testing',
  'phase_entrega': 'Handover',
  'phase_garantia': 'Warranty',
  'phase_facilities': 'Installations',

  // Turbine - Creation Dialog
  'number_of_middle_sections': 'Number of Middle Sections',
  'middle_section': 'Middle Section',
  'middle_sections': 'middle sections',
  'middle_sections_info': 'Define how many middle sections the tower has',
  'torqueTensioning': 'Torque & Tensioning',

  //Report
  'generate_report': 'Generate Report',
  'report_format': 'Report Format',
  'select_phases': 'Select Phases',
  'select_all': 'Select All',
  'clear_all': 'Clear All',
  'report_email_info': 'The report will be sent to your email',
  'generate_and_send': 'Generate and Send',
  'generating': 'Generating...',
  'report_sent_success': 'Report generated and sent successfully!',

  //Grua
  "register_activity": "Register Activity",
  "activity_type": "Activity Type",
  "mobilizacao": "Mobilization",
  "trabalho": "Effective Work",
  "paragem": "Downtime / Standby",
  "transferencia": "Pad-to-Pad Transfer",
  "desmobilizacao": "Demobilization",
  "wind": "High Wind",
  "mechanical": "Mechanical Breakdown",
  "waiting_components": "Waiting for Components",
  "safety": "Safety/HSE",
  "origin_pad": "Origin Pad",
  "destination_pad": "Destination Pad",
  "logistics_crane": "Logistics & Cranes",

  // Mobile Buttons - Installation
  'logout_confirmation': 'Are you sure you want to logout?',
  'no_projects_available': 'No projects available',

  // ════════════════════════════════════════════════════════════════════════
  // 🏗️ CRANE SYSTEM (NEW)
  // ════════════════════════════════════════════════════════════════════════

  // General
  'cranes': 'Cranes',
  'crane': 'Crane',
  'crane_management': 'Crane Management',
  'crane_management_subtitle': 'Manage cranes and log activities',
  'crane_activities': 'Crane Activities',

  // Crane List
  'no_cranes_yet': 'No cranes yet',
  'add_first_crane': 'Add the first crane for this project',
  'add_crane': 'Add Crane',
  'crane_model': 'Crane Model',
  'crane_model_required': 'Crane model is required',
  'multiple_cranes_info':
      'You can add multiple cranes. Each will have its own activity log.',
  'crane_added_success': 'Crane added successfully',

  // Delete Crane
  'delete_crane': 'Delete Crane',
  'delete_crane_confirm': 'Are you sure you want to delete the crane',
  'delete_crane_warning':
      'This action will delete the crane and ALL its activities. This operation cannot be undone.',
  'crane_deleted_success': 'Crane deleted successfully',

  // Activities
  'activities': 'activities',
  'no_activities_yet': 'No activities yet',
  'add_first_activity': 'Add the first activity for this crane',

  // Actions
  'delete_activity': 'Delete Activity',
  'delete_activity_confirm': 'Are you sure you want to delete this activity?',
  'activity_deleted_success': 'Activity deleted successfully',

  // ════════════════════════════════════════════════════════════════════════
  // 🌐 GENERAL PROJECT CRANES (not assigned to pads)
  // ════════════════════════════════════════════════════════════════════════

  // General
  'general_cranes': 'General Cranes',
  'general_crane': 'General Crane',
  'general_cranes_management': 'General Cranes Management',
  'general_cranes_subtitle': 'Cranes not assigned to any turbine',
  'general_crane_activities': 'General Crane Activities',

  // List
  'no_general_cranes_yet': 'No general cranes yet',
  'add_first_general_crane':
      'Add the first general crane for the project. These cranes are used for operations not assigned to any specific turbine.',
  'add_general_crane': 'Add General Crane',
  'general_cranes_info':
      'General cranes are used for project operations not linked to a specific turbine (e.g. transport, substation assembly, etc.)',
  'description_optional': 'Description (optional)',
  'crane_usage_example': 'E.g. Large component transport',

  // Success/Error
  'general_crane_added_success': 'General crane added successfully',
  'delete_general_crane': 'Delete General Crane',
  'general_crane_deleted_success': 'General crane deleted successfully',

  // ════════════════════════════════════════════════════════════════════════
  // 📊 REPORTS - CRANES
  // ════════════════════════════════════════════════════════════════════════

  'cranes_pads_report': 'Cranes (Pads)',
  'cranes_general_report': 'General Cranes',

  // ══════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ══════════════════════════════════════════════════════════════
  'email_phase_complete': 'Email when phase complete',
  'email_phase_complete_desc':
      'Receive email notification when completing a phase',
  'deadline_alerts': 'Deadline alerts',
  'deadline_alerts_desc': 'Notifications about upcoming deadlines',
  'turbine_changes': 'Turbine changes',
  'turbine_changes_desc': 'Notify when there are changes in turbines',
  'weekly_reports': 'Weekly reports',
  'weekly_reports_desc': 'Receive weekly summary by email',
  'date_format': 'Date Format',
  'theme': 'Theme',
  'light_theme': 'Light',
  'dark_theme': 'Dark',
  'data': 'Data',
  'export_all_data': 'Export all data',
  'export_all_data_desc': 'Complete download in JSON',
  'clear_cache': 'Clear cache',
  'clear_cache_desc': 'Free up storage space',
  'clear_cache_confirm': 'Are you sure you want to clear the cache?',
  'cache_cleared': 'Cache cleared successfully',
  'account': 'Account',
  'change_password': 'Change password',
  'change_password_desc': 'Change your login password',
  'clear': 'Clear',

// ══════════════════════════════════════════════════════════════
// TEAM MANAGEMENT SCREEN
// ══════════════════════════════════════════════════════════════
  'team_management': 'Team Management',
  'team_management_desc':
      'Manage companies and contractors involved in the project',
  'civil_construction': 'Civil Construction',
  'electrical': 'Electrical',
  'turbine_assembly': 'Turbine Assembly',
  'transport': 'Transport',
  'add_category': 'Add Category',
  'no_companies_yet': 'No companies added yet',
  'add_company': 'Add Company',
  'company_name': 'Company Name',
  'contact': 'Contact',
  'name_required': 'Name is required',
  'company_added': 'Company added successfully',
  'edit_company': 'Edit Company',
  'company_updated': 'Company updated',
  'delete_company': 'Delete Company',
  'delete_company_confirm': 'Are you sure you want to delete',
  'company_deleted': 'Company deleted',

  // ══════════════════════════════════════════════════════════════
  // HELP SCREEN
  // ══════════════════════════════════════════════════════════════
  'quick_start_guide': 'Quick Start Guide',
  'quick_start_guide_desc': 'First steps with the application',
  'how_to_add_turbines': 'How to add turbines',
  'how_to_add_turbines_desc': 'Step-by-step guide',
  'phase_management': 'Phase Management',
  'phase_management_desc': 'Manage installation phases',
  'reports_help': 'Reports',
  'reports_help_desc': 'How to generate and export reports',
  'cranes_logistics': 'Cranes & Logistics',
  'cranes_logistics_desc': 'Crane and transport management',
  'video_tutorials': 'Video Tutorials',
  'overview_video_desc': 'Application overview',
  'components_video_desc': 'Add and manage components',
  'reports_video_desc': 'Generate Excel and PDF reports',
  'support': 'Support',
  'contact_support': 'Contact Support',
  'live_chat': 'Live Chat',
  'online': 'Online',
  'avg_response_2min': 'Average response in 2 minutes',
  'report_bug': 'Report Bug',
  'report_bug_desc': 'Help us improve',
  'about': 'About',
  'wind_turbine_installation': 'Wind Turbine Installation',
  'version': 'Version',
  'updated': 'Updated',
  'terms_of_service': 'Terms of Service',
  'privacy_policy': 'Privacy Policy',
  'licenses': 'Licenses',
  'updates': 'Updates',
  'app_up_to_date': 'App is up to date',
  'check_updates': 'Check for updates',
  'keyboard_shortcuts': 'Keyboard Shortcuts',
  'search': 'Search',
  'print': 'Print',
  'undo': 'Undo',
  'redo': 'Redo',
  'view_all_shortcuts': 'View all shortcuts',
  'opening_video': 'Opening video',
  'opening': 'Opening',
  'bug_title': 'Bug Title',
  'bug_description': 'Description',
  'bug_reported': 'Bug reported successfully',
  'submit': 'Submit',
  'full_docs_available': 'Full documentation available online',
  'checking_updates': 'Checking for updates...',

  // Documentation contents (basic examples)
  'quick_start_content':
      'Welcome to As-Built! This application allows you to manage wind turbine installation efficiently.\n\n1. Create a new project\n2. Add turbines\n3. Register installation phases\n4. Generate reports',
  'add_turbines_content':
      'To add a turbine:\n\n1. Click the + button in the bottom right corner\n2. Fill in the name (e.g.: WTG-01)\n3. Select the turbine type\n4. Click Create',
  'phases_content':
      'Installation phases are:\n\n• Reception\n• Preparation\n• Pre-Assembly\n• Assembly\n• Torque & Tensioning\n• Final Phases',
  'reports_content':
      'To generate reports:\n\n1. Click the reports button\n2. Select desired phases\n3. Choose Excel or PDF\n4. Click Generate',
  'cranes_content':
      'Manage cranes:\n\n1. Access the Cranes menu\n2. Register mobilizations/demobilizations\n3. Track activities\n4. Generate specific reports',

  // ══════════════════════════════════════════════════════════════
  // 🆕 TRADUÇÕES ADICIONAIS
  // ══════════════════════════════════════════════════════════════
  'light_theme_enabled': 'Light theme enabled',
  'dark_theme_enabled': 'Dark theme enabled',
  'switch_to_light': 'Switch to Light Theme',
  'switch_to_dark': 'Switch to Dark Theme',
  'theme_changed': 'Theme changed successfully',
  'date_format_changed': 'Date format changed successfully',
  'select_date_format': 'Select Date Format',
  'date_format_ddmmyyyy': 'DD/MM/YYYY',
  'date_format_mmddyyyy': 'MM/DD/YYYY',
  'date_format_yyyymmdd': 'YYYY/MM/DD',
  'date_format_info':
      'This will change how dates are displayed throughout the app',
  'date_format_example': 'Example: {date}',
  'export_data_success': 'Data exported successfully',
  'export_data_error': 'Error exporting data',
  'exporting': 'Exporting...',
  'data_exported': 'Data exported successfully',
  'data_export_error': 'Error exporting data',
  'data_export_info':
      'The exported data is in JSON format and contains all your projects, turbines, components, and phases.',
  'export': 'Export',
  'export_data': 'Export Data',
  'export_data_desc': 'Export all your data in JSON format',
  'export_data_confirm':
      'Are you sure you want to export all data? This may take a few moments.',
  'exporting_data': 'Exporting data...',
  'data_export_complete': 'Data export complete',
  'data_export_failed': 'Data export failed',
  'view_details': 'View Details',
  'error_occurred': 'An error occurred',
  'please_try_again': 'Please try again later',
  'ok': 'OK',
  'update': 'Update',
  'saving': 'Saving',
  'search_placeholder': 'Search...',
  'no_results_found': 'No results found',
  'try_again_later': 'Try again later',
  'productivity_shortcuts': 'Productivity Shortcuts',
  'navigation_shortcuts': 'Navigation Shortcuts',
  'appearance_shortcuts': 'Appearance Shortcuts',
  'toggle_language': 'Toggle Language',
  'toggle_theme': 'Toggle Theme',
  'shortcuts_tip':
      'Tip: Use these shortcuts to navigate faster through the app!',
  'select_project_first': 'Select a project first',
  'dark_theme_activated': 'Dark theme activated',
  'light_theme_activated': 'Light theme activated',
};
