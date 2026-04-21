// ══════════════════════════════════════════════════════════════
// EQUIPMENT MODEL
// lib/models/equipment.dart
// ══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum EquipmentType {
  chaveTorque('chave_torque', 'Chave de Torque'),
  bombaTorque('bomba_torque', 'Bomba de Torque'),
  puller('puller', 'Puller (Tensionamento)'),
  bombaTensionamento('bomba_tensionamento', 'Bomba de Tensionamento'),
  chaveDinometrica('chave_dinometrica', 'Chave Dinométrica'),
  outro('outro', 'Outro');

  const EquipmentType(this.value, this.label);
  final String value;
  final String label;
}

enum EquipmentStatus {
  disponivel('disponivel', 'Disponível', '🟢'),
  emUso('em_uso', 'Em Uso', '🟡'),
  manutencao('manutencao', 'Manutenção', '🔵'),
  expirado('expirado', 'Expirado', '🔴');

  const EquipmentStatus(this.value, this.label, this.icon);
  final String value;
  final String label;
  final String icon;
}

enum EquipmentCondition {
  bom('bom', 'Bom'),
  regular('regular', 'Regular'),
  necessitaManutencao('necessita_manutencao', 'Necessita Manutenção');

  const EquipmentCondition(this.value, this.label);
  final String value;
  final String label;
}

class CalibrationData {
  final String lastDate;
  final String expiryDate;
  final int? daysUntilExpiry;
  final String certificateNumber;
  final String certificatePath;

  CalibrationData({
    required this.lastDate,
    required this.expiryDate,
    this.daysUntilExpiry,
    required this.certificateNumber,
    required this.certificatePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'lastDate': lastDate,
      'expiryDate': expiryDate,
      'daysUntilExpiry': daysUntilExpiry,
      'certificateNumber': certificateNumber,
      'certificatePath': certificatePath,
    };
  }

  factory CalibrationData.fromMap(Map<String, dynamic> map) {
    return CalibrationData(
      lastDate: map['lastDate'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      daysUntilExpiry: map['daysUntilExpiry'],
      certificateNumber: map['certificateNumber'] ?? '',
      certificatePath: map['certificatePath'] ?? '',
    );
  }

  CalibrationData copyWith({
    String? lastDate,
    String? expiryDate,
    int? daysUntilExpiry,
    String? certificateNumber,
    String? certificatePath,
  }) {
    return CalibrationData(
      lastDate: lastDate ?? this.lastDate,
      expiryDate: expiryDate ?? this.expiryDate,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      certificatePath: certificatePath ?? this.certificatePath,
    );
  }
}

class EquipmentUsageRecord {
  final String date;
  final String projectId;
  final String projectName;
  final String turbineId;
  final String connection;
  final String? operation;
  final String user;
  final String userId;

  EquipmentUsageRecord({
    required this.date,
    required this.projectId,
    required this.projectName,
    required this.turbineId,
    required this.connection,
    this.operation,
    required this.user,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'projectId': projectId,
      'projectName': projectName,
      'turbineId': turbineId,
      'connection': connection,
      'operation': operation,
      'user': user,
      'userId': userId,
    };
  }

  factory EquipmentUsageRecord.fromMap(Map<String, dynamic> map) {
    return EquipmentUsageRecord(
      date: map['date'] ?? '',
      projectId: map['projectId'] ?? '',
      projectName: map['projectName'] ?? '',
      turbineId: map['turbineId'] ?? '',
      connection: map['connection'] ?? '',
      operation: map['operation'],
      user: map['user'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}

class Equipment {
  final String equipmentId;
  final String projectId;
  final EquipmentType type;
  final String manufacturer;
  final String model;
  final String serialNumber;
  final String? description;
  final CalibrationData calibration;
  final EquipmentStatus status;
  final String? currentProject;
  final String? currentProjectName;
  final String currentLocation;
  final EquipmentCondition condition;
  final List<EquipmentUsageRecord> usageHistory;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  Equipment({
    required this.equipmentId,
    required this.projectId,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.serialNumber,
    this.description,
    required this.calibration,
    required this.status,
    this.currentProject,
    this.currentProjectName,
    required this.currentLocation,
    required this.condition,
    required this.usageHistory,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'projectId': projectId,
      'type': type.value,
      'manufacturer': manufacturer,
      'model': model,
      'serialNumber': serialNumber,
      'description': description,
      'calibration': calibration.toMap(),
      'status': status.value,
      'currentProject': currentProject,
      'currentProjectName': currentProjectName,
      'currentLocation': currentLocation,
      'condition': condition.value,
      'usageHistory': usageHistory.map((e) => e.toMap()).toList(),
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      equipmentId: map['equipmentId'] ?? '',
      projectId: map['projectId'] ?? '',
      type: EquipmentType.values.firstWhere(
        (e) => e.value == map['type'],
        orElse: () => EquipmentType.outro,
      ),
      manufacturer: map['manufacturer'] ?? '',
      model: map['model'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      description: map['description'],
      calibration: CalibrationData.fromMap(map['calibration'] ?? {}),
      status: EquipmentStatus.values.firstWhere(
        (e) => e.value == map['status'],
        orElse: () => EquipmentStatus.disponivel,
      ),
      currentProject: map['currentProject'],
      currentProjectName: map['currentProjectName'],
      currentLocation: map['currentLocation'] ?? '',
      condition: EquipmentCondition.values.firstWhere(
        (e) => e.value == map['condition'],
        orElse: () => EquipmentCondition.bom,
      ),
      usageHistory: (map['usageHistory'] as List<dynamic>?)
              ?.map((e) => EquipmentUsageRecord.fromMap(e))
              .toList() ??
          [],
      notes: map['notes'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedBy: map['updatedBy'],
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Equipment copyWith({
    String? equipmentId,
    String? projectId,
    EquipmentType? type,
    String? manufacturer,
    String? model,
    String? serialNumber,
    String? description,
    CalibrationData? calibration,
    EquipmentStatus? status,
    String? currentProject,
    String? currentProjectName,
    String? currentLocation,
    EquipmentCondition? condition,
    List<EquipmentUsageRecord>? usageHistory,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return Equipment(
      equipmentId: equipmentId ?? this.equipmentId,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      description: description ?? this.description,
      calibration: calibration ?? this.calibration,
      status: status ?? this.status,
      currentProject: currentProject ?? this.currentProject,
      currentProjectName: currentProjectName ?? this.currentProjectName,
      currentLocation: currentLocation ?? this.currentLocation,
      condition: condition ?? this.condition,
      usageHistory: usageHistory ?? this.usageHistory,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calcular dias até expiração
  int calculateDaysUntilExpiry() {
    try {
      final expiry = _parseDate(calibration.expiryDate);
      final today = DateTime.now();
      final difference = expiry.difference(today).inDays;
      return difference;
    } catch (e) {
      return 0;
    }
  }

  // Parsear data DD/MM/YYYY
  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length != 3) throw FormatException('Invalid date format');
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }

  // Verificar se calibração está válida
  bool get isCalibrationValid => calculateDaysUntilExpiry() > 0;

  // Obter alerta de calibração
  CalibrationAlert? get calibrationAlert {
    final days = calculateDaysUntilExpiry();

    if (days <= 0) {
      return CalibrationAlert(
        type: CalibrationAlertType.expirado,
        severity: CalibrationAlertSeverity.critical,
        message: '⛔ $model - Calibração EXPIRADA',
        equipment: this,
        daysUntilExpiry: days,
      );
    } else if (days <= 7) {
      return CalibrationAlert(
        type: CalibrationAlertType.urgente,
        severity: CalibrationAlertSeverity.high,
        message: '🔴 $model - Calibração expira em $days dia(s)',
        equipment: this,
        daysUntilExpiry: days,
      );
    } else if (days <= 30) {
      return CalibrationAlert(
        type: CalibrationAlertType.aviso,
        severity: CalibrationAlertSeverity.medium,
        message: '🟡 $model - Calibração expira em $days dia(s)',
        equipment: this,
        daysUntilExpiry: days,
      );
    }

    return null;
  }
}

// ══════════════════════════════════════════════════════════════
// ALERTAS DE CALIBRAÇÃO
// ══════════════════════════════════════════════════════════════

enum CalibrationAlertType {
  expirado,
  urgente,
  aviso,
}

enum CalibrationAlertSeverity {
  critical,
  high,
  medium,
}

class CalibrationAlert {
  final CalibrationAlertType type;
  final CalibrationAlertSeverity severity;
  final String message;
  final Equipment equipment;
  final int daysUntilExpiry;

  CalibrationAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.equipment,
    required this.daysUntilExpiry,
  });
}
