// lib/screens/documentation/documentation_screen.dart

import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/documentation.dart';
import '../../providers/documentation_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/documentation/document_card.dart';
import '../../widgets/add_document_dialog.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';

class DocumentationScreen extends ConsumerStatefulWidget {
  /// Passa o projectId atual. Se null, mostra todos os documentos.
  final String? projectId;

  const DocumentationScreen({super.key, this.projectId});

  @override
  ConsumerState<DocumentationScreen> createState() =>
      _DocumentationScreenState();
}

class _DocumentationScreenState extends ConsumerState<DocumentationScreen> {
  final _searchController = TextEditingController();
  bool _groupByCategory = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // TODO: substitui por uma verificação real do role do utilizador
  // ex: ref.read(userRoleProvider) == 'site_manager'
  bool get _isManager => true;

  void _showAddDialog() {
    showLiquidDialog(
      context: context,
      builder: (_) => AddDocumentDialog(
        projectId: widget.projectId ?? '',
      ),
    );
  }

  Future<void> _deleteDocument(String documentId) async {
    try {
      await ref.read(documentationServiceProvider).deleteDocument(documentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento eliminado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao eliminar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final filter = ref.watch(docFilterProvider);
    final allTags = ref.watch(allTagsProvider);
    final documentsAsync = ref.watch(filteredDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Text(t.translate('documentation')),
        ),
        actions: [
          IconButton(
            icon: Icon(_groupByCategory ? Icons.view_list : Icons.folder_copy),
            tooltip: _groupByCategory
                ? t.translate('view_as_list')
                : t.translate('group_by_category'),
            onPressed: () =>
                setState(() => _groupByCategory = !_groupByCategory),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filtros ─────────────────────────────────────────────────────
          _FilterBar(
            searchController: _searchController,
            filter: filter,
            allTags: allTags,
            t: t,
            onSearch: (q) =>
                ref.read(docFilterProvider.notifier).setSearchQuery(q),
            onClearSearch: () {
              _searchController.clear();
              ref.read(docFilterProvider.notifier).setSearchQuery('');
            },
            onCategorySelected: (cat) =>
                ref.read(docFilterProvider.notifier).setCategory(cat),
            onTagSelected: (tag) =>
                ref.read(docFilterProvider.notifier).setTag(tag),
          ),

          // ─── Contador e limpar filtros ────────────────────────────────────
          documentsAsync.when(
            data: (docs) => _CountBar(
              count: docs.length,
              hasFilters: filter.hasActiveFilters,
              t: t,
              onClear: () {
                _searchController.clear();
                ref.read(docFilterProvider.notifier).clearFilters();
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // ─── Conteúdo principal ───────────────────────────────────────────
          Expanded(
            child: documentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text('${t.translate('error')}: $e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              data: (docs) {
                if (docs.isEmpty) {
                  return _EmptyState(
                    hasFilters: filter.hasActiveFilters,
                    t: t,
                    onAdd: _isManager ? _showAddDialog : null,
                  );
                }

                if (_groupByCategory) {
                  return _GroupedListView(
                    documents: docs,
                    canDelete: _isManager,
                    onDelete: _deleteDocument,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => DocumentCard(
                    document: docs[i],
                    canDelete: _isManager,
                    onDelete: () => _deleteDocument(docs[i].documentId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isManager
          ? FloatingActionButton.extended(
              onPressed: _showAddDialog,
              tooltip: t.translate('add_document'),
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.upload_file),
              label: Text(t.translate('add')),
            )
          : null,
    );
  }
}

// ─── Barra de filtros ──────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final DocFilter filter;
  final List<String> allTags;
  final TranslationHelper t;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSearch;
  final ValueChanged<DocumentCategory?> onCategorySelected;
  final ValueChanged<String?> onTagSelected;

  const _FilterBar({
    required this.searchController,
    required this.filter,
    required this.allTags,
    required this.t,
    required this.onSearch,
    required this.onClearSearch,
    required this.onCategorySelected,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        children: [
          // Pesquisa
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: t.translate('search_documents_hint'),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? Tooltip(
                      message: t.translate('clear_search'),
                      child: IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: onClearSearch,
                      ),
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: onSearch,
          ),
          const SizedBox(height: 8),

          // Chips de categoria
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // "Todos"
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(t.translate('all')),
                    selected: filter.selectedCategory == null &&
                        filter.selectedTag == null,
                    onSelected: (_) {
                      onCategorySelected(null);
                      onTagSelected(null);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ),

                // Categorias
                ...DocumentCategory.values.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text('${cat.icon} ${cat.label}'),
                        selected: filter.selectedCategory == cat,
                        onSelected: (sel) =>
                            onCategorySelected(sel ? cat : null),
                        visualDensity: VisualDensity.compact,
                      ),
                    )),

                // Tags (se existirem)
                if (allTags.isNotEmpty) ...[
                  const VerticalDivider(width: 16),
                  ...allTags.take(8).map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text('#$tag'),
                          selected: filter.selectedTag == tag,
                          onSelected: (sel) => onTagSelected(sel ? tag : null),
                          visualDensity: VisualDensity.compact,
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barra de contagem ─────────────────────────────────────────────────────────

class _CountBar extends StatelessWidget {
  final int count;
  final bool hasFilters;
  final TranslationHelper t;
  final VoidCallback onClear;

  const _CountBar({
    required this.count,
    required this.hasFilters,
    required this.t,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.glassBorderLight),
          bottom: BorderSide(color: AppColors.glassBorderLight),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? t.translate('document') : t.translate('documents')}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: t.translate('clear_filters'),
              child: GestureDetector(
                onTap: onClear,
                child: Row(
                  children: [
                    Icon(Icons.clear, size: 13, color: Colors.blue.shade700),
                    const SizedBox(width: 2),
                    Text(t.translate('clear_filters'),
                        style: TextStyle(
                            fontSize: 12, color: Colors.blue.shade700)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Lista agrupada por categoria ──────────────────────────────────────────────

class _GroupedListView extends StatelessWidget {
  final List<Documentation> documents;
  final bool canDelete;
  final Future<void> Function(String) onDelete;

  const _GroupedListView({
    required this.documents,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Map<DocumentCategory, List<Documentation>> grouped = {};
    for (final doc in documents) {
      grouped.putIfAbsent(doc.category, () => []).add(doc);
    }
    // Ordenar por número de docs
    final categories = grouped.keys.toList()
      ..sort((a, b) => grouped[b]!.length.compareTo(grouped[a]!.length));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: categories.length,
      itemBuilder: (_, i) => _CategorySection(
        category: categories[i],
        documents: grouped[categories[i]]!,
        canDelete: canDelete,
        onDelete: onDelete,
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final DocumentCategory category;
  final List<Documentation> documents;
  final bool canDelete;
  final Future<void> Function(String) onDelete;

  const _CategorySection({
    required this.category,
    required this.documents,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(widget.category.icon,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(widget.category.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                _CountBadge(count: widget.documents.length),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        if (_expanded)
          ...widget.documents.map((doc) => DocumentCard(
                document: doc,
                canDelete: widget.canDelete,
                onDelete: () => widget.onDelete(doc.documentId),
              )),

        const Divider(height: 1),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$count',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final TranslationHelper t;
  final VoidCallback? onAdd;

  const _EmptyState({required this.hasFilters, required this.t, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? t.translate('no_documents_found')
                : t.translate('no_documents_registered'),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          if (!hasFilters)
            Text(
              t.translate('add_first_document_hint'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          if (onAdd != null && !hasFilters) ...[
            const SizedBox(height: 16),
            Tooltip(
              message: t.translate('add_document'),
              child: GradientButton(
                onPressed: onAdd,
                icon: Icons.upload_file,
                label: t.translate('add_document'),
                isSmall: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
