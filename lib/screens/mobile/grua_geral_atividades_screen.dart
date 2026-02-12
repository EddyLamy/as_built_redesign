import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import 'grua_geral_atividade_form_screen.dart';

/// Ecrã de atividades de uma grua geral específica
/// Mostra lista de atividades e permite adicionar/editar
class GruaGeralAtividadesScreen extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String gruaId;
  final String gruaModelo;

  const GruaGeralAtividadesScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.gruaId,
    required this.gruaModelo,
  });

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gruaModelo),
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
          // HEADER COM INFO DA GRUA
          // ═══════════════════════════════════════════════════════════
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8CD)
                  .withOpacity(0.1), // ✅ Cor válida (bege claro)
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
                        gruaModelo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.translate('general_crane_activities'),
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
          // LISTA DE ATIVIDADES
          // ═══════════════════════════════════════════════════════════
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('projects')
                  .doc(projectId)
                  .collection('gruas_gerais')
                  .doc(gruaId)
                  .collection('atividades')
                  .orderBy('inicio', descending: true)
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

                final atividades = snapshot.data!.docs;

                if (atividades.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.translate('no_activities_yet'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.translate('add_first_activity'),
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
                  itemCount: atividades.length,
                  itemBuilder: (context, index) {
                    final atividadeDoc = atividades[index];
                    final data = atividadeDoc.data() as Map<String, dynamic>;
                    final docId = atividadeDoc.id;

                    final tipo = data['tipo'] ?? 'trabalho';
                    final DateTime inicio =
                        (data['inicio'] as Timestamp).toDate();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.accentTeal.withOpacity(0.1),
                          child: Icon(
                            _getIconForTipo(tipo),
                            color: AppColors.accentTeal,
                          ),
                        ),
                        title: Text(
                          t.translate(tipo),
                          style: const TextStyle(
                            fontSize: 16,
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
                                  Icons.calendar_today,
                                  size: 14,
                                  color: AppColors.mediumGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${inicio.day}/${inicio.month}/${inicio.year} - ${inicio.hour}:${inicio.minute.toString().padLeft(2, '0')}h",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                            if (data['motivo'] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppColors.mediumGray,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      t.translate(data['motivo']),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.mediumGray,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.mediumGray,
                        ),
                        onTap: () => _showAtividadeDetail(context, data, docId),
                      ),
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
                  .accentTeal, // ou Color(0xFF40E0D0) para turquesa vibrante
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openAtividadeForm(context),
          icon: const Icon(Icons.precision_manufacturing_outlined),
          label: Text(t.translate('register_activity')),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  void _openAtividadeForm(BuildContext context,
      {Map<String, dynamic>? existingData, String? docId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GruaGeralAtividadeFormScreen(
          projectId: projectId,
          projectName: projectName,
          gruaId: gruaId,
          gruaModelo: gruaModelo,
          initialData: existingData,
          docId: docId,
        ),
      ),
    );
  }

  void _showAtividadeDetail(
      BuildContext context, Map<String, dynamic> data, String docId) {
    final t = TranslationHelper.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      t.translate(data['tipo'] ?? 'trabalho'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteAtividade(context, docId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.accentTeal),
                    onPressed: () {
                      Navigator.pop(context);
                      _openAtividadeForm(context,
                          existingData: data, docId: docId);
                    },
                  ),
                ],
              ),
              const Divider(height: 32),
              if (data['motivo'] != null) ...[
                Text(t.translate('reason'),
                    style: const TextStyle(color: Colors.grey)),
                Text(t.translate(data['motivo']),
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
              if (data['observacoes'] != null &&
                  data['observacoes'].toString().isNotEmpty) ...[
                Text(t.translate('notes'),
                    style: const TextStyle(color: Colors.grey)),
                Text(data['observacoes'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
              if (data['origem'] != null &&
                  data['origem'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text("Path: ${data['origem']} ➔ ${data['destino']}",
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.translate('close')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteAtividade(BuildContext context, String docId) async {
    final t = TranslationHelper.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('delete_activity')),
        content: Text(t.translate('delete_activity_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.translate('delete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .collection('gruas_gerais')
          .doc(gruaId)
          .collection('atividades')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('activity_deleted_success')),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  IconData _getIconForTipo(String? tipo) {
    switch (tipo) {
      case 'paragem':
        return Icons.pause_circle_filled;
      case 'transferencia':
        return Icons.swap_horiz;
      case 'mobilizacao':
        return Icons.flight_land;
      case 'desmobilizacao':
        return Icons.flight_takeoff;
      default:
        return Icons.engineering;
    }
  }
}
