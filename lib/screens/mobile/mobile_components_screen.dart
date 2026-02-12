import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart'; // <--- ESTE É O IMPORT VITAL
import 'mobile_installation_screen.dart';

/// Tela de seleção de componentes (Mobile)
/// Mostra componentes agrupados por categoria
class MobileComponentsScreen extends ConsumerStatefulWidget {
  final String turbinaId;
  final String turbinaNome;
  final int numberOfMiddleSections;

  const MobileComponentsScreen({
    super.key,
    required this.turbinaId,
    required this.turbinaNome,
    this.numberOfMiddleSections = 3,
  });

  @override
  ConsumerState<MobileComponentsScreen> createState() =>
      _MobileComponentsScreenState();
}

class _MobileComponentsScreenState
    extends ConsumerState<MobileComponentsScreen> {
  Map<String, List<Map<String, dynamic>>> _componentsByCategory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    setState(() => _isLoading = true);

    try {
      final turbinaService = ref.read(turbinaServiceProvider);
      final components = await turbinaService.getComponentsGroupedByCategory(
        widget.turbinaId,
        numberOfMiddleSections: widget.numberOfMiddleSections,
      );

      print('DEBUG components for ${widget.turbinaId}: $components');

      setState(() {
        _componentsByCategory = components;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar componentes: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turbinaNome),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _componentsByCategory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: AppColors.mediumGray,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum componente disponível',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _componentsByCategory.length,
                  itemBuilder: (context, categoryIndex) {
                    final category =
                        _componentsByCategory.keys.elementAt(categoryIndex);
                    final components = _componentsByCategory[category]!;

                    return _buildCategoryCard(category, components);
                  },
                ),
    );
  }

  Widget _buildCategoryCard(
      String category, List<Map<String, dynamic>> components) {
    // Category icon
    IconData categoryIcon;
    switch (category) {
      case 'Torre':
        categoryIcon = Icons.apartment;
        break;
      case 'Nacelle':
        categoryIcon = Icons.solar_power;
        break;
      case 'Rotor':
        categoryIcon = Icons.toys;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            categoryIcon,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          category,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${components.length} componentes',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.mediumGray,
          ),
        ),
        children: components.map((component) {
          return _buildComponentTile(component);
        }).toList(),
      ),
    );
  }

  Widget _buildComponentTile(Map<String, dynamic> component) {
    final componentId = component['id'] as String;
    final componentName = component['name'] as String;
    final progress = component['progress'] as double? ?? 0.0;

    // Progress color
    Color progressColor;
    if (progress >= 100) {
      progressColor = AppColors.successGreen;
    } else if (progress > 0) {
      progressColor = AppColors.warningOrange;
    } else {
      progressColor = AppColors.mediumGray;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: progressColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: progress >= 100
              ? Icon(Icons.check_circle, color: progressColor, size: 24)
              : progress > 0
                  ? Icon(Icons.pending, color: progressColor, size: 24)
                  : Icon(Icons.radio_button_unchecked,
                      color: progressColor, size: 24),
        ),
      ),
      title: Text(
        componentName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: AppColors.borderGray,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.mediumGray,
      ),
      onTap: () {
        // Navegar para instalação
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MobileInstallationScreen(
              turbinaId: widget.turbinaId,
              turbinaNome: widget.turbinaNome,
              componentId: componentId,
              componentName: componentName,
            ),
          ),
        );
      },
    );
  }
}
