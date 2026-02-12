import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import 'grua_atividades_screen.dart';

/// Ecrã de gestão de gruas (NÍVEL 1)
/// Mostra lista de gruas e permite adicionar novas
class GruasManagementScreen extends StatefulWidget {
  final String turbineId;
  final String turbineName;

  const GruasManagementScreen({
    super.key,
    required this.turbineId,
    required this.turbineName,
  });

  @override
  State<GruasManagementScreen> createState() => _GruasManagementScreenState();
}

class _GruasManagementScreenState extends State<GruasManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('cranes')),
            Text(
              widget.turbineName,
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
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.construction,
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
                        t.translate('crane_management'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.translate('crane_management_subtitle'),
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
          // LISTA DE GRUAS
          // ═══════════════════════════════════════════════════════════
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('turbinas')
                  .doc(widget.turbineId)
                  .collection('gruas')
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
                          Icons.construction,
                          size: 64,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.translate('no_cranes_yet'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.translate('add_first_crane'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                          textAlign: TextAlign.center,
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

                    // Contar atividades desta grua
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('turbinas')
                          .doc(widget.turbineId)
                          .collection('gruas')
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
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.construction,
                                color: AppColors.primaryBlue,
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
                                  onPressed: () =>
                                      _showDeleteGruaDialog(gruaId, modelo),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.mediumGray,
                                  size: 16,
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navegar para atividades da grua (NÍVEL 2)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GruaAtividadesScreen(
                                    turbineId: widget.turbineId,
                                    turbineName: widget.turbineName,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGruaDialog(),
        icon: const Icon(Icons.precision_manufacturing_sharp),
        label: Text(t.translate('add_crane')),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DIALOG: ADICIONAR GRUA
  // ═══════════════════════════════════════════════════════════════════════
  void _showAddGruaDialog() {
    final t = TranslationHelper.of(context);
    final modeloController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.construction, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Text(t.translate('add_crane')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: modeloController,
              decoration: InputDecoration(
                labelText: t.translate('crane_model'),
                hintText: 'Ex: Liebherr LTM 1750',
                prefixIcon: const Icon(Icons.construction),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.translate('multiple_cranes_info'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
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
                    .collection('turbinas')
                    .doc(widget.turbineId)
                    .collection('gruas')
                    .add({
                  'modelo': modelo,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.translate('crane_added_success')),
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
              backgroundColor: AppColors.primaryBlue,
            ),
            child: Text(t.translate('add')),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DIALOG: ELIMINAR GRUA
  // ═══════════════════════════════════════════════════════════════════════
  void _showDeleteGruaDialog(String gruaId, String modelo) {
    final t = TranslationHelper.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Text(t.translate('delete_crane')),
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
                    .collection('turbinas')
                    .doc(widget.turbineId)
                    .collection('gruas')
                    .doc(gruaId)
                    .collection('atividades')
                    .get();

                for (var doc in atividades.docs) {
                  await doc.reference.delete();
                }

                // Eliminar a grua
                await FirebaseFirestore.instance
                    .collection('turbinas')
                    .doc(widget.turbineId)
                    .collection('gruas')
                    .doc(gruaId)
                    .delete();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.translate('crane_deleted_success')),
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
