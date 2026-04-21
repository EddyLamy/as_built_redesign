import 'package:as_built/utils/keyboard_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeyboardShortcuts', () {
    test('registers desktop productivity and navigation shortcuts', () {
      final shortcuts = KeyboardShortcuts.getMainShortcuts();

      expect(
        shortcuts[
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN)],
        isA<NewProjectIntent>(),
      );
      expect(
        shortcuts[
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN)],
        isA<NewProjectIntent>(),
      );
      expect(
        shortcuts[
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT)],
        isA<AddTurbineIntent>(),
      );
      expect(
        shortcuts[
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR)],
        isA<GenerateReportIntent>(),
      );
      expect(
        shortcuts[
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF)],
        isA<SearchIntent>(),
      );
      expect(
        shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control, LogicalKeyboardKey.comma)],
        isA<OpenSettingsIntent>(),
      );
      expect(
        shortcuts[LogicalKeySet(LogicalKeyboardKey.f1)],
        isA<OpenHelpIntent>(),
      );
      expect(
        shortcuts[
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL)],
        isA<ToggleLanguageIntent>(),
      );
      expect(
        shortcuts[
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD)],
        isA<ToggleThemeIntent>(),
      );
    });
  });

  group('ShortcutExecutionGuard', () {
    test('blocks repeated execution inside cooldown window', () {
      final guard = ShortcutExecutionGuard(
        cooldown: const Duration(milliseconds: 400),
      );
      final origin = DateTime(2026, 4, 15, 10, 0, 0);

      expect(guard.canExecute('new-project', now: origin), isTrue);
      expect(
        guard.canExecute(
          'new-project',
          now: origin.add(const Duration(milliseconds: 200)),
        ),
        isFalse,
      );
      expect(
        guard.canExecute(
          'new-project',
          now: origin.add(const Duration(milliseconds: 450)),
        ),
        isTrue,
      );
    });

    test('tracks each shortcut independently', () {
      final guard = ShortcutExecutionGuard(
        cooldown: const Duration(milliseconds: 400),
      );
      final origin = DateTime(2026, 4, 15, 10, 0, 0);

      expect(guard.canExecute('theme', now: origin), isTrue);
      expect(
        guard.canExecute(
          'language',
          now: origin.add(const Duration(milliseconds: 100)),
        ),
        isTrue,
      );
    });
  });
}
