import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import 'grua_geral_atividades_screen.dart';

/// Ecrã de gestão de gruas gerais do projeto
/// (Gruas NÃO atribuídas a nenhuma turbina/pad)
class GruasGeraisScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const GruasGeraisScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
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
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════
          // HEADER COM INFO
          // ═══════════════════════════════════════════════════════════
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentTeal.withOpacity(0.3),
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

          // ═══════════════════════════════════════════════════════════
          // LISTA DE GRUAS GERAIS
          // ═══════════════════════════════════════════════════════════
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
                    final modelo = gruaData['modelo'] ?? 'Sem modelo';
                    final descricao = gruaData['descricao'] ?? '';

                    // Contar atividades desta grua
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
                                color: AppColors.accentTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.precision_manufacturing,
                                color: AppColors.accentTeal,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              modelo,
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
                                      context, gruaId, modelo, ref),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.mediumGray,
                                  size: 16,
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navegar para atividades da grua geral
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GruaGeralAtividadesScreen(
                                    projectId: projectId,
                                    projectName: projectName,
                                    gruaId: gruaId,
                                    gruaModelo: modelo,
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors
                  .accentTeal, // ou use Color(0xFF00CED1) para turquesa vibrante
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddGruaDialog(context, ref),
          icon: const Icon(Icons.precision_manufacturing_sharp),
          label: Text(t.translate('add_general_crane')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DIALOG: ADICIONAR GRUA GERAL
  // ═══════════════════════════════════════════════════════════════════════
  void _showAddGruaDialog(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final modeloController = TextEditingController();
    final descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.precision_manufacturing,
                color: AppColors.accentTeal),
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
                  color: AppColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accentTeal.withOpacity(0.3),
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
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final modelo = modeloController.text.trim();
              if (modelo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.translate('crane_model_required')),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectId)
                    .collection('gruas_gerais')
                    .add({
                  'modelo': modelo,
                  'descricao': descricaoController.text.trim(),
                  'projectId': projectId,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.translate('general_crane_added_success')),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${t.translate('error')}: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentTeal,
            ),
            child: Text(t.translate('add')),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DIALOG: ELIMINAR GRUA GERAL
  // ═══════════════════════════════════════════════════════════════════════
  void _showDeleteGruaDialog(
      BuildContext context, String gruaId, String modelo, WidgetRef ref) {
    final t = TranslationHelper.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Text(t.translate('delete_general_crane')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.translate('delete_crane_confirm')} "$modelo"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.errorRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.errorRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.translate('delete_crane_warning'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Eliminar todas as atividades primeiro
                final atividades = await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectId)
                    .collection('gruas_gerais')
                    .doc(gruaId)
                    .collection('atividades')
                    .get();

                for (var doc in atividades.docs) {
                  await doc.reference.delete();
                }

                // Eliminar a grua
                await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectId)
                    .collection('gruas_gerais')
                    .doc(gruaId)
                    .delete();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(t.translate('general_crane_deleted_success')),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${t.translate('error')}: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: Text(t.translate('delete')),
          ),
        ],
      ),
    );
  }
}
