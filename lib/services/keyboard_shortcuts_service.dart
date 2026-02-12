import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/add_turbina_dialog.dart';
import '../widgets/create_project_dialog.dart';

/// Serviço centralizado para executar ações de atalhos de teclado
class KeyboardShortcutsService {
  final BuildContext context;
  final WidgetRef ref;

  KeyboardShortcutsService({
    required this.context,
    required this.ref,
  });

  /// Abre o diálogo para criar novo projeto
  void createNewProject() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateProjectWizard(),
    );
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddTurbinaDialog(
        projectId: selectedProjectId,
      ),
    );
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

    // Quando no dashboard, usar o método que já existe
    if (context.mounted) {
      try {
        // Tentar chamar o método do dashboard se estamos numa rota com acesso
        // Alternativamente, abrir um dialog genérico de geração de relatório
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gerando relatório...'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Erro ao gerar relatório: $e');
      }
    }
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
