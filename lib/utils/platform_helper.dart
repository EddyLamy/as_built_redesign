import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper para detectar plataforma e comportamentos específicos
class PlatformHelper {
  // ══════════════════════════════════════════════════════════════════════════
  // DETECÇÃO DE PLATAFORMA
  // ══════════════════════════════════════════════════════════════════════════

  /// Verifica se está em mobile (Android ou iOS)
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Verifica se está em desktop (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Verifica se está em web
  static bool get isWeb => kIsWeb;

  /// Verifica se está em Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Verifica se está em iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Verifica se está em Windows
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// Verifica se está em macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// Verifica se está em Linux
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOME DA PLATAFORMA
  // ══════════════════════════════════════════════════════════════════════════

  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CAPACIDADES DA PLATAFORMA
  // ══════════════════════════════════════════════════════════════════════════

  /// Suporta câmera
  static bool get supportsCamera => isMobile;

  /// Suporta relatórios (Python scripts)
  static bool get supportsReports => isDesktop;

  /// Suporta drawer lateral
  static bool get supportsDrawer => isDesktop;

  /// Suporta multi-window
  static bool get supportsMultiWindow => isDesktop;

  /// Suporta notificações push
  static bool get supportsPushNotifications => isMobile;

  // ══════════════════════════════════════════════════════════════════════════
  // MENSAGENS DE ERRO/INFO
  // ══════════════════════════════════════════════════════════════════════════

  static String get reportsNotAvailableMessage {
    if (isMobile) {
      return 'Relatórios estão disponíveis apenas na versão desktop';
    }
    return 'Relatórios não disponíveis nesta plataforma';
  }

  static String get dashboardNotAvailableMessage {
    if (isMobile) {
      return 'Dashboard está disponível apenas na versão desktop';
    }
    return 'Dashboard não disponível nesta plataforma';
  }
}
