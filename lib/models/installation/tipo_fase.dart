// ENUMS - TIPOS DE FASE E TRABALHOS

import '../../i18n/installation_translations.dart';

/// Tipos de fase de componentes e checkpoints
enum TipoFase {
  // ────── FASES DE COMPONENTES ──────
  recepcao,
  preparacao,
  preInstalacao,
  instalacao,
  torqueTensionamento, // 🆕 NOVA FASE TORQUE & TENSIONING

  // ────── CHECKPOINTS GERAIS ──────
  eletricos,
  mecanicosGerais,
  finish,
  inspecaoSupervisor,
  punchlist,
  inspecaoCliente,
  punchlistCliente,
}

/// Tipo de trabalho mecânico em ligações
enum TipoTrabalhoMecanico {
  torque,
  tensionamento,
}

/// Extensões para TipoFase
extension TipoFaseExtension on TipoFase {
  /// Nome legível (traduzido)
  String getName(String locale) {
    return InstallationTranslations.getString(nameKey, locale);
  }

  /// Nome em português (compatibilidade)
  String get name => getName('pt');

  /// Chave para tradução
  String get nameKey {
    switch (this) {
      case TipoFase.recepcao:
        return 'reception';
      case TipoFase.preparacao:
        return 'preparation';
      case TipoFase.preInstalacao:
        return 'preInstallation';
      case TipoFase.instalacao:
        return 'installation';
      case TipoFase.torqueTensionamento: // 🆕 NOVA TRADUÇÃO
        return 'torqueTensioning';
      case TipoFase.eletricos:
        return 'electricalWorks';
      case TipoFase.mecanicosGerais:
        return 'mechanicalWorks';
      case TipoFase.finish:
        return 'finish';
      case TipoFase.inspecaoSupervisor:
        return 'supervisorInspection';
      case TipoFase.punchlist:
        return 'punchlist';
      case TipoFase.inspecaoCliente:
        return 'clientInspection';
      case TipoFase.punchlistCliente:
        return 'clientPunchlist';
    }
  }

  /// É uma fase de componente (não é checkpoint)
  bool get isFaseComponente {
    return this == TipoFase.recepcao ||
        this == TipoFase.preparacao ||
        this == TipoFase.preInstalacao ||
        this == TipoFase.instalacao ||
        this == TipoFase.torqueTensionamento; // 🆕 INCLUÍDO AQUI
  }

  /// É um checkpoint geral
  bool get isCheckpoint {
    return !isFaseComponente;
  }

  /// Requer horas (além das datas)
  bool get requerHoras {
    return this == TipoFase.recepcao ||
        this == TipoFase.preInstalacao ||
        this == TipoFase.instalacao;
  }

  /// Requer traceabilidade (VUI, Serial, Item)
  bool get requerTraceabilidade {
    return this == TipoFase.recepcao || this == TipoFase.instalacao;
  }

  /// Converter string para enum
  static TipoFase fromString(String value) {
    return TipoFase.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TipoFase.recepcao,
    );
  }
}

/// Extensões para TipoTrabalhoMecanico
extension TipoTrabalhoMecanicoExtension on TipoTrabalhoMecanico {
  /// Nome legível (traduzido)
  String getName(String locale) {
    return InstallationTranslations.getString(nameKey, locale);
  }

  /// Nome em português (compatibilidade)
  String get name => getName('pt');

  /// Chave para tradução
  String get nameKey {
    switch (this) {
      case TipoTrabalhoMecanico.torque:
        return 'torque';
      case TipoTrabalhoMecanico.tensionamento:
        return 'tensioning';
    }
  }

  /// Converter string para enum
  static TipoTrabalhoMecanico fromString(String value) {
    return TipoTrabalhoMecanico.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TipoTrabalhoMecanico.torque,
    );
  }
}
