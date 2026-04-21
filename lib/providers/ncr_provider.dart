import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ncr.dart';
import '../services/ncr_pdf_export_service.dart';
import '../services/ncr_service.dart';

final ncrServiceProvider = Provider<NcrService>((ref) {
  return NcrService();
});

final ncrPdfExportServiceProvider = Provider<NcrPdfExportService>((ref) {
  return NcrPdfExportService();
});

final projectNcrsProvider =
    StreamProvider.family<List<NcrRecord>, String>((ref, projectId) {
  final service = ref.watch(ncrServiceProvider);
  return service.watchProjectNcrs(projectId);
});

final turbineNcrsProvider =
    StreamProvider.family<List<NcrRecord>, String>((ref, turbinaId) {
  final service = ref.watch(ncrServiceProvider);
  return service.watchTurbineNcrs(turbinaId);
});

class NcrSummary {
  const NcrSummary({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.overdue,
    required this.critical,
  });

  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int overdue;
  final int critical;
}

final projectNcrSummaryProvider =
    Provider.family<AsyncValue<NcrSummary>, String>((ref, projectId) {
  final ncrsAsync = ref.watch(projectNcrsProvider(projectId));

  return ncrsAsync.whenData((ncrs) {
    return NcrSummary(
      total: ncrs.length,
      open: ncrs.where((item) => item.status == NcrStatus.open).length,
      inProgress:
          ncrs.where((item) => item.status == NcrStatus.inProgress).length,
      resolved: ncrs
          .where(
            (item) =>
                item.status == NcrStatus.resolved ||
                item.status == NcrStatus.closed,
          )
          .length,
      overdue: ncrs.where((item) => item.isOverdue).length,
      critical:
          ncrs.where((item) => item.severity == NcrSeverity.critical).length,
    );
  });
});
