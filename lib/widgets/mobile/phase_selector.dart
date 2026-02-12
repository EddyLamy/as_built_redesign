import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Phase Selector Horizontal (Mobile)
/// Permite navegar entre fases com scroll horizontal
class PhaseSelector extends StatelessWidget {
  final List<Map<String, dynamic>> phases;
  final int currentIndex;
  final Function(int) onPhaseChanged;

  const PhaseSelector({
    super.key,
    required this.phases,
    required this.currentIndex,
    required this.onPhaseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: phases.length,
        itemBuilder: (context, index) {
          final phase = phases[index];
          final isSelected = index == currentIndex;
          final isCompleted = index < currentIndex;

          return GestureDetector(
            onTap: () => onPhaseChanged(index),
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue
                    : isCompleted
                        ? AppColors.successGreen.withOpacity(0.1)
                        : AppColors.borderGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : isCompleted
                          ? AppColors.successGreen
                          : AppColors.borderGray,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    isCompleted ? Icons.check_circle : phase['icon'],
                    color: isSelected
                        ? Colors.white
                        : isCompleted
                            ? AppColors.successGreen
                            : AppColors.mediumGray,
                    size: 32,
                  ),
                  const SizedBox(height: 8),

                  // Label
                  Text(
                    phase['label'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isCompleted
                              ? AppColors.successGreen
                              : AppColors.darkGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
