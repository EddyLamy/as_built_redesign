import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

/// Formulário de Fases Finais (Simplificado - Desktop Only)
class FinalPhasesForm extends ConsumerWidget {
  final String turbinaId;
  final String componentId;

  const FinalPhasesForm({
    super.key,
    required this.turbinaId,
    required this.componentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.mediumGray,
            ),
            SizedBox(height: 16),
            Text(
              'Fases Finais',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fase disponível apenas na versão desktop',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
