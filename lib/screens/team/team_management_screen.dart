import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  final String projectId;

  const TeamManagementScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  // TODO: Substituir por Firebase data
  final Map<String, List<Map<String, String>>> _companies = {
    'civil': [],
    'electrical': [],
    'turbine_assembly': [],
    'cranes': [],
    'transport': [],
    'commissioning': [],
  };

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.groups, color: Colors.white),
            const SizedBox(width: 12),
            Text(t.translate('team_management')),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Info card
          Card(
            color: AppColors.primaryBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.translate('team_management_desc'),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ══════════════════════════════════════════════════════════════
          // CATEGORIAS DE EMPRESAS
          // ══════════════════════════════════════════════════════════════

          _buildCategorySection(
            context,
            'civil',
            Icons.foundation,
            t.translate('civil_construction'),
            AppColors.warningOrange,
          ),

          _buildCategorySection(
            context,
            'electrical',
            Icons.electrical_services,
            t.translate('electrical'),
            AppColors.errorRed,
          ),

          _buildCategorySection(
            context,
            'turbine_assembly',
            Icons.wind_power,
            t.translate('turbine_assembly'),
            AppColors.primaryBlue,
          ),

          _buildCategorySection(
            context,
            'cranes',
            Icons.construction,
            t.translate('cranes'),
            AppColors.accentTeal,
          ),

          _buildCategorySection(
            context,
            'transport',
            Icons.local_shipping,
            t.translate('transport'),
            AppColors.successGreen,
          ),

          _buildCategorySection(
            context,
            'commissioning',
            Icons.check_circle_outline,
            t.translate('commissioning'),
            const Color(0xFF9C27B0), // Purple
          ),

          const SizedBox(height: 24),

          // Botão adicionar nova categoria
          OutlinedButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: Text(t.translate('add_category')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: AppColors.primaryBlue, width: 2),
              foregroundColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String categoryKey,
    IconData icon,
    String title,
    Color color,
  ) {
    final t = TranslationHelper.of(context);
    final companies = _companies[categoryKey] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Header da categoria
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${companies.length}',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Lista de empresas
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
              ...companies.map((company) => _buildCompanyTile(
                    context,
                    categoryKey,
                    company,
                    color,
                  )),
              ListTile(
                leading: Icon(Icons.add_circle_outline, color: color),
                title: Text(
                  t.translate('add_company'),
                  style: TextStyle(color: color),
                ),
                onTap: () => _showAddCompanyDialog(context, categoryKey, color),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompanyTile(
    BuildContext context,
    String categoryKey,
    Map<String, String> company,
    Color color,
  ) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              company['name']![0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(company['name'] ?? ''),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (company['contact']?.isNotEmpty ?? false)
                Row(
                  children: [
                    const Icon(Icons.phone,
                        size: 14, color: AppColors.mediumGray),
                    const SizedBox(width: 4),
                    Text(company['contact']!),
                  ],
                ),
              if (company['email']?.isNotEmpty ?? false)
                Row(
                  children: [
                    const Icon(Icons.email,
                        size: 14, color: AppColors.mediumGray),
                    const SizedBox(width: 4),
                    Text(company['email']!),
                  ],
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(TranslationHelper.of(context).translate('edit')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.errorRed),
                    const SizedBox(width: 12),
                    Text(
                      TranslationHelper.of(context).translate('delete'),
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditCompanyDialog(context, categoryKey, company, color);
              } else if (value == 'delete') {
                _showDeleteCompanyDialog(context, categoryKey, company);
              }
            },
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _showAddCompanyDialog(
      BuildContext context, String categoryKey, Color color) {
    final t = TranslationHelper.of(context);
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_business, color: color),
            const SizedBox(width: 12),
            Text(t.translate('add_company')),
          ],
        ),
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
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.translate('name_required'))),
                );
                return;
              }

              setState(() {
                _companies[categoryKey]!.add({
                  'name': nameController.text.trim(),
                  'contact': contactController.text.trim(),
                  'email': emailController.text.trim(),
                  'notes': notesController.text.trim(),
                });
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.translate('company_added')),
                  backgroundColor: AppColors.successGreen,
                ),
              );

              // TODO: Salvar no Firebase
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(t.translate('add')),
          ),
        ],
      ),
    );
  }

  void _showEditCompanyDialog(
    BuildContext context,
    String categoryKey,
    Map<String, String> company,
    Color color,
  ) {
    final t = TranslationHelper.of(context);
    final nameController = TextEditingController(text: company['name']);
    final contactController = TextEditingController(text: company['contact']);
    final emailController = TextEditingController(text: company['email']);
    final notesController = TextEditingController(text: company['notes']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: color),
            const SizedBox(width: 12),
            Text(t.translate('edit_company')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: t.translate('company_name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: t.translate('contact'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: t.translate('email'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
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
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                company['name'] = nameController.text.trim();
                company['contact'] = contactController.text.trim();
                company['email'] = emailController.text.trim();
                company['notes'] = notesController.text.trim();
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.translate('company_updated')),
                  backgroundColor: AppColors.successGreen,
                ),
              );

              // TODO: Atualizar no Firebase
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(t.translate('save')),
          ),
        ],
      ),
    );
  }

  void _showDeleteCompanyDialog(
    BuildContext context,
    String categoryKey,
    Map<String, String> company,
  ) {
    final t = TranslationHelper.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Text(t.translate('delete_company')),
          ],
        ),
        content: Text(
            '${t.translate('delete_company_confirm')} "${company['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _companies[categoryKey]!.remove(company);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.translate('company_deleted')),
                  backgroundColor: AppColors.errorRed,
                ),
              );

              // TODO: Deletar do Firebase
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(t.translate('delete')),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final t = TranslationHelper.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.translate('coming_soon')),
        backgroundColor: AppColors.accentTeal,
      ),
    );
  }
}
