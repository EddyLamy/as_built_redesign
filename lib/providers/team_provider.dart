// lib/providers/team_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../services/team_service.dart';

// ─── Service ──────────────────────────────────────────────────────────────────

final teamServiceProvider = Provider<TeamService>((ref) => TeamService());

// ─── Categorias (stream por projeto) ──────────────────────────────────────────

final teamCategoriesProvider =
    StreamProvider.autoDispose.family<List<TeamCategory>, String>(
  (ref, projectId) {
    final service = ref.watch(teamServiceProvider);
    return service.getCategoriesStream(projectId);
  },
);

// ─── Empresas (stream por categoria) ──────────────────────────────────────────

// Key: (projectId, categoryId)
typedef CompanyKey = ({String projectId, String categoryId});

final companiesProvider =
    StreamProvider.autoDispose.family<List<Company>, CompanyKey>(
  (ref, key) {
    final service = ref.watch(teamServiceProvider);
    return service.getCompaniesStream(key.projectId, key.categoryId);
  },
);

// ─── Pessoas (stream por empresa) ─────────────────────────────────────────────

typedef PeopleKey = ({String projectId, String categoryId, String companyId});

final peopleProvider =
    StreamProvider.autoDispose.family<List<CompanyPerson>, PeopleKey>(
  (ref, key) {
    final service = ref.watch(teamServiceProvider);
    return service.getPeopleStream(
        key.projectId, key.categoryId, key.companyId);
  },
);

// ─── Contagem total de empresas no projeto ─────────────────────────────────────

final totalCompaniesProvider =
    Provider.autoDispose.family<int, String>((ref, projectId) {
  final categoriesAsync = ref.watch(teamCategoriesProvider(projectId));
  return categoriesAsync.maybeWhen(
    data: (cats) => cats.fold<int>(0, (sum, cat) {
      final companiesAsync = ref
          .watch(companiesProvider((projectId: projectId, categoryId: cat.id)));
      return sum + (companiesAsync.asData?.value.length ?? 0);
    }),
    orElse: () => 0,
  );
});
