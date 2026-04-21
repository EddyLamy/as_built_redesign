import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../utils/app_feedback.dart';
import '../widgets/add_turbina_dialog.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/generate_report_dialog.dart';
import '../main.dart' show navigatorKey;

/// Serviço centralizado para executar ações de atalhos de teclado
class KeyboardShortcutsService {
  final WidgetRef ref;

  KeyboardShortcutsService({
    required this.ref,
  });

  static bool _shortcutDialogVisible = false;

  BuildContext? get _actionContext =>
      navigatorKey.currentState?.overlay?.context ??
      navigatorKey.currentContext;

  NavigatorState? get _rootNavigator => navigatorKey.currentState;

  Future<T?> _showShortcutDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = false,
  }) async {
    final navigator = _rootNavigator;
    final dialogContext = _actionContext;

    if (navigator == null || dialogContext == null) {
      showAppFeedback(
        'Atalho indisponível neste momento',
        type: AppFeedbackType.warning,
      );
      return null;
    }

    if (_shortcutDialogVisible) {
      return null;
    }

    _shortcutDialogVisible = true;

    try {
      return await navigator.push<T>(
        DialogRoute<T>(
          context: dialogContext,
          barrierDismissible: barrierDismissible,
          builder: builder,
        ),
      );
    } finally {
      _shortcutDialogVisible = false;
    }
  }

  /// Abre o diálogo para criar novo projeto
  Future<void> createNewProject() async {
    await _showShortcutDialog(
      barrierDismissible: false,
      builder: (context) => const CreateProjectWizard(),
    );
  }

  /// Adiciona nova turbina ao projeto selecionado
  Future<void> addNewTurbine() async {
    final selectedProjectId = ref.read(selectedProjectIdProvider);

    if (selectedProjectId == null) {
      showAppFeedback(
        'Selecione um projeto primeiro',
        type: AppFeedbackType.warning,
      );
      return;
    }

    await _showShortcutDialog(
      barrierDismissible: false,
      builder: (context) => AddTurbinaDialog(
        projectId: selectedProjectId,
      ),
    );
  }

  /// Gera relatório para o projeto selecionado
  Future<void> generateReport() async {
    final selectedProjectId = ref.read(selectedProjectIdProvider);

    if (selectedProjectId == null) {
      showAppFeedback(
        'Selecione um projeto primeiro',
        type: AppFeedbackType.warning,
      );
      return;
    }

    try {
      final selectedProject = ref.read(selectedProjectProvider).asData?.value ??
          await ref.read(selectedProjectProvider.future);

      if (selectedProject == null) {
        showAppFeedback(
          'Não foi possível carregar o projeto selecionado',
          type: AppFeedbackType.warning,
        );
        return;
      }

      await _showShortcutDialog(
        barrierDismissible: false,
        builder: (context) => GenerateReportDialog(
          projectId: selectedProjectId,
          projectName: selectedProject.nome,
        ),
      );
    } catch (_) {
      showAppFeedback(
        'Não foi possível carregar o projeto selecionado',
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> focusSearch() async {
    showAppFeedback(
      'Use o campo de pesquisa visível nesta página',
      type: AppFeedbackType.info,
      duration: const Duration(seconds: 2),
    );
  }
}
