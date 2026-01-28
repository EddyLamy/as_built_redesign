import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/torque_tensioning.dart';
import '../services/torque_tensioning_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DIALOG: ADICIONAR CONEXÃO EXTRA
// ═══════════════════════════════════════════════════════════════════════════

class AddConexaoExtraDialog extends ConsumerStatefulWidget {
  final String turbinaId;
  final String projectId;

  const AddConexaoExtraDialog({
    super.key,
    required this.turbinaId,
    required this.projectId,
  });

  @override
  ConsumerState<AddConexaoExtraDialog> createState() =>
      _AddConexaoExtraDialogState();
}

class _AddConexaoExtraDialogState extends ConsumerState<AddConexaoExtraDialog> {
  final _formKey = GlobalKey<FormState>();
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();
  final _descricaoController = TextEditingController();

  String _categoriaSelecionada = 'Outro';
  bool _isCreating = false;

  final List<String> _categorias = [
    'Civil Works',
    'Torre',
    'Nacelle',
    'Rotor',
    'Outro',
  ];

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ════════════════════════════════════════════════════
                  // HEADER
                  // ════════════════════════════════════════════════════
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.accentTeal,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nova Conexão Extra',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Adicione uma conexão customizada',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // ════════════════════════════════════════════════════
                  // COMPONENTE ORIGEM
                  // ════════════════════════════════════════════════════
                  TextFormField(
                    controller: _origemController,
                    decoration: InputDecoration(
                      labelText: 'Componente Origem *',
                      hintText: 'Ex: Platform, Transformer',
                      prefixIcon: Icon(
                        Icons.arrow_forward,
                        color: AppColors.primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'De onde parte a conexão',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  // ════════════════════════════════════════════════════
                  // COMPONENTE DESTINO
                  // ════════════════════════════════════════════════════
                  TextFormField(
                    controller: _destinoController,
                    decoration: InputDecoration(
                      labelText: 'Componente Destino *',
                      hintText: 'Ex: Tower Bottom, Nacelle Base',
                      prefixIcon: Icon(
                        Icons.flag,
                        color: AppColors.successGreen,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Para onde vai a conexão',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  // ════════════════════════════════════════════════════
                  // CATEGORIA
                  // ════════════════════════════════════════════════════
                  DropdownButtonFormField<String>(
                    initialValue: _categoriaSelecionada,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(
                        _getCategoryIcon(_categoriaSelecionada),
                        color: _getCategoryColor(_categoriaSelecionada),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Agrupa conexões similares',
                    ),
                    items: _categorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(categoria),
                              size: 20,
                              color: _getCategoryColor(categoria),
                            ),
                            const SizedBox(width: 12),
                            Text(categoria),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSelecionada = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // ════════════════════════════════════════════════════
                  // DESCRIÇÃO (OPCIONAL)
                  // ════════════════════════════════════════════════════
                  TextFormField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                      labelText: 'Descrição (opcional)',
                      hintText: 'Ex: Plataforma de acesso ao bottom',
                      prefixIcon: Icon(
                        Icons.description,
                        color: AppColors.mediumGray,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: 'Detalhes sobre esta conexão',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 24),

                  // ════════════════════════════════════════════════════
                  // INFO BOX
                  // ════════════════════════════════════════════════════
                  Container(
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
                        Icon(
                          Icons.info_outline,
                          color: AppColors.accentTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Conexões extras podem ser deletadas a qualquer momento',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ════════════════════════════════════════════════════
                  // BUTTONS
                  // ════════════════════════════════════════════════════
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _isCreating ? null : () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isCreating ? null : _handleCreate,
                        icon: _isCreating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(_isCreating ? 'A criar...' : 'Criar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentTeal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CRIAR CONEXÃO EXTRA
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final service = TorqueTensioningService();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Utilizador não autenticado');
      }

      final now = DateTime.now();

      final novaConexao = TorqueTensioning(
        id: '', // Será gerado pelo Firestore
        turbinaId: widget.turbinaId,
        projectId: widget.projectId,
        componenteOrigem: _origemController.text.trim(),
        componenteDestino: _destinoController.text.trim(),
        categoria: _categoriaSelecionada,
        isStandard: false,
        isExtra: true,
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        createdAt: now,
        createdBy: user.uid,
        updatedAt: now,
        updatedBy: user.uid,
      );

      await service.createConexao(novaConexao);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conexão "${_origemController.text} → ${_destinoController.text}" criada!',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar conexão: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS - CORES E ÍCONES
  // ══════════════════════════════════════════════════════════════════════════

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Civil Works':
        return AppColors.warningOrange;
      case 'Torre':
        return AppColors.accentTeal;
      case 'Nacelle':
        return AppColors.primaryBlue;
      case 'Rotor':
        return AppColors.successGreen;
      default:
        return AppColors.mediumGray;
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Civil Works':
        return Icons.foundation;
      case 'Torre':
        return Icons.layers;
      case 'Nacelle':
        return Icons.settings;
      case 'Rotor':
        return Icons.autorenew;
      default:
        return Icons.link;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER - Current User (assumindo que já existe)
// ═══════════════════════════════════════════════════════════════════════════
// Nota: Este provider deve já existir no teu projeto
// Se não existir, adicionar ao app_providers.dart

// Exemplo:
// final currentUserProvider = StateProvider<User?>((ref) => null);
