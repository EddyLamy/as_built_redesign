import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/background_watermark.dart';
import 'grua_geral_atividades_screen.dart';

class GruasGeraisScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;
  final bool embeddedInDesktopShell;

  const GruasGeraisScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    this.embeddedInDesktopShell = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);

    final screenBody = Stack(
      children: [
        const BackgroundWatermark(
          size: 520,
          opacity: 0.03,
          alignment: Alignment.centerRight,
        ),
        Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentTeal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.translate('general_cranes_management'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.translate('general_cranes_subtitle'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectId)
                    .collection('gruas_gerais')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${t.translate('error')}: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.errorRed),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final gruas = snapshot.data!.docs;
                  if (gruas.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.precision_manufacturing,
                            size: 64,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.translate('no_general_cranes_yet'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              t.translate('add_first_general_crane'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: gruas.length,
                    itemBuilder: (context, index) {
                      final gruaDoc = gruas[index];
                      final gruaData = gruaDoc.data() as Map<String, dynamic>;
                      final gruaId = gruaDoc.id;
                      final modelo =
                          (gruaData['modelo'] ?? gruaData['nome'] ?? '')
                              .toString();
                      final descricao =
                          (gruaData['descricao'] ?? '').toString();

                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('projects')
                            .doc(projectId)
                            .collection('gruas_gerais')
                            .doc(gruaId)
                            .collection('atividades')
                            .get(),
                        builder: (context, atividadesSnapshot) {
                          final numAtividades =
                              atividadesSnapshot.data?.docs.length ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.accentTeal
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.precision_manufacturing,
                                  color: AppColors.accentTeal,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                modelo.isEmpty
                                    ? t.translate('unnamed_general_crane')
                                    : modelo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (descricao.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      descricao,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkGray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.assignment,
                                        size: 16,
                                        color: AppColors.mediumGray,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$numAtividades ${t.translate('activities')}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.errorRed,
                                    ),
                                    onPressed: () => _showDeleteGruaDialog(
                                      context,
                                      gruaId,
                                      modelo,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.mediumGray,
                                    size: 16,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GruaGeralAtividadesScreen(
                                      projectId: projectId,
                                      projectName: projectName,
                                      gruaId: gruaId,
                                      gruaModelo: modelo.isEmpty
                                          ? t.translate('unnamed_general_crane')
                                          : modelo,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );

    if (embeddedInDesktopShell) {
      return screenBody;
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.translate('general_cranes')),
              Text(
                projectName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: screenBody,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.accentTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddGruaDialog(context),
          icon: const Icon(Icons.precision_manufacturing_sharp),
          label: Text(t.translate('add_general_crane')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  void _showAddGruaDialog(BuildContext context) {
    final t = TranslationHelper.of(context);
    final modeloController = TextEditingController();
    final descricaoController = TextEditingController();

    showLiquidDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.precision_manufacturing,
              color: AppColors.accentTeal,
            ),
            const SizedBox(width: 12),
            Text(t.translate('add_general_crane')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: modeloController,
                decoration: InputDecoration(
                  labelText: t.translate('crane_model'),
                  hintText: 'Ex: Manitowoc 18000',
                  prefixIcon: const Icon(Icons.precision_manufacturing),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(
                  labelText: t.translate('description_optional'),
                  hintText: t.translate('crane_usage_example'),
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accentTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.accentTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.translate('general_cranes_info'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accentTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final modelo = modeloController.text.trim();
              final descricao = descricaoController.text.trim();
              if (modelo.isEmpty) {
                return;
              }

              await FirebaseFirestore.instance
                  .collection('projects')
                  .doc(projectId)
                  .collection('gruas_gerais')
                  .add({
                'nome': modelo,
                'modelo': modelo,
                'descricao': descricao,
                'atividadeCount': 0,
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(t.translate('save')),
          ),
        ],
      ),
    );
  }

  void _showDeleteGruaDialog(
    BuildContext context,
    String gruaId,
    String modelo,
  ) {
    final t = TranslationHelper.of(context);

    showLiquidDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.translate('delete')),
        content: Text('Eliminar grua geral "$modelo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('projects')
                  .doc(projectId)
                  .collection('gruas_gerais')
                  .doc(gruaId)
                  .delete();

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text(t.translate('delete')),
          ),
        ],
      ),
    );
  }
}
