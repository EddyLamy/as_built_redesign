import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/help/help_screen.dart';
import '../services/keyboard_shortcuts_service.dart';
import '../utils/app_feedback.dart';
import '../utils/keyboard_shortcuts.dart';
import '../main.dart' show navigatorKey;

/// Route observer exposto para o MaterialApp registar
final RouteObserver<ModalRoute<void>> shortcutRouteObserver =
    RouteObserver<ModalRoute<void>>();

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

class _GlobalKeyboardHandlerState extends ConsumerState<GlobalKeyboardHandler>
    with WidgetsBindingObserver
    implements RouteAware {
  final FocusNode _focusNode = FocusNode(debugLabel: 'global_shortcuts_root');
  final ShortcutExecutionGuard _executionGuard = ShortcutExecutionGuard();
  bool _hardwareHandlerAttached = false;

  KeyboardShortcutsService get _service => KeyboardShortcutsService(ref: ref);

  Future<void> _invokeShortcut(
    Object shortcutId,
    Future<void> Function() action,
  ) async {
    if (!_executionGuard.canExecute(shortcutId)) {
      return;
    }

    try {
      await action();
    } catch (_) {
      showAppFeedback(
        'Não foi possível executar o atalho',
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> _dispatchIntent(Intent intent) {
    if (intent is NewProjectIntent) {
      return _invokeShortcut(NewProjectIntent, _service.createNewProject);
    }
    if (intent is AddTurbineIntent) {
      return _invokeShortcut(AddTurbineIntent, _service.addNewTurbine);
    }
    if (intent is GenerateReportIntent) {
      return _invokeShortcut(GenerateReportIntent, _service.generateReport);
    }
    if (intent is SearchIntent) {
      return _invokeShortcut(SearchIntent, _service.focusSearch);
    }
    if (intent is OpenSettingsIntent) {
      return _invokeShortcut(OpenSettingsIntent, () async {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
      });
    }
    if (intent is OpenHelpIntent) {
      return _invokeShortcut(OpenHelpIntent, () async {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        );
      });
    }
    if (intent is ToggleLanguageIntent) {
      return _invokeShortcut(ToggleLanguageIntent, () async {
        final currentLocale = ref.read(localeProvider);
        final newLocale = currentLocale == 'pt' ? 'en' : 'pt';
        await ref.read(localeProvider.notifier).setLocale(newLocale);
        _showLanguageFeedback(newLocale);
      });
    }
    if (intent is ToggleThemeIntent) {
      return _invokeShortcut(ToggleThemeIntent, () async {
        await ref.read(themeProvider.notifier).toggleTheme();
        final isDark = ref.read(themeProvider) == 'dark';
        _showThemeFeedback(isDark);
      });
    }

    return Future<void>.value();
  }

  bool _hardwareKeyHandler(KeyEvent event) {
    final intent = KeyboardShortcuts.matchEvent(event);
    if (intent == null) {
      return false;
    }

    _dispatchIntent(intent);
    return true;
  }

  KeyEventResult _handleFocusKeyEvent(KeyEvent event) {
    final intent = KeyboardShortcuts.matchEvent(event);
    if (intent == null) {
      return KeyEventResult.ignored;
    }

    _dispatchIntent(intent);
    return KeyEventResult.handled;
  }

  void _attachHardwareHandler() {
    if (_hardwareHandlerAttached) {
      return;
    }

    HardwareKeyboard.instance.addHandler(_hardwareKeyHandler);
    _hardwareHandlerAttached = true;
  }

  void _detachHardwareHandler() {
    if (!_hardwareHandlerAttached) {
      return;
    }

    HardwareKeyboard.instance.removeHandler(_hardwareKeyHandler);
    _hardwareHandlerAttached = false;
  }

  void _recoverFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _focusNode.hasFocus) {
        return;
      }

      _focusNode.requestFocus();
    });
  }

  void _showLanguageFeedback(String newLocale) {
    showAppFeedback(
      newLocale == 'pt'
          ? 'Idioma alterado para Português'
          : 'Language changed to English',
      type: AppFeedbackType.info,
      duration: const Duration(seconds: 1),
    );
  }

  void _showThemeFeedback(bool isDark) {
    showAppFeedback(
      isDark ? 'Tema escuro ativado' : 'Tema claro ativado',
      type: AppFeedbackType.info,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attachHardwareHandler();
    _recoverFocus();
    // Register with route observer after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null) {
        shortcutRouteObserver.subscribe(this, route);
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _detachHardwareHandler();
    _attachHardwareHandler();
    _recoverFocus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _attachHardwareHandler();
      _recoverFocus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachHardwareHandler();
  }

  @override
  void didUpdateWidget(GlobalKeyboardHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attachHardwareHandler();
    _recoverFocus();
  }

  // RouteAware — re-request focus whenever this pseudo-route resurfaces
  @override
  void didPopNext() => _recoverFocus(); // a child route was popped
  @override
  void didPush() => _recoverFocus();
  @override
  void didPop() {}
  @override
  void didPushNext() {}

  @override
  void dispose() {
    shortcutRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _detachHardwareHandler();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: KeyboardShortcuts.getMainShortcuts(),
      child: Actions(
        actions: <Type, Action<Intent>>{
          NewProjectIntent: CallbackAction<NewProjectIntent>(
            onInvoke: (_) {
              _dispatchIntent(const NewProjectIntent());
              return null;
            },
          ),
          AddTurbineIntent: CallbackAction<AddTurbineIntent>(
            onInvoke: (_) {
              _dispatchIntent(const AddTurbineIntent());
              return null;
            },
          ),
          GenerateReportIntent: CallbackAction<GenerateReportIntent>(
            onInvoke: (_) {
              _dispatchIntent(const GenerateReportIntent());
              return null;
            },
          ),
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: (_) {
              _dispatchIntent(const SearchIntent());
              return null;
            },
          ),
          OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
            onInvoke: (_) {
              _dispatchIntent(const OpenSettingsIntent());
              return null;
            },
          ),
          OpenHelpIntent: CallbackAction<OpenHelpIntent>(
            onInvoke: (_) {
              _dispatchIntent(const OpenHelpIntent());
              return null;
            },
          ),
          ToggleLanguageIntent: CallbackAction<ToggleLanguageIntent>(
            onInvoke: (_) {
              _dispatchIntent(const ToggleLanguageIntent());
              return null;
            },
          ),
          ToggleThemeIntent: CallbackAction<ToggleThemeIntent>(
            onInvoke: (_) {
              _dispatchIntent(const ToggleThemeIntent());
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          canRequestFocus: true,
          skipTraversal: true,
          onKeyEvent: (_, event) => _handleFocusKeyEvent(event),
          onFocusChange: (hasFocus) {
            if (!hasFocus && mounted) {
              _recoverFocus();
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
