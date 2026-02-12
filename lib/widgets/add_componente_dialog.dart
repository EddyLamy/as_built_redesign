import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';

class AddComponenteDialog extends ConsumerStatefulWidget {
  final String turbinaId;
  final String projectId;
  final String categoria;

  const AddComponenteDialog({
    super.key,
    required this.turbinaId,
    required this.projectId,
    required this.categoria,
  });

  @override
  ConsumerState<AddComponenteDialog> createState() =>
      _AddComponenteDialogState();
}

class _AddComponenteDialogState extends ConsumerState<AddComponenteDialog> {
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _itemNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _vuiController = TextEditingController();
  final _ordemController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Sugerir próxima ordem
    _loadNextOrder();
  }

  Future<void> _loadNextOrder() async {
    try {
      final componenteService = ref.read(componenteServiceProvider);
      final componentes = await componenteService.getComponentesPorCategoria(
        widget.turbinaId,
        widget.categoria,
      );

      // Próxima ordem = maior ordem atual + 1
      int maxOrder = componentes.fold(
        0,
        (max, c) => c.ordem > max ? c.ordem : max,
      );
      _ordemController.text = (maxOrder + 1).toString();
    } catch (e) {
      _ordemController.text = '100'; // Default se falhar
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _itemNumberController.dispose();
    _serialNumberController.dispose();
    _vuiController.dispose();
    _ordemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline, color: AppColors.primaryBlue),
          SizedBox(width: 12),
          Text('Add Custom Component'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info da categoria
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Category: ${widget.categoria}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nome do componente *
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Component Name *',
                  hintText: 'e.g., Custom Flange Type X',
                  prefixIcon: Icon(Icons.widgets),
                ),
              ),
              const SizedBox(height: 16),

              // Tipo
              TextField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  hintText: 'e.g., Foundation, Tower, etc',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              // VUI
              TextField(
                controller: _vuiController,
                decoration: const InputDecoration(
                  labelText: 'VUI / Unit ID',
                  hintText: 'e.g., VES-CUSTOM-001',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _itemNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Item Number',
                        hintText: 'e.g., ITEM-001',
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _serialNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Serial Number',
                        hintText: 'e.g., SN-001',
                        prefixIcon: Icon(Icons.tag),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ordem de instalação
              TextField(
                controller: _ordemController,
                decoration: const InputDecoration(
                  labelText: 'Installation Order *',
                  hintText: 'e.g., 22',
                  prefixIcon: Icon(Icons.format_list_numbered),
                  helperText: 'Order in installation sequence',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAdd,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Add Component'),
        ),
      ],
    );
  }

  Future<void> _handleAdd() async {
    // Validação
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Component name is required'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_ordemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Installation order is required'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final componenteService = ref.read(componenteServiceProvider);

      // Criar componente custom
      await componenteService.createComponenteCustom(
        turbinaId: widget.turbinaId,
        projectId: widget.projectId,
        nome: _nomeController.text.trim(),
        tipo: _tipoController.text.trim().isEmpty
            ? 'Custom'
            : _tipoController.text.trim(),
        categoria: widget.categoria,
        ordem: int.parse(_ordemController.text.trim()),
        itemNumber: _itemNumberController.text.trim().isEmpty
            ? null
            : _itemNumberController.text.trim(),
        serialNumber: _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
        vui: _vuiController.text.trim().isEmpty
            ? null
            : _vuiController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Component "${_nomeController.text.trim()}" added successfully',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
