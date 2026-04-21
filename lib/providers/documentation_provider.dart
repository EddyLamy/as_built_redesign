// lib/providers/documentation_provider.dart
// ignore_for_file: unnecessary_import

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/documentation.dart';
import '../services/documentation_service.dart';

part 'documentation_provider.g.dart';

// ─── Service ──────────────────────────────────────────────────────────────────

@riverpod
DocumentationService documentationService(Ref ref) {
  return DocumentationService();
}

// ─── Stream em tempo real ──────────────────────────────────────────────────────

@riverpod
Stream<List<Documentation>> documentationStream(Ref ref) {
  final service = ref.watch(documentationServiceProvider);
  return service.getDocumentsStream();
}

// ─── Filtro de documentação ────────────────────────────────────────────────────

class DocFilter {
  final String searchQuery;
  final DocumentCategory? selectedCategory;
  final String? selectedTag;

  const DocFilter({
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedTag,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty || selectedCategory != null || selectedTag != null;

  DocFilter copyWith({
    String? searchQuery,
    DocumentCategory? selectedCategory,
    bool clearCategory = false,
    String? selectedTag,
    bool clearTag = false,
  }) {
    return DocFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : selectedCategory ?? this.selectedCategory,
      selectedTag: clearTag ? null : selectedTag ?? this.selectedTag,
    );
  }
}

// ─── Notifier do filtro (usando @riverpod) ─────────────────────────────────────

@riverpod
class DocFilterNotifier extends _$DocFilterNotifier {
  @override
  DocFilter build() => const DocFilter();

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void setCategory(DocumentCategory? cat) =>
      state = state.copyWith(selectedCategory: cat, clearCategory: cat == null);

  void setTag(String? tag) =>
      state = state.copyWith(selectedTag: tag, clearTag: tag == null);

  void clearFilters() => state = const DocFilter();
}

// ─── Lista filtrada ────────────────────────────────────────────────────────────

@riverpod
AsyncValue<List<Documentation>> filteredDocuments(Ref ref) {
  final docsAsync = ref.watch(documentationStreamProvider);
  final filter = ref.watch(docFilterProvider);

  return docsAsync.whenData((docs) {
    var result = docs;

    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      result = result.where((d) {
        return d.title.toLowerCase().contains(q) ||
            d.documentId.toLowerCase().contains(q) ||
            d.fileName.toLowerCase().contains(q) ||
            d.tags.any((t) => t.toLowerCase().contains(q)) ||
            (d.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (filter.selectedCategory != null) {
      result =
          result.where((d) => d.category == filter.selectedCategory).toList();
    }

    if (filter.selectedTag != null) {
      result =
          result.where((d) => d.tags.contains(filter.selectedTag)).toList();
    }

    return result;
  });
}

// ─── Agrupado por categoria ────────────────────────────────────────────────────

@riverpod
AsyncValue<Map<DocumentCategory, List<Documentation>>> groupedDocuments(
    Ref ref) {
  final filteredAsync = ref.watch(filteredDocumentsProvider);
  return filteredAsync.whenData((docs) {
    final Map<DocumentCategory, List<Documentation>> grouped = {};
    for (final doc in docs) {
      grouped.putIfAbsent(doc.category, () => []).add(doc);
    }
    return grouped;
  });
}

// ─── Todas as tags (para filtro) ──────────────────────────────────────────────

@riverpod
List<String> allTags(Ref ref) {
  final docsAsync = ref.watch(documentationStreamProvider);
  return docsAsync.maybeWhen(
    data: (docs) {
      final tags = <String>{};
      for (final d in docs) {
        tags.addAll(d.tags);
      }
      return tags.toList()..sort();
    },
    orElse: () => [],
  );
}
