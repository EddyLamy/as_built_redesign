import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/add_turbina_dialog.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/generate_report_dialog.dart';
import '../main.dart' show navigatorKey;

/// Serviço centralizado para executar ações de atalhos de teclado
class KeyboardShortcutsService {
  final BuildContext context;
  final WidgetRef ref;
  final bool useRootNav;

  KeyboardShortcutsService({
    required this.context,
    required this.ref,
    this.useRootNav = false,
  });

  /// Abre o diálogo para criar novo projeto
  void createNewProject() {
    if (useRootNav && navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const CreateProjectWizard(),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CreateProjectWizard(),
      );
    }
  }

  /// Adiciona nova turbina ao projeto selecionado
  void addNewTurbine() {
    final selectedProjectId = ref.read(selectedProjectIdProvider);

    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um projeto primeiro')),
      );
      return;
    }

    if (useRootNav && navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => AddTurbinaDialog(
          projectId: selectedProjectId,
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AddTurbinaDialog(
          projectId: selectedProjectId,
        ),
      );
    }
  }

  /// Gera relatório para o projeto selecionado
  void generateReport() {
    final selectedProjectId = ref.read(selectedProjectIdProvider);

    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um projeto primeiro')),
      );
      return;
    }

    // Obter o nome do projeto do provider
    final selectedProjectAsync = ref.read(selectedProjectProvider);

    selectedProjectAsync.whenData((project) {
      if (project != null) {
        // Usar rootNavigator para garantir que funciona
        final dialogContext = useRootNav && navigatorKey.currentContext != null
            ? navigatorKey.currentContext!
            : context;
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (context) => GenerateReportDialog(
            projectId: selectedProjectId,
            projectName: project.nome,
          ),
        );
      }
    });
  }

  /// Limpa a pesquisa (só funciona se há um campo de pesquisa ativo)
  void clearSearch() {
    // Esta ação precisa ser implementada por quem tenha o campo de pesquisa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesquisa limpa'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}
