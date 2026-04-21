import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de atalhos de teclado para toda a aplicação
class KeyboardShortcuts {
  static final List<_ShortcutBinding> _bindings = [
    _ShortcutBinding.mod(LogicalKeyboardKey.keyN, const NewProjectIntent()),
    _ShortcutBinding.mod(LogicalKeyboardKey.keyT, const AddTurbineIntent()),
    _ShortcutBinding.mod(
      LogicalKeyboardKey.keyR,
      const GenerateReportIntent(),
    ),
    _ShortcutBinding.mod(LogicalKeyboardKey.keyF, const SearchIntent()),
    _ShortcutBinding.mod(
      LogicalKeyboardKey.comma,
      const OpenSettingsIntent(),
    ),
    _ShortcutBinding.single(LogicalKeyboardKey.f1, const OpenHelpIntent()),
    _ShortcutBinding.mod(
      LogicalKeyboardKey.keyL,
      const ToggleLanguageIntent(),
    ),
    _ShortcutBinding.mod(LogicalKeyboardKey.keyD, const ToggleThemeIntent()),
  ];

  /// Criar atalhos para o ecrã principal
  static Map<ShortcutActivator, Intent> getMainShortcuts() {
    return {
      for (final binding in _bindings) ...binding.activators,
    };
  }

  static Intent? matchEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return null;
    }

    for (final binding in _bindings) {
      if (binding.matches(event)) {
        return binding.intent;
      }
    }

    return null;
  }
}

class _ShortcutBinding {
  const _ShortcutBinding._({
    required this.key,
    required this.intent,
    required this.requiresModifier,
  });

  factory _ShortcutBinding.mod(LogicalKeyboardKey key, Intent intent) {
    return _ShortcutBinding._(
      key: key,
      intent: intent,
      requiresModifier: true,
    );
  }

  factory _ShortcutBinding.single(LogicalKeyboardKey key, Intent intent) {
    return _ShortcutBinding._(
      key: key,
      intent: intent,
      requiresModifier: false,
    );
  }

  final LogicalKeyboardKey key;
  final Intent intent;
  final bool requiresModifier;

  Map<ShortcutActivator, Intent> get activators {
    if (!requiresModifier) {
      return {
        LogicalKeySet(key): intent,
      };
    }

    return {
      LogicalKeySet(LogicalKeyboardKey.control, key): intent,
      LogicalKeySet(LogicalKeyboardKey.meta, key): intent,
    };
  }

  bool matches(KeyEvent event) {
    if (event.logicalKey != key) {
      return false;
    }

    if (!requiresModifier) {
      return true;
    }

    return HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
  }
}

class ShortcutExecutionGuard {
  ShortcutExecutionGuard({
    this.cooldown = const Duration(milliseconds: 400),
  });

  final Duration cooldown;
  final Map<Object, DateTime> _lastExecutionByShortcut = <Object, DateTime>{};

  bool canExecute(Object shortcutId, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final lastExecution = _lastExecutionByShortcut[shortcutId];

    if (lastExecution != null &&
        currentTime.difference(lastExecution) < cooldown) {
      return false;
    }

    _lastExecutionByShortcut[shortcutId] = currentTime;
    return true;
  }

  void reset([Object? shortcutId]) {
    if (shortcutId == null) {
      _lastExecutionByShortcut.clear();
      return;
    }

    _lastExecutionByShortcut.remove(shortcutId);
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
