import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/help/help_screen.dart';
import '../services/keyboard_shortcuts_service.dart';

/// Widget que captura atalhos de teclado em TODA a aplicação
class GlobalKeyboardHandler extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalKeyboardHandler({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GlobalKeyboardHandler> createState() =>
      _GlobalKeyboardHandlerState();
}

class _GlobalKeyboardHandlerState extends ConsumerState<GlobalKeyboardHandler> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Garantir foco quando a app inicia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        // Só processar quando a tecla é pressionada
        if (event is! KeyDownEvent) return;

        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        final key = event.logicalKey;

        // Criar serviço de atalhos
        final shortcutsService = KeyboardShortcutsService(
          context: context,
          ref: ref,
        );

        // ══════════════════════════════════════════════════════════
        // ATALHOS GLOBAIS (funcionam em qualquer ecrã)
        // ══════════════════════════════════════════════════════════

        // Ctrl + N - Novo Projeto (FUNCIONA EM QUALQUER ECRÃ)
        if (isCtrlPressed && key == LogicalKeyboardKey.keyN) {
          shortcutsService.createNewProject();
          return;
        }

        // Ctrl + T - Adicionar Turbina (FUNCIONA EM QUALQUER ECRÃ)
        if (isCtrlPressed && key == LogicalKeyboardKey.keyT) {
          shortcutsService.addNewTurbine();
          return;
        }

        // Ctrl + R - Gerar Relatório (FUNCIONA EM QUALQUER ECRÃ)
        if (isCtrlPressed && key == LogicalKeyboardKey.keyR) {
          shortcutsService.generateReport();
          return;
        }

        // Ctrl + F - Limpar Pesquisa (FUNCIONA EM QUALQUER ECRÃ)
        if (isCtrlPressed && key == LogicalKeyboardKey.keyF) {
          shortcutsService.clearSearch();
          return;
        }

        // Ctrl + , - Settings (FUNCIONA EM QUALQUER ECRÃ)
        if (isCtrlPressed && key == LogicalKeyboardKey.comma) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
          return;
        }

        // F1 - Help (FUNCIONA EM QUALQUER ECRÃ)
        if (key == LogicalKeyboardKey.f1) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          );
          return;
        }

        // Ctrl + L - Alternar Idioma (FUNCIONA EM QUALQUER ECRÃ)
        if (isCtrlPressed && key == LogicalKeyboardKey.keyL) {
          final currentLocale = ref.read(localeProvider);
          final newLocale = currentLocale == 'pt' ? 'en' : 'pt';
          ref.read(localeProvider.notifier).setLocale(newLocale);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newLocale == 'pt'
                  ? 'Idioma alterado para Português'
                  : 'Language changed to English'),
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }

        // Ctrl + D - Alternar Tema (FUNCIONA EM QUALQUER ECRÃ)
        if (isCtrlPressed && key == LogicalKeyboardKey.keyD) {
          ref.read(themeProvider.notifier).toggleTheme();

          final currentTheme = ref.read(themeProvider);
          final isDark = currentTheme == 'dark';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(isDark ? 'Tema escuro ativado' : 'Tema claro ativado'),
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }
      },
      child: widget.child,
    );
  }
}
