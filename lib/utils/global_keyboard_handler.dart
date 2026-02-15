import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/help/help_screen.dart';
import '../services/keyboard_shortcuts_service.dart';
import '../main.dart' show navigatorKey;

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
  @override
  void initState() {
    super.initState();
    // Register global keyboard handler - works independently of focus
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
    final key = event.logicalKey;

    try {
      // ══════════════════════════════════════════════════════════
      // ATALHOS GLOBAIS (funcionam em qualquer ecrã ou dialog)
      // ══════════════════════════════════════════════════════════

      // F1 - Help
      if (key == LogicalKeyboardKey.f1) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        );
        return true;
      }

      // Ctrl + , - Settings
      if (isCtrlPressed && key == LogicalKeyboardKey.comma) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        return true;
      }

      // Ctrl + L - Toggle Language
      if (isCtrlPressed && key == LogicalKeyboardKey.keyL) {
        final currentLocale = ref.read(localeProvider);
        final newLocale = currentLocale == 'pt' ? 'en' : 'pt';
        ref.read(localeProvider.notifier).setLocale(newLocale);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newLocale == 'pt'
                  ? 'Idioma alterado para Português'
                  : 'Language changed to English'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        return true;
      }

      // Ctrl + D - Toggle Theme
      if (isCtrlPressed && key == LogicalKeyboardKey.keyD) {
        ref.read(themeProvider.notifier).toggleTheme();

        final currentTheme = ref.read(themeProvider);
        final isDark = currentTheme == 'dark';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(isDark ? 'Tema escuro ativado' : 'Tema claro ativado'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        return true;
      }

      // ══════════════════════════════════════════════════════════
      // ATALHOS ESPECÍFICOS DO DASHBOARD
      // (Tentam executar em qualquer ecrã, serviço valida contexto)
      // ══════════════════════════════════════════════════════════

      if (mounted) {
        final service = KeyboardShortcutsService(
            context: context, ref: ref, useRootNav: true);

        // Ctrl + N - New Project
        if (isCtrlPressed && key == LogicalKeyboardKey.keyN) {
          service.createNewProject();
          return true;
        }

        // Ctrl + T - Add Turbine
        if (isCtrlPressed && key == LogicalKeyboardKey.keyT) {
          service.addNewTurbine();
          return true;
        }

        // Ctrl + R - Generate Report
        if (isCtrlPressed && key == LogicalKeyboardKey.keyR) {
          service.generateReport();
          return true;
        }
      }
    } catch (e) {
      // Silenciosamente ignorar erros de atalhos
    }

    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
