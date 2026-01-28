import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODELO: TORQUE & TENSIONAMENTO - RASTREABILIDADE COMPLETA
// ═══════════════════════════════════════════════════════════════════════════
/// Representa uma conexão estrutural entre dois componentes da turbina
/// com dados de torque, tensionamento e rastreabilidade completa.
///
/// TODOS OS CAMPOS SÃO OPCIONAIS (exceto IDs e timestamps)
class TorqueTensioning {
  final String id;
  final String turbinaId;
  final String projectId;

  // ══════════════════════════════════════════════════════════════════════════
  // IDENTIFICAÇÃO DA CONEXÃO
  // ══════════════════════════════════════════════════════════════════════════
  final String componenteOrigem; // Ex: "Bottom", "Hub"
  final String componenteDestino; // Ex: "Middle 1", "Blade A"
  final String categoria; // Civil, Torre, Nacelle, Rotor, Outro

  /// Se true, é uma conexão gerada automaticamente (standard)
  final bool isStandard;

  /// Se true, é uma conexão adicionada manualmente pelo user
  final bool isExtra;

  /// Descrição customizada (para conexões extras)
  final String? descricao;

  // ══════════════════════════════════════════════════════════════════════════
  // TORQUE (OPCIONAL)
  // ══════════════════════════════════════════════════════════════════════════
  final double? torqueValue; // Ex: 1200
  final String? torqueUnit; // Ex: "Nm", "kNm", "ft-lb"

  // ══════════════════════════════════════════════════════════════════════════
  // TENSIONAMENTO (OPCIONAL)
  // ══════════════════════════════════════════════════════════════════════════
  final double? tensioningValue; // Ex: 850
  final String? tensioningUnit; // Ex: "kN", "lbf", "MPa"

  // ══════════════════════════════════════════════════════════════════════════
  // 🔩 RASTREABILIDADE - PARAFUSOS/STUDS (TODOS OPCIONAIS)
  // ══════════════════════════════════════════════════════════════════════════
  final String? boltMetric; // Ex: "M36", "M42", "M48", "2 inch"
  final int? boltQuantity; // Ex: 72, 96, 120
  final String? boltType; // Ex: "Stud", "Bolt", "Hex Bolt"
  final String? boltBatch; // Lote dos parafusos
  final String? boltVUI; // VUI dos parafusos
  final String? boltSerialNumber; // Serial dos parafusos
  final String? boltItemNumber; // Part number dos parafusos

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 RASTREABILIDADE - EQUIPAMENTO TORQUE (TODOS OPCIONAIS)
  // ══════════════════════════════════════════════════════════════════════════
  final String? torqueWrenchId; // ID da chave de torque
  final String? torqueWrenchSerial; // Serial da chave
  final DateTime? torqueWrenchCalibrationDate; // Data de calibração

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 RASTREABILIDADE - EQUIPAMENTO TENSIONAMENTO (TODOS OPCIONAIS)
  // ══════════════════════════════════════════════════════════════════════════
  final String? tensioningEquipmentId; // ID do equipamento
  final String? tensioningEquipmentSerial; // Serial do equipamento

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 RASTREABILIDADE - PROCEDIMENTOS (TODOS OPCIONAIS)
  // ══════════════════════════════════════════════════════════════════════════
  final String? workInstructionNumber; // Ex: "WI-001-Rev3"
  final String? qualityCheckNumber; // Ex: "QC-123", "ITP-456"
  final String? inspectorName; // Nome do inspetor
  final String? inspectorSignature; // URL assinatura digital
  final DateTime? inspectorSignedAt; // Data/hora da assinatura

  // ══════════════════════════════════════════════════════════════════════════
  // 🌡️ RASTREABILIDADE - CONDIÇÕES AMBIENTAIS (TODOS OPCIONAIS)
  // ══════════════════════════════════════════════════════════════════════════
  final double? temperatura; // °C
  final double? humidade; // %
  final String? condicoesMeteo; // "Sol", "Chuva leve", "Vento forte"

  // ══════════════════════════════════════════════════════════════════════════
  // 📸 DOCUMENTAÇÃO (OPCIONAIS)
  // ══════════════════════════════════════════════════════════════════════════
  final List<String> photoUrls; // URLs das fotos no Firebase Storage
  final String? observacoes; // Notas técnicas

  // ══════════════════════════════════════════════════════════════════════════
  // 📅 EXECUÇÃO (OPCIONAIS)
  // ══════════════════════════════════════════════════════════════════════════
  final DateTime? dataInicio; // Quando começou
  final DateTime? dataFim; // Quando terminou
  final String? executadoPor; // User ID
  final String? executadoPorNome; // Nome do técnico

  // ══════════════════════════════════════════════════════════════════════════
  // 📊 METADATA (OBRIGATÓRIOS - para auditoria)
  // ══════════════════════════════════════════════════════════════════════════
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;

  // ══════════════════════════════════════════════════════════════════════════
  // CONSTRUTOR
  // ══════════════════════════════════════════════════════════════════════════
  TorqueTensioning({
    required this.id,
    required this.turbinaId,
    required this.projectId,
    required this.componenteOrigem,
    required this.componenteDestino,
    required this.categoria,
    this.isStandard = false,
    this.isExtra = false,
    this.descricao,
    // Torque
    this.torqueValue,
    this.torqueUnit,
    // Tensionamento
    this.tensioningValue,
    this.tensioningUnit,
    // Parafusos
    this.boltMetric,
    this.boltQuantity,
    this.boltType,
    this.boltBatch,
    this.boltVUI,
    this.boltSerialNumber,
    this.boltItemNumber,
    // Equipamento Torque
    this.torqueWrenchId,
    this.torqueWrenchSerial,
    this.torqueWrenchCalibrationDate,
    // Equipamento Tensionamento
    this.tensioningEquipmentId,
    this.tensioningEquipmentSerial,
    // Procedimentos
    this.workInstructionNumber,
    this.qualityCheckNumber,
    this.inspectorName,
    this.inspectorSignature,
    this.inspectorSignedAt,
    // Condições
    this.temperatura,
    this.humidade,
    this.condicoesMeteo,
    // Documentação
    this.photoUrls = const [],
    this.observacoes,
    // Execução
    this.dataInicio,
    this.dataFim,
    this.executadoPor,
    this.executadoPorNome,
    // Metadata
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // CONVERSÃO PARA FIRESTORE
  // ══════════════════════════════════════════════════════════════════════════
  Map<String, dynamic> toFirestore() {
    return {
      'turbinaId': turbinaId,
      'projectId': projectId,
      'componenteOrigem': componenteOrigem,
      'componenteDestino': componenteDestino,
      'categoria': categoria,
      'isStandard': isStandard,
      'isExtra': isExtra,
      'descricao': descricao,

      // Torque
      if (torqueValue != null || torqueUnit != null)
        'torque': {
          if (torqueValue != null) 'value': torqueValue,
          if (torqueUnit != null) 'unit': torqueUnit,
        },

      // Tensionamento
      if (tensioningValue != null || tensioningUnit != null)
        'tensioning': {
          if (tensioningValue != null) 'value': tensioningValue,
          if (tensioningUnit != null) 'unit': tensioningUnit,
        },

      // Parafusos
      if (boltMetric != null ||
          boltQuantity != null ||
          boltType != null ||
          boltBatch != null ||
          boltVUI != null ||
          boltSerialNumber != null ||
          boltItemNumber != null)
        'bolts': {
          if (boltMetric != null) 'metric': boltMetric,
          if (boltQuantity != null) 'quantity': boltQuantity,
          if (boltType != null) 'type': boltType,
          if (boltBatch != null) 'batch': boltBatch,
          if (boltVUI != null) 'vui': boltVUI,
          if (boltSerialNumber != null) 'serialNumber': boltSerialNumber,
          if (boltItemNumber != null) 'itemNumber': boltItemNumber,
        },

      // Equipamento Torque
      if (torqueWrenchId != null ||
          torqueWrenchSerial != null ||
          torqueWrenchCalibrationDate != null)
        'torqueWrench': {
          if (torqueWrenchId != null) 'id': torqueWrenchId,
          if (torqueWrenchSerial != null) 'serialNumber': torqueWrenchSerial,
          if (torqueWrenchCalibrationDate != null)
            'calibrationDate': Timestamp.fromDate(torqueWrenchCalibrationDate!),
        },

      // Equipamento Tensionamento
      if (tensioningEquipmentId != null || tensioningEquipmentSerial != null)
        'tensioningEquipment': {
          if (tensioningEquipmentId != null) 'id': tensioningEquipmentId,
          if (tensioningEquipmentSerial != null)
            'serialNumber': tensioningEquipmentSerial,
        },

      // Procedimentos
      if (workInstructionNumber != null ||
          qualityCheckNumber != null ||
          inspectorName != null ||
          inspectorSignature != null ||
          inspectorSignedAt != null)
        'procedures': {
          if (workInstructionNumber != null)
            'workInstructionNumber': workInstructionNumber,
          if (qualityCheckNumber != null)
            'qualityCheckNumber': qualityCheckNumber,
          if (inspectorName != null) 'inspectorName': inspectorName,
          if (inspectorSignature != null)
            'inspectorSignature': inspectorSignature,
          if (inspectorSignedAt != null)
            'signedAt': Timestamp.fromDate(inspectorSignedAt!),
        },

      // Condições Ambientais
      if (temperatura != null || humidade != null || condicoesMeteo != null)
        'ambientConditions': {
          if (temperatura != null) 'temperatura': temperatura,
          if (humidade != null) 'humidade': humidade,
          if (condicoesMeteo != null) 'condicoesMeteo': condicoesMeteo,
        },

      // Documentação
      'photoUrls': photoUrls,
      'observacoes': observacoes,

      // Execução
      if (dataInicio != null) 'dataInicio': Timestamp.fromDate(dataInicio!),
      if (dataFim != null) 'dataFim': Timestamp.fromDate(dataFim!),
      'executadoPor': executadoPor,
      'executadoPorNome': executadoPorNome,

      // Metadata
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONVERSÃO DE FIRESTORE
  // ══════════════════════════════════════════════════════════════════════════
  factory TorqueTensioning.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper para extrair valores nested
    final torqueMap = data['torque'] as Map<String, dynamic>?;
    final tensioningMap = data['tensioning'] as Map<String, dynamic>?;
    final boltsMap = data['bolts'] as Map<String, dynamic>?;
    final torqueWrenchMap = data['torqueWrench'] as Map<String, dynamic>?;
    final tensioningEquipmentMap =
        data['tensioningEquipment'] as Map<String, dynamic>?;
    final proceduresMap = data['procedures'] as Map<String, dynamic>?;
    final ambientMap = data['ambientConditions'] as Map<String, dynamic>?;

    return TorqueTensioning(
      id: doc.id,
      turbinaId: data['turbinaId'] ?? '',
      projectId: data['projectId'] ?? '',
      componenteOrigem: data['componenteOrigem'] ?? '',
      componenteDestino: data['componenteDestino'] ?? '',
      categoria: data['categoria'] ?? 'Outro',
      isStandard: data['isStandard'] ?? false,
      isExtra: data['isExtra'] ?? false,
      descricao: data['descricao'],

      // Torque
      torqueValue: torqueMap?['value']?.toDouble(),
      torqueUnit: torqueMap?['unit'],

      // Tensionamento
      tensioningValue: tensioningMap?['value']?.toDouble(),
      tensioningUnit: tensioningMap?['unit'],

      // Parafusos
      boltMetric: boltsMap?['metric'],
      boltQuantity: boltsMap?['quantity'],
      boltType: boltsMap?['type'],
      boltBatch: boltsMap?['batch'],
      boltVUI: boltsMap?['vui'],
      boltSerialNumber: boltsMap?['serialNumber'],
      boltItemNumber: boltsMap?['itemNumber'],

      // Equipamento Torque
      torqueWrenchId: torqueWrenchMap?['id'],
      torqueWrenchSerial: torqueWrenchMap?['serialNumber'],
      torqueWrenchCalibrationDate: torqueWrenchMap?['calibrationDate'] != null
          ? (torqueWrenchMap!['calibrationDate'] as Timestamp).toDate()
          : null,

      // Equipamento Tensionamento
      tensioningEquipmentId: tensioningEquipmentMap?['id'],
      tensioningEquipmentSerial: tensioningEquipmentMap?['serialNumber'],

      // Procedimentos
      workInstructionNumber: proceduresMap?['workInstructionNumber'],
      qualityCheckNumber: proceduresMap?['qualityCheckNumber'],
      inspectorName: proceduresMap?['inspectorName'],
      inspectorSignature: proceduresMap?['inspectorSignature'],
      inspectorSignedAt: proceduresMap?['signedAt'] != null
          ? (proceduresMap!['signedAt'] as Timestamp).toDate()
          : null,

      // Condições
      temperatura: ambientMap?['temperatura']?.toDouble(),
      humidade: ambientMap?['humidade']?.toDouble(),
      condicoesMeteo: ambientMap?['condicoesMeteo'],

      // Documentação
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      observacoes: data['observacoes'],

      // Execução
      dataInicio: data['dataInicio'] != null
          ? (data['dataInicio'] as Timestamp).toDate()
          : null,
      dataFim: data['dataFim'] != null
          ? (data['dataFim'] as Timestamp).toDate()
          : null,
      executadoPor: data['executadoPor'],
      executadoPorNome: data['executadoPorNome'],

      // Metadata
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      updatedBy: data['updatedBy'] ?? '',
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COPY WITH
  // ══════════════════════════════════════════════════════════════════════════
  TorqueTensioning copyWith({
    String? id,
    String? turbinaId,
    String? projectId,
    String? componenteOrigem,
    String? componenteDestino,
    String? categoria,
    bool? isStandard,
    bool? isExtra,
    String? descricao,
    double? torqueValue,
    String? torqueUnit,
    double? tensioningValue,
    String? tensioningUnit,
    String? boltMetric,
    int? boltQuantity,
    String? boltType,
    String? boltBatch,
    String? boltVUI,
    String? boltSerialNumber,
    String? boltItemNumber,
    String? torqueWrenchId,
    String? torqueWrenchSerial,
    DateTime? torqueWrenchCalibrationDate,
    String? tensioningEquipmentId,
    String? tensioningEquipmentSerial,
    String? workInstructionNumber,
    String? qualityCheckNumber,
    String? inspectorName,
    String? inspectorSignature,
    DateTime? inspectorSignedAt,
    double? temperatura,
    double? humidade,
    String? condicoesMeteo,
    List<String>? photoUrls,
    String? observacoes,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? executadoPor,
    String? executadoPorNome,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return TorqueTensioning(
      id: id ?? this.id,
      turbinaId: turbinaId ?? this.turbinaId,
      projectId: projectId ?? this.projectId,
      componenteOrigem: componenteOrigem ?? this.componenteOrigem,
      componenteDestino: componenteDestino ?? this.componenteDestino,
      categoria: categoria ?? this.categoria,
      isStandard: isStandard ?? this.isStandard,
      isExtra: isExtra ?? this.isExtra,
      descricao: descricao ?? this.descricao,
      torqueValue: torqueValue ?? this.torqueValue,
      torqueUnit: torqueUnit ?? this.torqueUnit,
      tensioningValue: tensioningValue ?? this.tensioningValue,
      tensioningUnit: tensioningUnit ?? this.tensioningUnit,
      boltMetric: boltMetric ?? this.boltMetric,
      boltQuantity: boltQuantity ?? this.boltQuantity,
      boltType: boltType ?? this.boltType,
      boltBatch: boltBatch ?? this.boltBatch,
      boltVUI: boltVUI ?? this.boltVUI,
      boltSerialNumber: boltSerialNumber ?? this.boltSerialNumber,
      boltItemNumber: boltItemNumber ?? this.boltItemNumber,
      torqueWrenchId: torqueWrenchId ?? this.torqueWrenchId,
      torqueWrenchSerial: torqueWrenchSerial ?? this.torqueWrenchSerial,
      torqueWrenchCalibrationDate:
          torqueWrenchCalibrationDate ?? this.torqueWrenchCalibrationDate,
      tensioningEquipmentId:
          tensioningEquipmentId ?? this.tensioningEquipmentId,
      tensioningEquipmentSerial:
          tensioningEquipmentSerial ?? this.tensioningEquipmentSerial,
      workInstructionNumber:
          workInstructionNumber ?? this.workInstructionNumber,
      qualityCheckNumber: qualityCheckNumber ?? this.qualityCheckNumber,
      inspectorName: inspectorName ?? this.inspectorName,
      inspectorSignature: inspectorSignature ?? this.inspectorSignature,
      inspectorSignedAt: inspectorSignedAt ?? this.inspectorSignedAt,
      temperatura: temperatura ?? this.temperatura,
      humidade: humidade ?? this.humidade,
      condicoesMeteo: condicoesMeteo ?? this.condicoesMeteo,
      photoUrls: photoUrls ?? this.photoUrls,
      observacoes: observacoes ?? this.observacoes,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      executadoPor: executadoPor ?? this.executadoPor,
      executadoPorNome: executadoPorNome ?? this.executadoPorNome,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS - CALCULAR PROGRESSO
  // ══════════════════════════════════════════════════════════════════════════

  /// Calcula o progresso desta conexão (0-100%)
  /// Baseado nos campos preenchidos
  int get progresso {
    int total = 0;
    int preenchidos = 0;

    // Torque (peso 2)
    total += 2;
    if (torqueValue != null && torqueUnit != null) preenchidos += 2;

    // Tensionamento (peso 2)
    total += 2;
    if (tensioningValue != null && tensioningUnit != null) preenchidos += 2;

    // Parafusos (peso 1)
    total += 1;
    if (boltMetric != null || boltQuantity != null) preenchidos += 1;

    // Datas (peso 1)
    total += 1;
    if (dataInicio != null && dataFim != null) preenchidos += 1;

    // Fotos (peso 1)
    total += 1;
    if (photoUrls.isNotEmpty) preenchidos += 1;

    return total > 0 ? ((preenchidos / total) * 100).round() : 0;
  }

  /// Se a conexão está completa (tem pelo menos torque OU tensionamento)
  bool get isCompleto {
    return (torqueValue != null && torqueUnit != null) ||
        (tensioningValue != null && tensioningUnit != null);
  }

  /// Se a conexão tem dados parciais
  bool get isEmProgresso {
    return !isCompleto && progresso > 0;
  }

  /// Se a conexão está pendente (sem dados)
  bool get isPendente {
    return progresso == 0;
  }

  /// Status calculado baseado no progresso
  String get status {
    if (isCompleto) return 'Concluído';
    if (isEmProgresso) return 'Em Progresso';
    return 'Pendente';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELO: TEMPLATE DE CONEXÃO
// ═══════════════════════════════════════════════════════════════════════════
/// Template para gerar conexões standard automaticamente
class ConexaoTemplate {
  final String tipo; // Ex: "bottom_middle1", "hub_blade_a"
  final String origem; // Ex: "Bottom", "Hub"
  final String destino; // Ex: "Middle 1", "Blade A"
  final String categoria; // Civil, Torre, Nacelle, Rotor
  final int ordem; // Ordem sequencial

  ConexaoTemplate({
    required this.tipo,
    required this.origem,
    required this.destino,
    required this.categoria,
    required this.ordem,
  });
}
