// lib/screens/team/team_management_screen.dart

import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/team.dart';
import '../../providers/team_provider.dart';

class TeamManagementScreen extends ConsumerWidget {
  final String projectId;

  const TeamManagementScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final categoriesAsync = ref.watch(teamCategoriesProvider(projectId));

    return Scaffold(
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${t.translate('error')}: $e')),
        data: (categories) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card
            Align(
              alignment: Alignment.centerLeft,
              child: Card(
                color: AppColors.primaryBlue.withValues(alpha: 0.06),
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.primaryBlue.withValues(alpha: 0.16),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.primaryBlue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        t.translate('team_management_desc'),
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Categorias vindas do Firebase
            ...categories.map((category) => _CategorySection(
                  key: ValueKey(category.id),
                  projectId: projectId,
                  category: category,
                )),

            const SizedBox(height: 96),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddCategoryDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(t.translate('add_category')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final nameController = TextEditingController();
    String selectedEmoji = '🏢';
    int selectedColor = 0xFF607D8B;

    const iconOptions = <MapEntry<String, String>>[
      MapEntry('🏢', 'Acampamento Base'),
      MapEntry('🏗️', 'Grua'),
      MapEntry('⚡', 'Elétrica'),
      MapEntry('🌀', 'Turbina'),
      MapEntry('🚛', 'Transporte'),
      MapEntry('✅', 'Site Supervisor'),
      MapEntry('🔧', 'Manutenção'),
      MapEntry('🔩', 'Montagem'),
      MapEntry('🏭', 'Comissionamento'),
      MapEntry('⛏️', 'Fundação'),
      MapEntry('🚧', 'Obra'),
      MapEntry('👷', 'Equipa de Campo'),
      MapEntry('🔌', 'Cablagem'),
      MapEntry('🛢️', 'Logística'),
    ];
    const colors = [
      0xFFFF9800,
      0xFFE53935,
      0xFF1976D2,
      0xFF00897B,
      0xFF43A047,
      0xFF8E24AA,
      0xFF607D8B,
      0xFFF57C00,
    ];

    showLiquidDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline,
                  color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Text(t.translate('new_category')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '${t.translate('category_name')} *',
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Emoji picker
                Text(t.translate('icon'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: iconOptions.map((option) {
                    final emoji = option.key;
                    final label = option.value;
                    final isSel = selectedEmoji == emoji;
                    return Tooltip(
                      message: label,
                      waitDuration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () =>
                            setStateDialog(() => selectedEmoji = emoji),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primaryBlue
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSel
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                          ),
                          child: Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Legenda: ${iconOptions.firstWhere((o) => o.key == selectedEmoji).key} ${iconOptions.firstWhere((o) => o.key == selectedEmoji).value}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Color picker
                Text(t.translate('color'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((c) {
                    final isSel = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setStateDialog(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isSel
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.translate('name_required'))),
                  );
                  return;
                }
                final service = ref.read(teamServiceProvider);
                final existingCount = ref
                        .read(teamCategoriesProvider(projectId))
                        .asData
                        ?.value
                        .length ??
                    0;
                final category = TeamCategory(
                  id: service.generateCategoryId(),
                  name: nameController.text.trim(),
                  emoji: selectedEmoji,
                  colorValue: selectedColor,
                  order: existingCount + 10,
                  isDefault: false,
                );
                await service.addCategory(projectId, category);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(t.translate('add')),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECÇÃO DE CATEGORIA — mantém o visual do código original
// ═══════════════════════════════════════════════════════════════════════════════

class _CategorySection extends ConsumerStatefulWidget {
  final String projectId;
  final TeamCategory category;

  const _CategorySection({
    super.key,
    required this.projectId,
    required this.category,
  });

  @override
  ConsumerState<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<_CategorySection> {
  bool _expanded = false;
  Color get _color => Color(widget.category.colorValue);

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final companiesAsync = ref.watch(companiesProvider(
      (projectId: widget.projectId, categoryId: widget.category.id),
    ));
    final companies = companiesAsync.asData?.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // ── Header da categoria (igual ao original mas com toggle expand) ──
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.category.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  widget.category.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Text(
              '${companies.length}',
              style: TextStyle(
                  fontSize: 14, color: _color, fontWeight: FontWeight.bold),
            ),
            // Só categorias não-default têm menu de eliminação
            if (!widget.category.isDefault)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.mediumGray, size: 20),
                onSelected: (action) => _handleCategoryAction(context, action),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.errorRed),
                      const SizedBox(width: 8),
                      Text(
                        TranslationHelper.of(context)
                            .translate('delete_category'),
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                    ]),
                  ),
                ],
              ),
            IconButton(
              icon: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.mediumGray,
              ),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Lista de empresas (igual ao original) ──────────────────────────
        if (_expanded)
          Card(
            child: Column(
              children: [
                if (companies.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      t.translate('no_companies_yet'),
                      style: const TextStyle(
                        color: AppColors.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ...companies.map((company) => _CompanyTile(
                      key: ValueKey(company.id),
                      projectId: widget.projectId,
                      categoryId: widget.category.id,
                      company: company,
                      color: _color,
                    )),
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: _color),
                  title: Text(
                    t.translate('add_company'),
                    style: TextStyle(color: _color),
                  ),
                  onTap: () => _showAddCompanyDialog(context),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),
      ],
    );
  }

  void _handleCategoryAction(BuildContext context, String action) async {
    final t = TranslationHelper.of(context);
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Text(t.translate('delete_category')),
          ]),
          content: Text(
              '"${widget.category.name}" — ${t.translate('delete_category_msg')}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
              child: Text(t.translate('delete')),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        try {
          await ref
              .read(teamServiceProvider)
              .deleteCategory(widget.projectId, widget.category.id);
          if (!context.mounted) return;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(t.translate('category_has_companies')),
                  backgroundColor: AppColors.errorRed),
            );
          }
        }
      }
    }
  }

  void _showAddCompanyDialog(BuildContext context) {
    final t = TranslationHelper.of(context);
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final notesController = TextEditingController();

    showLiquidDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.add_business, color: _color),
          const SizedBox(width: 12),
          Text(t.translate('add_company')),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '${t.translate('company_name')} *',
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: t.translate('contact'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: t.translate('phone'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: t.translate('email'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: t.translate('notes'),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.translate('name_required'))),
                );
                return;
              }
              final service = ref.read(teamServiceProvider);
              final company = Company(
                id: service.generateCompanyId(),
                name: nameController.text.trim(),
                contact: contactController.text.trim().isEmpty
                    ? null
                    : contactController.text.trim(),
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                createdAt: DateTime.now(),
              );
              await service.addCompany(
                  widget.projectId, widget.category.id, company);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.translate('company_added')),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _color),
            child: Text(t.translate('add')),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TILE DE EMPRESA — igual ao original + painel de pessoas + Firebase
// ═══════════════════════════════════════════════════════════════════════════════

class _CompanyTile extends ConsumerStatefulWidget {
  final String projectId;
  final String categoryId;
  final Company company;
  final Color color;

  const _CompanyTile({
    super.key,
    required this.projectId,
    required this.categoryId,
    required this.company,
    required this.color,
  });

  @override
  ConsumerState<_CompanyTile> createState() => _CompanyTileState();
}

class _CompanyTileState extends ConsumerState<_CompanyTile> {
  bool _showPeople = false;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final peopleAsync = _showPeople
        ? ref.watch(peopleProvider((
            projectId: widget.projectId,
            categoryId: widget.categoryId,
            companyId: widget.company.id,
          )))
        : null;

    return Column(
      children: [
        // ── Tile principal (igual ao original) ──────────────────────────
        ListTile(
          leading: CircleAvatar(
            backgroundColor: widget.color.withValues(alpha: 0.2),
            child: Text(
              // Ignora dígitos iniciais — ex: "2windservice" → "W"
              widget.company.name
                      .replaceAll(RegExp(r'^\d+'), '')
                      .trim()
                      .isNotEmpty
                  ? widget.company.name
                      .replaceAll(RegExp(r'^\d+'), '')
                      .trim()[0]
                      .toUpperCase()
                  : widget.company.name[0].toUpperCase(),
              style:
                  TextStyle(color: widget.color, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(widget.company.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.company.contact?.isNotEmpty ?? false)
                Row(children: [
                  const Icon(Icons.person,
                      size: 14, color: AppColors.mediumGray),
                  const SizedBox(width: 4),
                  Text(widget.company.contact!),
                ]),
              if (widget.company.phone?.isNotEmpty ?? false)
                Row(children: [
                  const Icon(Icons.phone,
                      size: 14, color: AppColors.mediumGray),
                  const SizedBox(width: 4),
                  Text(widget.company.phone!),
                ]),
              if (widget.company.email?.isNotEmpty ?? false)
                Row(children: [
                  const Icon(Icons.email,
                      size: 14, color: AppColors.mediumGray),
                  const SizedBox(width: 4),
                  Text(widget.company.email!),
                ]),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão pessoas (novo)
              IconButton(
                icon: Icon(
                  _showPeople ? Icons.people : Icons.people_outline,
                  color: widget.color,
                  size: 20,
                ),
                tooltip: t.translate('people'),
                onPressed: () => setState(() => _showPeople = !_showPeople),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text(t.translate('edit')),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'add_person',
                    child: Row(children: [
                      const Icon(Icons.person_add_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text(t.translate('add_person')),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.errorRed),
                      const SizedBox(width: 12),
                      Text(t.translate('delete'),
                          style: const TextStyle(color: AppColors.errorRed)),
                    ]),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCompanyDialog(context);
                  } else if (value == 'add_person') {
                    setState(() => _showPeople = true);
                    _showAddPersonDialog(context);
                  } else if (value == 'delete') {
                    _showDeleteCompanyDialog(context);
                  }
                },
              ),
            ],
          ),
        ),

        // ── Painel de pessoas (novo) ─────────────────────────────────────
        if (_showPeople) ...[
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                if (peopleAsync == null || peopleAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  )
                else if ((peopleAsync.asData?.value ?? []).isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      t.translate('no_people_yet'),
                      style: const TextStyle(
                          color: AppColors.mediumGray,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  ...(peopleAsync.asData?.value ?? []).map(
                    (person) => _PersonTile(
                      person: person,
                      color: widget.color,
                      onEdit: () => _showEditPersonDialog(context, person),
                      onDelete: () async {
                        await ref.read(teamServiceProvider).deletePerson(
                              widget.projectId,
                              widget.categoryId,
                              widget.company.id,
                              person.id,
                            );
                      },
                    ),
                  ),
                // Adicionar pessoa
                TextButton.icon(
                  onPressed: () => _showAddPersonDialog(context),
                  icon: Icon(Icons.person_add, color: widget.color, size: 16),
                  label: Text(
                    t.translate('add_person'),
                    style: TextStyle(color: widget.color),
                  ),
                ),
              ],
            ),
          ),
        ],

        const Divider(height: 1),
      ],
    );
  }

  // ── Edit company ───────────────────────────────────────────────────────────

  void _showEditCompanyDialog(BuildContext context) {
    final t = TranslationHelper.of(context);
    final nameC = TextEditingController(text: widget.company.name);
    final contactC = TextEditingController(text: widget.company.contact ?? '');
    final phoneC = TextEditingController(text: widget.company.phone ?? '');
    final emailC = TextEditingController(text: widget.company.email ?? '');
    final notesC = TextEditingController(text: widget.company.notes ?? '');

    showLiquidDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.edit, color: widget.color),
          const SizedBox(width: 12),
          Text(t.translate('edit_company')),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: InputDecoration(
                    labelText: t.translate('company_name'),
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactC,
                decoration: InputDecoration(
                    labelText: t.translate('contact'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneC,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: t.translate('phone'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: t.translate('email'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesC,
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: t.translate('notes'),
                    border: const OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = widget.company.copyWith(
                name: nameC.text.trim(),
                contact:
                    contactC.text.trim().isEmpty ? null : contactC.text.trim(),
                phone: phoneC.text.trim().isEmpty ? null : phoneC.text.trim(),
                email: emailC.text.trim().isEmpty ? null : emailC.text.trim(),
                notes: notesC.text.trim().isEmpty ? null : notesC.text.trim(),
              );
              await ref
                  .read(teamServiceProvider)
                  .updateCompany(widget.projectId, widget.categoryId, updated);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(t.translate('company_updated')),
                  backgroundColor: AppColors.successGreen,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.color),
            child: Text(t.translate('save')),
          ),
        ],
      ),
    );
  }

  // ── Delete company ─────────────────────────────────────────────────────────

  void _showDeleteCompanyDialog(BuildContext context) async {
    final t = TranslationHelper.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
          const SizedBox(width: 12),
          Text(t.translate('delete_company')),
        ]),
        content: Text(
            '${t.translate('delete_company_confirm')} "${widget.company.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(t.translate('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(teamServiceProvider).deleteCompany(
          widget.projectId, widget.categoryId, widget.company.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t.translate('company_deleted')),
          backgroundColor: AppColors.errorRed,
        ));
      }
    }
  }

  // ── Add person ─────────────────────────────────────────────────────────────

  void _showAddPersonDialog(BuildContext context) {
    final t = TranslationHelper.of(context);
    final nameC = TextEditingController();
    final roleC = TextEditingController();
    final phoneC = TextEditingController();
    final emailC = TextEditingController();
    final notesC = TextEditingController();

    showLiquidDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.person_add, color: widget.color),
          const SizedBox(width: 12),
          Text(t.translate('add_person')),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                    labelText: '${t.translate('person_name')} *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleC,
                decoration: InputDecoration(
                    labelText: t.translate('job_role'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.work)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneC,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: t.translate('phone'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: t.translate('email'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesC,
                maxLines: 2,
                decoration: InputDecoration(
                    labelText: t.translate('notes'),
                    border: const OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameC.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.translate('name_required'))),
                );
                return;
              }
              final service = ref.read(teamServiceProvider);
              final person = CompanyPerson(
                id: service.generatePersonId(),
                name: nameC.text.trim(),
                jobRole: roleC.text.trim().isEmpty ? null : roleC.text.trim(),
                phone: phoneC.text.trim().isEmpty ? null : phoneC.text.trim(),
                email: emailC.text.trim().isEmpty ? null : emailC.text.trim(),
                notes: notesC.text.trim().isEmpty ? null : notesC.text.trim(),
              );
              await service.addPerson(widget.projectId, widget.categoryId,
                  widget.company.id, person);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(t.translate('person_added')),
                  backgroundColor: AppColors.successGreen,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.color),
            child: Text(t.translate('add')),
          ),
        ],
      ),
    );
  }

  // ── Edit person ────────────────────────────────────────────────────────────

  void _showEditPersonDialog(BuildContext context, CompanyPerson person) {
    final t = TranslationHelper.of(context);
    final nameC = TextEditingController(text: person.name);
    final roleC = TextEditingController(text: person.jobRole ?? '');
    final phoneC = TextEditingController(text: person.phone ?? '');
    final emailC = TextEditingController(text: person.email ?? '');
    final notesC = TextEditingController(text: person.notes ?? '');

    showLiquidDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.edit, color: widget.color),
          const SizedBox(width: 12),
          Text(t.translate('edit')),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: InputDecoration(
                    labelText: '${t.translate('person_name')} *',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleC,
                decoration: InputDecoration(
                    labelText: t.translate('job_role'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.work)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneC,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: t.translate('phone'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: t.translate('email'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesC,
                maxLines: 2,
                decoration: InputDecoration(
                    labelText: t.translate('notes'),
                    border: const OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = person.copyWith(
                name: nameC.text.trim(),
                jobRole: roleC.text.trim().isEmpty ? null : roleC.text.trim(),
                phone: phoneC.text.trim().isEmpty ? null : phoneC.text.trim(),
                email: emailC.text.trim().isEmpty ? null : emailC.text.trim(),
                notes: notesC.text.trim().isEmpty ? null : notesC.text.trim(),
              );
              await ref.read(teamServiceProvider).updatePerson(
                    widget.projectId,
                    widget.categoryId,
                    widget.company.id,
                    updated,
                  );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(t.translate('person_updated')),
                  backgroundColor: AppColors.successGreen,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.color),
            child: Text(t.translate('save')),
          ),
        ],
      ),
    );
  }
}

// ─── Tile de pessoa ────────────────────────────────────────────────────────────

class _PersonTile extends StatelessWidget {
  final CompanyPerson person;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PersonTile({
    required this.person,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(
          person.name[0].toUpperCase(),
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(person.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (person.jobRole != null)
            Text(person.jobRole!,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.mediumGray)),
          if (person.phone != null)
            Row(children: [
              const Icon(Icons.phone, size: 11, color: AppColors.mediumGray),
              const SizedBox(width: 3),
              Text(person.phone!, style: const TextStyle(fontSize: 11)),
            ]),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 16),
        onSelected: (action) {
          if (action == 'edit') onEdit();
          if (action == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              const Icon(Icons.edit_outlined, size: 16),
              const SizedBox(width: 8),
              Text(t.translate('edit')),
            ]),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(children: [
              const Icon(Icons.delete_outline,
                  size: 16, color: AppColors.errorRed),
              const SizedBox(width: 8),
              Text(t.translate('delete'),
                  style: const TextStyle(color: AppColors.errorRed)),
            ]),
          ),
        ],
      ),
    );
  }
}
