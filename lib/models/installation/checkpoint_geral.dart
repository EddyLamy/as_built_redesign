import 'package:cloud_firestore/cloud_firestore.dart';
import 'tipo_fase.dart';

// ═══════════════════════════════════════════════════════
// CHECKPOINT GERAL
// ═══════════════════════════════════════════════════════

class CheckpointGeral {
  final String id;
  final String turbinaId;
  final TipoFase tipo;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<String> fotos;
  final String? observacoes;
  final bool fotosNA;
  final bool observacoesNA;
  final bool isNA;
  final String? motivoNA;
  final String? motivoNAKey;
  final String? componenteAssociadoId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  CheckpointGeral({
    required this.id,
    required this.turbinaId,
    required this.tipo,
    this.dataInicio,
    this.dataFim,
    this.fotos = const [],
    this.observacoes,
    this.fotosNA = false,
    this.observacoesNA = false,
    this.isNA = false,
    this.motivoNA,
    this.motivoNAKey,
    this.componenteAssociadoId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy,
    this.updatedBy,
  })  : assert(tipo.isCheckpoint, 'Tipo deve ser um checkpoint'),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progresso {
    if (isNA) return 100.0;
    int total = 2;
    int preenchidos = 0;
    if (dataInicio != null) preenchidos++;
    if (dataFim != null) preenchidos++;
    if (!fotosNA) {
      total += 1;
      if (fotos.isNotEmpty) preenchidos++;
    }
    if (!observacoesNA) {
      total += 1;
      if (observacoes != null && observacoes!.isNotEmpty) preenchidos++;
    }
    return total > 0 ? (preenchidos / total) * 100 : 0;
  }

  String getStatus(String locale) {
    if (isNA) return 'N/A';
    final prog = progresso;
    if (prog == 0) return locale == 'pt' ? 'Pendente' : 'Pending';
    if (prog == 100) return locale == 'pt' ? 'Completo' : 'Complete';
    return locale == 'pt' ? 'Em Curso' : 'In Progress';
  }

  String get status => getStatus('pt');

  bool get isValid {
    if (isNA) return motivoNA != null && motivoNA!.isNotEmpty;
    if (dataInicio == null || dataFim == null) return false;
    if (dataFim!.isBefore(dataInicio!)) return false;
    return true;
  }

  String getNome(String locale) => tipo.getName(locale);
  String get nome => getNome('pt');

  factory CheckpointGeral.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckpointGeral(
      id: doc.id,
      turbinaId: data['turbinaId'] ?? '',
      tipo: TipoFaseExtension.fromString(data['tipo'] ?? 'eletricos'),
      dataInicio: data['dataInicio'] != null
          ? (data['dataInicio'] as Timestamp).toDate()
          : null,
      dataFim: data['dataFim'] != null
          ? (data['dataFim'] as Timestamp).toDate()
          : null,
      fotos: List<String>.from(data['fotos'] ?? []),
      observacoes: data['observacoes'],
      fotosNA: data['fotosNA'] ?? false,
      observacoesNA: data['observacoesNA'] ?? false,
      isNA: data['isNA'] ?? false,
      motivoNA: data['motivoNA'],
      motivoNAKey: data['motivoNAKey'],
      componenteAssociadoId: data['componenteAssociadoId'],
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
      'tipo': tipo.toString().split('.').last,
      'dataInicio': dataInicio != null ? Timestamp.fromDate(dataInicio!) : null,
      'dataFim': dataFim != null ? Timestamp.fromDate(dataFim!) : null,
      'fotos': fotos,
      'observacoes': observacoes,
      'fotosNA': fotosNA,
      'observacoesNA': observacoesNA,
      'isNA': isNA,
      'motivoNA': motivoNA,
      'motivoNAKey': motivoNAKey,
      'componenteAssociadoId': componenteAssociadoId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  CheckpointGeral copyWith({
    String? id,
    String? turbinaId,
    TipoFase? tipo,
    DateTime? dataInicio,
    DateTime? dataFim,
    List<String>? fotos,
    String? observacoes,
    bool? fotosNA,
    bool? observacoesNA,
    bool? isNA,
    String? motivoNA,
    String? motivoNAKey,
    String? componenteAssociadoId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return CheckpointGeral(
      id: id ?? this.id,
      turbinaId: turbinaId ?? this.turbinaId,
      tipo: tipo ?? this.tipo,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      fotos: fotos ?? this.fotos,
      observacoes: observacoes ?? this.observacoes,
      fotosNA: fotosNA ?? this.fotosNA,
      observacoesNA: observacoesNA ?? this.observacoesNA,
      isNA: isNA ?? this.isNA,
      motivoNA: motivoNA ?? this.motivoNA,
      motivoNAKey: motivoNAKey ?? this.motivoNAKey,
      componenteAssociadoId:
          componenteAssociadoId ?? this.componenteAssociadoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
