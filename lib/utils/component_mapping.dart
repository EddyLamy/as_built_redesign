// lib/utils/component_mapping.dart

/// Utilitário para mapear IDs hardcoded da Instalação para nomes de componentes
class ComponentMapping {
  // ══════════════════════════════════════════════════════════════════════════
  // 📋 MAPEAMENTO: hardcodedId → Nome do Componente
  // ══════════════════════════════════════════════════════════════════════════
  static final Map<String, String> hardcodedToName = {
    // Tower Sections
    'bottom': 'Tower Section - Bottom',
    'middle1': 'Tower Section - Middle 1',
    'middle2': 'Tower Section - Middle 2',
    'middle3': 'Tower Section - Middle 3',
    'middle4': 'Tower Section - Middle 4',
    'middle5': 'Tower Section - Middle 5',
    'top': 'Tower Section - Top',

    // Main Components
    'nacelle': 'Nacelle',
    'drive_train': 'Drive Train',
    'hub': 'Hub',
    'blade_1': 'Blade 1',
    'blade_2': 'Blade 2',
    'blade_3': 'Blade 3',

    // Electrical & Auxiliary (existing)
    'mv_cable': 'MV Cable',
    'swg': 'SWG',
    'top_cooler': 'Top Cooler',

    // 🆕 ELECTRICAL SYSTEMS (new components)
    'transformador': 'Transformador',
    'gerador': 'Gerador',
    'ground_control': 'Ground Control',
    'light_control': 'Light Control',
    'light_battery': 'Light Battery',
    'ups': 'UPS',

    // 🆕 MECHANICAL SYSTEMS (new components)
    'gearbox': 'Gearbox',
    'coupling': 'Coupling',
    'service_lift': 'Service Lift',
    'lift_cables': 'Lift Cables',

    // 🆕 AUXILIARY SYSTEMS (new components)
    'resq': 'ResQ',
    'aviation_light_1': 'Aviation Light 1',
    'aviation_light_2': 'Aviation Light 2',
    'grua_interna': 'Grua Interna',
    'cms': 'CMS',

    // 🆕 CIVIL WORKS (new components)
    'anchor_bolts': 'Anchor Bolts',

    // Dynamic Components (podem ter múltiplos)
    'spare_parts': 'Spare Parts',
    'bodies_parts': 'Bodies Parts',
  };

  // ══════════════════════════════════════════════════════════════════════════
  // 🔄 MAPEAMENTO REVERSO: Nome → hardcodedId
  // ══════════════════════════════════════════════════════════════════════════
  static final Map<String, String> nameToHardcoded = {
    for (var entry in hardcodedToName.entries) entry.value: entry.key
  };

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 EXTRAIR hardcodedId de um componenteId completo
  // ══════════════════════════════════════════════════════════════════════════
  /// Extrai o hardcoded ID de um componenteId completo
  ///
  /// Exemplo:
  /// - Input: "bottom_SBIL6540tSwkucPNzRZk"
  /// - Output: "bottom"
  static String extractHardcodedId(String fullComponentId) {
    final parts = fullComponentId.split('_');
    if (parts.length >= 2) {
      // Remove o último elemento (turbinaId)
      return parts.sublist(0, parts.length - 1).join('_');
    }
    return fullComponentId;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📝 OBTER nome do componente a partir do ID completo
  // ══════════════════════════════════════════════════════════════════════════
  /// Obtém o nome do componente a partir do ID completo
  ///
  /// Exemplo:
  /// - Input: "bottom_SBIL6540tSwkucPNzRZk"
  /// - Output: "Tower Section - Bottom"
  static String? getComponentName(String fullComponentId) {
    final hardcodedId = extractHardcodedId(fullComponentId);
    return hardcodedToName[hardcodedId];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 OBTER hardcodedId a partir do nome
  // ══════════════════════════════════════════════════════════════════════════
  /// Obtém o hardcodedId a partir do nome do componente
  ///
  /// Exemplo:
  /// - Input: "Tower Section - Bottom"
  /// - Output: "bottom"
  static String? getHardcodedId(String componentName) {
    return nameToHardcoded[componentName];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆔 CONSTRUIR componenteId completo
  // ══════════════════════════════════════════════════════════════════════════
  /// Constrói o componenteId completo usado em installation_data/
  ///
  /// Exemplo:
  /// - Input: hardcodedId="bottom", turbinaId="SBIL6540tSwkucPNzRZk"
  /// - Output: "bottom_SBIL6540tSwkucPNzRZk"
  static String buildFullComponentId(String hardcodedId, String turbinaId) {
    return '${hardcodedId}_$turbinaId';
  }
}
