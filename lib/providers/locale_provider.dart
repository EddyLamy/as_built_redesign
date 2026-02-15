import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

/// Provider que controla o locale atual - Riverpod 3.x annotation-based
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  String build() {
    _loadLocale();
    return 'pt';
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString('locale') ?? 'pt';
      if (state != savedLocale) {
        state = savedLocale;
      }
    } catch (e) {
      print('Erro ao carregar locale: $e');
    }
  }

  Future<void> setLocale(String locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', locale);
    } catch (e) {
      print('Erro ao salvar locale: $e');
    }
  }
}

/// Provider que retorna a string do locale - para compatibilidade
final localeStringProvider = Provider<String>((ref) {
  return ref.watch(localeProvider);
});
