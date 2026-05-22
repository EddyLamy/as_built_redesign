import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/safety_alert.dart';
import '../services/safety_alert_pdf_export_service.dart';
import '../services/safety_alert_service.dart';

final safetyAlertServiceProvider = Provider<SafetyAlertService>((ref) {
  return SafetyAlertService();
});

final safetyAlertPdfExportServiceProvider =
    Provider<SafetyAlertPdfExportService>((ref) {
  return SafetyAlertPdfExportService();
});

final projectSafetyAlertsProvider =
    StreamProvider.family<List<SafetyAlertRecord>, String>((ref, projectId) {
  final service = ref.watch(safetyAlertServiceProvider);
  return service.watchProjectAlerts(projectId);
});

class SafetyAlertSummary {
  const SafetyAlertSummary({
    required this.total,
    required this.resolved,
    required this.underStudy,
    required this.inResolution,
    required this.futureCompanyAction,
  });

  final int total;
  final int resolved;
  final int underStudy;
  final int inResolution;
  final int futureCompanyAction;
}

final projectSafetyAlertSummaryProvider =
    Provider.family<AsyncValue<SafetyAlertSummary>, String>((ref, projectId) {
  final alertsAsync = ref.watch(projectSafetyAlertsProvider(projectId));

  return alertsAsync.whenData((alerts) {
    return SafetyAlertSummary(
      total: alerts.length,
      resolved: alerts
          .where((item) => item.status == SafetyAlertStatus.resolved)
          .length,
      underStudy: alerts
          .where((item) => item.status == SafetyAlertStatus.underStudy)
          .length,
      inResolution: alerts
          .where((item) => item.status == SafetyAlertStatus.inResolution)
          .length,
      futureCompanyAction: alerts
          .where(
            (item) => item.status == SafetyAlertStatus.futureCompanyAction,
          )
          .length,
    );
  });
});
