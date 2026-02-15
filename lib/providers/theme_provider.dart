import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// Provider que controla o tema atual - Riverpod 3.x annotation-based
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  String build() {
    _loadTheme();
    return 'light';
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme') ?? 'light';
      if (state != savedTheme) {
        state = savedTheme;
      }
    } catch (e) {
      print('Erro ao carregar tema: $e');
    }
  }

  Future<void> setTheme(String theme) async {
    if (theme != 'light' && theme != 'dark') return;

    state = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', theme);
    } catch (e) {
      print('Erro ao salvar tema: $e');
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state == 'light' ? 'dark' : 'light';
    await setTheme(newTheme);
  }
}

/// Provider que retorna a string do tema - para compatibilidade
final themeStringProvider = Provider<String>((ref) {
  return ref.watch(themeProvider);
});
