import 'models/installation/tipo_fase.dart';
import 'i18n/installation_translations.dart';

void testModels() {
  // Testar enums
  final tipo = TipoFase.recepcao;
  print(tipo.getName('pt')); // "Receção"
  print(tipo.getName('en')); // "Reception"

  // Testar traduções
  print(InstallationTranslations.get('pending', 'pt')); // "Pendente"
  print(InstallationTranslations.get('pending', 'en')); // "Pending"

  print('✅ Imports OK!');
}
