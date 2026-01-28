import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider para o locale atual (retorna String: 'pt' ou 'en')
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('pt') {
    // ← Agora String
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'pt';
    state = languageCode; // ← String direto
  }

  Future<void> setLocale(String languageCode) async {
    state = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  void toggleLanguage() {
    final newLocale = state == 'pt' ? 'en' : 'pt'; // ← String
    setLocale(newLocale);
  }
}
