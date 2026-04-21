import 'package:flutter/material.dart';
import '../installation/final_phases_cards_view.dart';

/// Formulário de Fases Finais
class FinalPhasesForm extends StatelessWidget {
  final String turbinaId;
  final String componentId;

  const FinalPhasesForm({
    super.key,
    required this.turbinaId,
    required this.componentId,
  });

  @override
  Widget build(BuildContext context) {
    return FinalPhasesCardsView(
      turbinaId: turbinaId,
      physics: const BouncingScrollPhysics(),
    );
  }
}
