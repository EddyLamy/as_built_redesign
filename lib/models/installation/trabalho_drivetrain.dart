import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════
// TRABALHO DRIVE TRAIN (TORQUE APLICADO)
// ═══════════════════════════════════════════════════════

class TrabalhoDriveTrain {
  final String id;
  final String turbinaId;
  final String componenteId;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<String> fotosTorque;
  final List<String> fotosTensionamento;
  final String? observacoesTorque;
  final String? observacoesTensionamento;
  final bool torqueNA;
  final bool tensionamentoNA;
  final bool fotosNATorque;
  final bool fotosNATensionamento;
  final bool observacoesNATorque;
  final bool observacoesNATensionamento;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  TrabalhoDriveTrain({
    required this.id,
    required this.turbinaId,
    required this.componenteId,
    this.dataInicio,
    this.dataFim,
    this.fotosTorque = const [],
    this.fotosTensionamento = const [],
    this.observacoesTorque,
    this.observacoesTensionamento,
    this.torqueNA = false,
    this.tensionamentoNA = false,
    this.fotosNATorque = false,
    this.fotosNATensionamento = false,
    this.observacoesNATorque = false,
    this.observacoesNATensionamento = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy,
    this.updatedBy,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progresso {
    int total = 4; // Datas + 2 trabalhos
    int preenchidos = 0;

    if (dataInicio != null) preenchidos++;
    if (dataFim != null) preenchidos++;

    if (torqueNA ||
        (observacoesTorque != null && observacoesTorque!.isNotEmpty)) {
      preenchidos++;
    }
    if (tensionamentoNA ||
        (observacoesTensionamento != null &&
            observacoesTensionamento!.isNotEmpty)) {
      preenchidos++;
    }

    return (preenchidos / total) * 100;
  }

  bool get isValid {
    return dataInicio != null &&
        dataFim != null &&
        !dataFim!.isBefore(dataInicio!);
  }

  factory TrabalhoDriveTrain.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TrabalhoDriveTrain(
      id: doc.id,
      turbinaId: data['turbinaId'] ?? '',
      componenteId: data['componenteId'] ?? '',
      dataInicio: data['dataInicio'] != null
          ? (data['dataInicio'] as Timestamp).toDate()
          : null,
      dataFim: data['dataFim'] != null
          ? (data['dataFim'] as Timestamp).toDate()
          : null,
      fotosTorque: List<String>.from(data['fotosTorque'] ?? []),
      fotosTensionamento: List<String>.from(data['fotosTensionamento'] ?? []),
      observacoesTorque: data['observacoesTorque'],
      observacoesTensionamento: data['observacoesTensionamento'],
      torqueNA: data['torqueNA'] ?? false,
      tensionamentoNA: data['tensionamentoNA'] ?? false,
      fotosNATorque: data['fotosNATorque'] ?? false,
      fotosNATensionamento: data['fotosNATensionamento'] ?? false,
      observacoesNATorque: data['observacoesNATorque'] ?? false,
      observacoesNATensionamento: data['observacoesNATensionamento'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'turbinaId': turbinaId,
      'componenteId': componenteId,
      'dataInicio': dataInicio != null ? Timestamp.fromDate(dataInicio!) : null,
      'dataFim': dataFim != null ? Timestamp.fromDate(dataFim!) : null,
      'fotosTorque': fotosTorque,
      'fotosTensionamento': fotosTensionamento,
      'observacoesTorque': observacoesTorque,
      'observacoesTensionamento': observacoesTensionamento,
      'torqueNA': torqueNA,
      'tensionamentoNA': tensionamentoNA,
      'fotosNATorque': fotosNATorque,
      'fotosNATensionamento': fotosNATensionamento,
      'observacoesNATorque': observacoesNATorque,
      'observacoesNATensionamento': observacoesNATensionamento,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  TrabalhoDriveTrain copyWith({
    String? id,
    String? turbinaId,
    String? componenteId,
    DateTime? dataInicio,
    DateTime? dataFim,
    List<String>? fotosTorque,
    List<String>? fotosTensionamento,
    String? observacoesTorque,
    String? observacoesTensionamento,
    bool? torqueNA,
    bool? tensionamentoNA,
    bool? fotosNATorque,
    bool? fotosNATensionamento,
    bool? observacoesNATorque,
    bool? observacoesNATensionamento,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return TrabalhoDriveTrain(
      id: id ?? this.id,
      turbinaId: turbinaId ?? this.turbinaId,
      componenteId: componenteId ?? this.componenteId,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      fotosTorque: fotosTorque ?? this.fotosTorque,
      fotosTensionamento: fotosTensionamento ?? this.fotosTensionamento,
      observacoesTorque: observacoesTorque ?? this.observacoesTorque,
      observacoesTensionamento:
          observacoesTensionamento ?? this.observacoesTensionamento,
      torqueNA: torqueNA ?? this.torqueNA,
      tensionamentoNA: tensionamentoNA ?? this.tensionamentoNA,
      fotosNATorque: fotosNATorque ?? this.fotosNATorque,
      fotosNATensionamento: fotosNATensionamento ?? this.fotosNATensionamento,
      observacoesNATorque: observacoesNATorque ?? this.observacoesNATorque,
      observacoesNATensionamento:
          observacoesNATensionamento ?? this.observacoesNATensionamento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
