import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Configurações de Notificações do Utilizador
class NotificationSettings {
  // Ativar/Desativar globalmente
  final bool enabled;

  // Ativar por tipo
  final bool phaseAlerts;
  final bool componentAlerts;
  final bool turbineAlerts;

  // UI
  final bool showBadge; // Mostrar badge no AppBar
  final bool showInDashboard; // Mostrar cards no Dashboard

  // Thresholds (dias)
  final int daysBeforePhaseWarning; // Avisar X dias antes do prazo
  final int daysComponentStalled; // Componente sem progresso há X dias
  final int daysTurbineStalled; // Turbina sem progresso há X dias

  // Projetos silenciados (projectId -> data até quando)
  final Map<String, DateTime> mutedProjects;

  // Alertas dispensados (notificationId)
  final Set<String> dismissedAlerts;

  NotificationSettings({
    this.enabled = true,
    this.phaseAlerts = true,
    this.componentAlerts = true,
    this.turbineAlerts = true,
    this.showBadge = true,
    this.showInDashboard = true,
    this.daysBeforePhaseWarning = 7,
    this.daysComponentStalled = 30,
    this.daysTurbineStalled = 60,
    this.mutedProjects = const {},
    this.dismissedAlerts = const {},
  });

  /// Copy with
  NotificationSettings copyWith({
    bool? enabled,
    bool? phaseAlerts,
    bool? componentAlerts,
    bool? turbineAlerts,
    bool? showBadge,
    bool? showInDashboard,
    int? daysBeforePhaseWarning,
    int? daysComponentStalled,
    int? daysTurbineStalled,
    Map<String, DateTime>? mutedProjects,
    Set<String>? dismissedAlerts,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      phaseAlerts: phaseAlerts ?? this.phaseAlerts,
      componentAlerts: componentAlerts ?? this.componentAlerts,
      turbineAlerts: turbineAlerts ?? this.turbineAlerts,
      showBadge: showBadge ?? this.showBadge,
      showInDashboard: showInDashboard ?? this.showInDashboard,
      daysBeforePhaseWarning:
          daysBeforePhaseWarning ?? this.daysBeforePhaseWarning,
      daysComponentStalled: daysComponentStalled ?? this.daysComponentStalled,
      daysTurbineStalled: daysTurbineStalled ?? this.daysTurbineStalled,
      mutedProjects: mutedProjects ?? this.mutedProjects,
      dismissedAlerts: dismissedAlerts ?? this.dismissedAlerts,
    );
  }

  /// Verificar se projeto está silenciado
  bool isProjectMuted(String projectId) {
    final muteUntil = mutedProjects[projectId];
    if (muteUntil == null) return false;

    // Se a data já passou, não está mais silenciado
    if (DateTime.now().isAfter(muteUntil)) {
      return false;
    }

    return true;
  }

  /// Verificar se alerta foi dispensado
  bool isAlertDismissed(String alertId) {
    return dismissedAlerts.contains(alertId);
  }

  /// Silenciar projeto por X dias
  NotificationSettings muteProject(String projectId, int days) {
    final muteUntil = DateTime.now().add(Duration(days: days));
    final newMuted = Map<String, DateTime>.from(mutedProjects);
    newMuted[projectId] = muteUntil;

    return copyWith(mutedProjects: newMuted);
  }

  /// Reativar projeto
  NotificationSettings unmuteProject(String projectId) {
    final newMuted = Map<String, DateTime>.from(mutedProjects);
    newMuted.remove(projectId);

    return copyWith(mutedProjects: newMuted);
  }

  /// Dispensar alerta
  NotificationSettings dismissAlert(String alertId) {
    final newDismissed = Set<String>.from(dismissedAlerts);
    newDismissed.add(alertId);

    return copyWith(dismissedAlerts: newDismissed);
  }

  /// Limpar alertas dispensados antigos (> 30 dias)
  NotificationSettings cleanupDismissed() {
    // Manter só os últimos 100 alertas dispensados
    if (dismissedAlerts.length <= 100) {
      return this;
    }

    final newDismissed = dismissedAlerts
        .skip(dismissedAlerts.length - 100)
        .toSet();
    return copyWith(dismissedAlerts: newDismissed);
  }

  /// Limpar projetos silenciados expirados
  NotificationSettings cleanupMutedProjects() {
    final now = DateTime.now();
    final newMuted = Map<String, DateTime>.from(mutedProjects);
    newMuted.removeWhere((key, value) => now.isAfter(value));

    return copyWith(mutedProjects: newMuted);
  }

  /// Converter para Map (persistência)
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'phaseAlerts': phaseAlerts,
      'componentAlerts': componentAlerts,
      'turbineAlerts': turbineAlerts,
      'showBadge': showBadge,
      'showInDashboard': showInDashboard,
      'daysBeforePhaseWarning': daysBeforePhaseWarning,
      'daysComponentStalled': daysComponentStalled,
      'daysTurbineStalled': daysTurbineStalled,
      'mutedProjects': mutedProjects.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'dismissedAlerts': dismissedAlerts.toList(),
    };
  }

  /// Criar de Map
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] ?? true,
      phaseAlerts: map['phaseAlerts'] ?? true,
      componentAlerts: map['componentAlerts'] ?? true,
      turbineAlerts: map['turbineAlerts'] ?? true,
      showBadge: map['showBadge'] ?? true,
      showInDashboard: map['showInDashboard'] ?? true,
      daysBeforePhaseWarning: map['daysBeforePhaseWarning'] ?? 7,
      daysComponentStalled: map['daysComponentStalled'] ?? 30,
      daysTurbineStalled: map['daysTurbineStalled'] ?? 60,
      mutedProjects:
          (map['mutedProjects'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DateTime.parse(value as String)),
          ) ??
          {},
      dismissedAlerts:
          (map['dismissedAlerts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
    );
  }

  /// Converter para JSON
  String toJson() => json.encode(toMap());

  /// Criar de JSON
  factory NotificationSettings.fromJson(String source) {
    return NotificationSettings.fromMap(json.decode(source));
  }

  /// Salvar no SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_settings', toJson());
  }

  /// Carregar do SharedPreferences
  static Future<NotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('notification_settings');

    if (jsonString == null) {
      return NotificationSettings(); // Default
    }

    try {
      return NotificationSettings.fromJson(jsonString);
    } catch (e) {
      print('❌ Erro ao carregar settings: $e');
      return NotificationSettings(); // Default em caso de erro
    }
  }

  /// Limpar (resetar para padrão)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_settings');
  }
}
