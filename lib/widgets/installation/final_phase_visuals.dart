import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/installation/tipo_fase.dart';

class FinalPhaseVisuals {
  const FinalPhaseVisuals({
    required this.icon,
    required this.accentColor,
  });

  final IconData icon;
  final Color accentColor;

  static FinalPhaseVisuals of(TipoFase tipo) {
    switch (tipo) {
      case TipoFase.eletricos:
        return const FinalPhaseVisuals(
          icon: Icons.electrical_services,
          accentColor: AppColors.infoBlue,
        );
      case TipoFase.mecanicosGerais:
        return const FinalPhaseVisuals(
          icon: Icons.precision_manufacturing,
          accentColor: AppColors.warningOrange,
        );
      case TipoFase.finish:
        return const FinalPhaseVisuals(
          icon: Icons.check_circle,
          accentColor: AppColors.successGreen,
        );
      case TipoFase.inspecaoSupervisor:
        return const FinalPhaseVisuals(
          icon: Icons.visibility,
          accentColor: AppColors.accentTeal,
        );
      case TipoFase.punchlist:
        return const FinalPhaseVisuals(
          icon: Icons.checklist,
          accentColor: AppColors.accentAmber,
        );
      case TipoFase.inspecaoCliente:
        return const FinalPhaseVisuals(
          icon: Icons.groups,
          accentColor: AppColors.primaryBlue,
        );
      case TipoFase.punchlistCliente:
        return const FinalPhaseVisuals(
          icon: Icons.assignment_turned_in,
          accentColor: AppColors.primaryBlueDark,
        );
      default:
        return const FinalPhaseVisuals(
          icon: Icons.check_circle_outline,
          accentColor: AppColors.mediumGray,
        );
    }
  }
}
