import 'package:flutter/material.dart';
import 'translations_pt.dart';
import 'translations_en.dart';

const Map<String, String> _runtimePtOverrides = {
  'daily_journal_people_hours': 'Pessoas 2WindService / Horas',
  'daily_journal_waiting_time': 'Tempos de Espera e Horas Extra',
  'daily_journal_wind_measurements': 'Medições de Vento',
  'company': 'Empresa',
  'description': 'Descrição',
  'total_hours': 'Horas Totais',
  'wind_photo_helper':
      'As fotos de confirmação não são armazenadas na app nesta fase.',
  'manual_excel_photo_note': 'Fotos tratadas manualmente no Excel.',
  'manual_excel_photo_note_detail':
      'Se precisares de anexar evidência para este horário, adiciona a foto diretamente no ficheiro Excel exportado.',
  'ncr_linked_turbine': 'Torre associada',
  'ncr_due_date': 'Data limite',
  'ncr_assigned_to': 'Atribuída a',
  'ncr_description': 'Descrição detalhada',
  'ncr_category': 'Categoria',
  'ncr_severity': 'Severidade',
  'ncr_search_hint': 'Pesquisar por código, título, turbina ou responsável',
  'ncr_empty': 'Ainda não existem NCRs para este projeto.',
  'ncr_empty_turbine': 'Ainda não existem NCRs registadas para esta torre.',
  'ncr_total': 'Total',
  'ncr_open_count': 'Abertas',
  'ncr_in_progress_count': 'Em curso',
  'ncr_overdue_count': 'Em atraso',
  'ncr_critical_count': 'Críticas',
  'ncr_overdue_only': 'Só em atraso',
  'ncr_status_open': 'Aberta',
  'ncr_status_in_progress': 'Em curso',
  'ncr_status_pending_validation': 'Validação pendente',
  'ncr_status_resolved': 'Resolvida',
  'ncr_status_closed': 'Fechada',
  'ncr_severity_low': 'Baixa',
  'ncr_severity_medium': 'Média',
  'ncr_severity_high': 'Alta',
  'ncr_severity_critical': 'Crítica',
  'ncr_category_quality': 'Qualidade',
  'ncr_category_mechanical': 'Mecânica',
  'ncr_category_electrical': 'Elétrica',
  'ncr_category_civil': 'Civil',
  'ncr_category_safety': 'Segurança',
  'ncr_category_logistics': 'Logística',
  'ncr_category_documentation': 'Documentação',
  'ncr_category_other': 'Outro',
  'ncr_unassigned': 'Sem responsável',
  'ncr_status_history': 'Histórico de estados',
  'ncr_no_history': 'Ainda não existem alterações de estado registadas.',
  'ncr_status_change_note': 'Nota de alteração de estado',
  'ncr_status_note_required': 'Indique o motivo da alteração de estado.',
  'ncr_initial_note': 'Nota inicial (opcional)',
  'ncr_created_history_note': 'NCR criada',
  'ncr_closure_note': 'Nota de fecho',
  'ncr_closure_note_required': 'O fecho formal exige uma nota de fecho.',
  'ncr_closed_by': 'Fechada por',
  'ncr_pdf_document': 'Documento NCR',
  'ncr_current_status': 'Estado atual',
  'ncr_generated_at': 'Gerado em',
  'ncr_updated_at': 'Atualizada em',
  'ncr_status_timeline': 'Linha temporal de estados',
  'ncr_evidence_images': 'Evidências fotográficas',
  'ncr_attachments': 'Anexos adicionais',
  'ncr_no_images': 'Sem imagens anexadas a esta NCR.',
  'ncr_no_attachments': 'Sem anexos adicionais.',
  'ncr_pdf_saved': 'PDF da NCR guardado com sucesso.',
  'ncr_pdf_error': 'Não foi possível gerar o PDF da NCR.',
  'open_in_maps': 'Abrir no mapa',
  'unable_to_open_map': 'Não foi possível abrir o mapa.',
  'project_gps_coordinates': 'Coordenadas GPS do projeto',
  'office_gps_coordinates': 'Coordenadas GPS do escritório',
  'enter_or_pick_coordinates': 'Introduza manualmente ou selecione no mapa.',
  'pick_on_map': 'Selecionar no mapa',
  'map_picker_title': 'Selecionar coordenadas no mapa',
  'map_picker_subtitle':
      'Clique no mapa para definir as coordenadas ou escreva-as manualmente.',
  'map_picker_no_selection': 'Nenhuma coordenada selecionada.',
  'office_coordinates_optional':
      'Opcional. Use este campo quando o escritório/base estiver noutro local.',
  'clear_selection': 'Limpar seleção',
  'safety_alerts': 'SGI',
  'safety_alert_management': 'Sistema de Gestão de Incidentes (SGI)',
  'safety_alert_new': 'Novo registo SGI',
  'safety_alert_category': 'Categoria',
  'safety_alert_destination_to': 'Destinado a',
  'safety_alert_department': 'Departamento',
  'safety_alert_problem_description': 'Descrição da situação/problema',
  'safety_alert_possible_solution': 'Possível solução',
  'safety_alert_resolucao_efetuada': 'Ação corretiva aplicada',
  'safety_alert_status': 'Estado do problema',
  'safety_alert_photos': 'Fotos',
  'safety_alert_resolution_photos': 'Fotos da resolução',
  'safety_alert_add_photos': 'Adicionar fotos',
  'safety_alert_photos_hint':
      'Pode anexar até 3 fotos de evidência para cada alerta.',
  'safety_alert_resolution_photos_hint':
      'Pode anexar até 3 fotos da resolução do problema.',
  'safety_alert_max_photos_reached':
      'O máximo de 3 fotos por alerta já foi atingido.',
  'safety_alert_created_success': 'Registo SGI criado com sucesso.',
  'safety_alert_updated_success': 'Registo SGI atualizado com sucesso.',
  'safety_alert_deleted_success': 'Registo SGI removido com sucesso.',
  'safety_alert_delete_confirm':
      'Tem a certeza de que pretende eliminar este registo SGI?',
  'safety_alert_empty': 'Ainda não existem registos SGI para este projeto.',
  'safety_alert_search_hint':
      'Pesquisar por código, descrição do problema ou solução proposta',
  'safety_alert_export_saved': 'PDF do registo SGI guardado com sucesso.',
  'safety_alert_export_error': 'Não foi possível gerar o PDF do registo SGI.',
  'safety_alert_print': 'Imprimir',
  'safety_alert_total': 'Total',
  'safety_alert_created_at': 'Criado em',
  'safety_alert_updated_at': 'Atualizado em',
  'safety_alert_category_near_miss': 'Near Miss',
  'safety_alert_category_hazardous_observation': 'Alerta de Segurança',
  'safety_alert_category_walk_and_talk': 'Walk and Talk',
  'safety_alert_status_resolved': 'Resolvido',
  'safety_alert_status_under_study': 'Em estudo',
  'safety_alert_status_in_resolution': 'Em fase de resolução',
  'safety_alert_status_future_company_action':
      'Requer ação futura da companhia',
  'safety_alert_status_requires_action': 'Requer ação',
  'export': 'Exportar',
  'all': 'Todos',
};

const Map<String, String> _runtimeEnOverrides = {
  'daily_journal_people_hours': '2WindService People / Hours',
  'daily_journal_waiting_time': 'Waiting Time and Overtime',
  'daily_journal_wind_measurements': 'Wind Measurements',
  'company': 'Company',
  'description': 'Description',
  'total_hours': 'Total Hours',
  'wind_photo_helper':
      'Confirmation photos are not stored in the app at this stage.',
  'manual_excel_photo_note': 'Photos are handled manually in Excel.',
  'manual_excel_photo_note_detail':
      'If evidence is needed for this time slot, add the photo directly in the exported Excel file.',
  'ncr_linked_turbine': 'Linked turbine',
  'ncr_due_date': 'Due date',
  'ncr_assigned_to': 'Assigned to',
  'ncr_description': 'Detailed description',
  'ncr_category': 'Category',
  'ncr_severity': 'Severity',
  'ncr_search_hint': 'Search by code, title, turbine or owner',
  'ncr_empty': 'There are no NCRs for this project yet.',
  'ncr_empty_turbine': 'There are no NCRs registered for this turbine yet.',
  'ncr_total': 'Total',
  'ncr_open_count': 'Open',
  'ncr_in_progress_count': 'In progress',
  'ncr_overdue_count': 'Overdue',
  'ncr_critical_count': 'Critical',
  'ncr_overdue_only': 'Overdue only',
  'ncr_status_open': 'Open',
  'ncr_status_in_progress': 'In progress',
  'ncr_status_pending_validation': 'Pending validation',
  'ncr_status_resolved': 'Resolved',
  'ncr_status_closed': 'Closed',
  'ncr_severity_low': 'Low',
  'ncr_severity_medium': 'Medium',
  'ncr_severity_high': 'High',
  'ncr_severity_critical': 'Critical',
  'ncr_category_quality': 'Quality',
  'ncr_category_mechanical': 'Mechanical',
  'ncr_category_electrical': 'Electrical',
  'ncr_category_civil': 'Civil',
  'ncr_category_safety': 'Safety',
  'ncr_category_logistics': 'Logistics',
  'ncr_category_documentation': 'Documentation',
  'ncr_category_other': 'Other',
  'ncr_unassigned': 'Unassigned',
  'ncr_status_history': 'Status history',
  'ncr_no_history': 'There are no status changes recorded yet.',
  'ncr_status_change_note': 'Status change note',
  'ncr_status_note_required': 'Add a reason for the status change.',
  'ncr_initial_note': 'Initial note (optional)',
  'ncr_created_history_note': 'NCR created',
  'ncr_closure_note': 'Closure note',
  'ncr_closure_note_required': 'Formal closure requires a closure note.',
  'ncr_closed_by': 'Closed by',
  'ncr_pdf_document': 'NCR document',
  'ncr_current_status': 'Current status',
  'ncr_generated_at': 'Generated at',
  'ncr_updated_at': 'Updated at',
  'ncr_status_timeline': 'Status timeline',
  'ncr_evidence_images': 'Photo evidence',
  'ncr_attachments': 'Additional attachments',
  'ncr_no_images': 'No images attached to this NCR.',
  'ncr_no_attachments': 'No additional attachments.',
  'ncr_pdf_saved': 'NCR PDF saved successfully.',
  'ncr_pdf_error': 'Unable to generate the NCR PDF.',
  'open_in_maps': 'Open in map',
  'unable_to_open_map': 'Unable to open the map.',
  'project_gps_coordinates': 'Project GPS coordinates',
  'office_gps_coordinates': 'Office GPS coordinates',
  'enter_or_pick_coordinates': 'Enter them manually or choose them on the map.',
  'pick_on_map': 'Pick on map',
  'map_picker_title': 'Pick coordinates on the map',
  'map_picker_subtitle':
      'Click on the map to set the coordinates or type them manually.',
  'map_picker_no_selection': 'No coordinates selected.',
  'office_coordinates_optional':
      'Optional. Use this field when the office/base is in a different place.',
  'clear_selection': 'Clear selection',
  'safety_alerts': 'IMS',
  'safety_alert_management': 'Incident Management System (IMS)',
  'safety_alert_new': 'New IMS record',
  'safety_alert_category': 'Category',
  'safety_alert_destination_to': 'Intended for',
  'safety_alert_department': 'Department',
  'safety_alert_problem_description': 'Problem situation description',
  'safety_alert_possible_solution': 'Possible solution',
  'safety_alert_resolucao_efetuada': 'Corrective action taken',
  'safety_alert_status': 'Problem status',
  'safety_alert_photos': 'Photos',
  'safety_alert_resolution_photos': 'Resolution photos',
  'safety_alert_add_photos': 'Add photos',
  'safety_alert_photos_hint':
      'You can attach up to 3 evidence photos to each alert.',
  'safety_alert_resolution_photos_hint':
      'You can attach up to 3 problem resolution photos to each alert.',
  'safety_alert_max_photos_reached':
      'The maximum of 3 photos per alert has already been reached.',
  'safety_alert_created_success': 'IMS record created successfully.',
  'safety_alert_updated_success': 'IMS record updated successfully.',
  'safety_alert_deleted_success': 'IMS record removed successfully.',
  'safety_alert_delete_confirm':
      'Are you sure you want to delete this IMS record?',
  'safety_alert_empty': 'There are no IMS records for this project yet.',
  'safety_alert_search_hint':
      'Search by code, problem description or proposed solution',
  'safety_alert_export_saved': 'IMS record PDF saved successfully.',
  'safety_alert_export_error': 'Unable to generate the IMS record PDF.',
  'safety_alert_print': 'Print',
  'safety_alert_total': 'Total',
  'safety_alert_created_at': 'Created at',
  'safety_alert_updated_at': 'Updated at',
  'safety_alert_category_near_miss': 'Near Miss',
  'safety_alert_category_hazardous_observation': 'Safety Alert',
  'safety_alert_category_walk_and_talk': 'Walk and Talk',
  'safety_alert_status_resolved': 'Resolved',
  'safety_alert_status_under_study': 'Under study',
  'safety_alert_status_in_resolution': 'In resolution',
  'safety_alert_status_future_company_action': 'Future company action required',
  'safety_alert_status_requires_action': 'Requires action',
  'export': 'Export',
  'all': 'All',
};

class TranslationHelper {
  final Locale locale;
  late Map<String, String> _translations;

  TranslationHelper(this.locale) {
    _translations =
        locale.languageCode == 'pt' ? translationsPT : translationsEN;
  }

  Map<String, String> get _runtimeOverrides =>
      locale.languageCode == 'pt' ? _runtimePtOverrides : _runtimeEnOverrides;

  String translate(String key) {
    return _runtimeOverrides[key] ??
        _translations[key] ??
        translationsPT[key] ??
        translationsEN[key] ??
        _runtimePtOverrides[key] ??
        _runtimeEnOverrides[key] ??
        key;
  }

  String translateValueOrKey(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return text;
    }

    final translatedFromKey = translate(normalized);
    if (translatedFromKey != normalized) {
      return translatedFromKey;
    }

    for (final entry in translationsEN.entries) {
      if (entry.value == normalized) {
        return translate(entry.key);
      }
    }

    for (final entry in translationsPT.entries) {
      if (entry.value == normalized) {
        return translate(entry.key);
      }
    }

    return text;
  }

  // Helper methods para traduzir valores específicos
  String translateStatus(String status) {
    final rawStatus = status.trim();

    if (rawStatus.isEmpty) {
      return translate('status_pending');
    }

    if (rawStatus.startsWith('status_')) {
      final directTranslation = translate(rawStatus);
      if (directTranslation != rawStatus) {
        return directTranslation;
      }
      return translateStatus(rawStatus.substring(7));
    }

    final directStatusKey = 'status_$rawStatus';
    final directStatusTranslation = translate(directStatusKey);
    if (directStatusTranslation != directStatusKey) {
      return directStatusTranslation;
    }

    final normalizedStatusKey = _normalizeStatusKey(rawStatus);
    final normalizedLookupKey = 'status_$normalizedStatusKey';
    final normalizedStatusTranslation = translate(normalizedLookupKey);
    if (normalizedStatusTranslation != normalizedLookupKey) {
      return normalizedStatusTranslation;
    }

    return rawStatus;
  }

  String _normalizeStatusKey(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'pending';
      case 'em progresso':
        return 'in_progress';
      case 'concluído':
      case 'concluido':
        return 'completed';
      case 'planejada':
        return 'Planejada';
      case 'em instalação':
        return 'Em Instalação';
      case 'instalada':
        return 'Instalada';
      case 'comissionada':
        return 'Comissionada';
      case 'em manutenção':
        return 'Em Manutenção';
      default:
        return status;
    }
  }

  static TranslationHelper of(BuildContext context) {
    return Localizations.of<TranslationHelper>(context, TranslationHelper)!;
  }
}

class TranslationDelegate extends LocalizationsDelegate<TranslationHelper> {
  const TranslationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en'].contains(locale.languageCode);
  }

  @override
  Future<TranslationHelper> load(Locale locale) async {
    return TranslationHelper(locale);
  }

  @override
  bool shouldReload(TranslationDelegate old) => true;
}
