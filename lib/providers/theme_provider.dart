import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que gere o tema atual (light/dark)
final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super('light') {
    _loadTheme();
  }

  /// Carregar tema salvo
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme') ?? 'light';
      state = savedTheme;
    } catch (e) {
      print('Erro ao carregar tema: $e');
    }
  }

  /// Mudar tema
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

  /// Toggle entre light e dark
  Future<void> toggleTheme() async {
    final newTheme = state == 'light' ? 'dark' : 'light';
    await setTheme(newTheme);
  }
}
