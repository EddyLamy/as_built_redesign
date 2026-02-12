import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de atalhos de teclado para toda a aplicação
class KeyboardShortcuts {
  /// Criar atalhos para o ecrã principal
  static Map<ShortcutActivator, Intent> getMainShortcuts() {
    return {
      // Ctrl + N - Novo Projeto
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
          const NewProjectIntent(),

      // Ctrl + T - Adicionar Turbina
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT):
          const AddTurbineIntent(),

      // Ctrl + R - Gerar Relatório
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
          const GenerateReportIntent(),

      // Ctrl + F - Pesquisar
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
          const SearchIntent(),

      // Ctrl + , - Configurações
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.comma):
          const OpenSettingsIntent(),

      // F1 - Ajuda
      LogicalKeySet(LogicalKeyboardKey.f1): const OpenHelpIntent(),

      // Ctrl + L - Mudar Idioma
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL):
          const ToggleLanguageIntent(),

      // Ctrl + D - Tema Dark/Light
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD):
          const ToggleThemeIntent(),
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════
// INTENTS (Intenções dos atalhos)
// ══════════════════════════════════════════════════════════════════════════

class NewProjectIntent extends Intent {
  const NewProjectIntent();
}

class AddTurbineIntent extends Intent {
  const AddTurbineIntent();
}

class GenerateReportIntent extends Intent {
  const GenerateReportIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class OpenHelpIntent extends Intent {
  const OpenHelpIntent();
}

class ToggleLanguageIntent extends Intent {
  const ToggleLanguageIntent();
}

class ToggleThemeIntent extends Intent {
  const ToggleThemeIntent();
}
