import 'package:flutter/material.dart';
import 'translations_pt.dart';
import 'translations_en.dart';

class TranslationHelper {
  final Locale locale;
  late Map<String, String> _translations;

  TranslationHelper(this.locale) {
    _translations =
        locale.languageCode == 'pt' ? translationsPT : translationsEN;
  }

  String translate(String key) {
    return _translations[key] ?? key;
  }

  // Helper methods para traduzir valores específicos
  String translateStatus(String status) {
    return translate('status_$status');
  }

  static TranslationHelper of(BuildContext context) {
    return Localizations.of<TranslationHelper>(context, TranslationHelper)!;
  }
}

class TranslationDelegate extends LocalizationsDelegate<TranslationHelper> {
  const TranslationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en'].contains(locale.languageCode);
  }

  @override
  Future<TranslationHelper> load(Locale locale) async {
    return TranslationHelper(locale);
  }

  @override
  bool shouldReload(TranslationDelegate old) => false;
}
