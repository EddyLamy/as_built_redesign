import 'package:cloud_firestore/cloud_firestore.dart';
import 'tipo_fase.dart';
import '../../i18n/installation_translations.dart';

// ═══════════════════════════════════════════════════════
// TRABALHO MECÂNICO (LIGAÇÃO ENTRE COMPONENTES)
// ═══════════════════════════════════════════════════════

class TrabalhoLigacao {
  final String id;
  final String turbinaId;

  // ────── LIGAÇÃO ──────
  final String componenteA; // "Fundação", "Bottom", etc.
  final String componenteB; // "Bottom", "Middle 1", etc.
  final String nomeLigacao; // "Fundação/Bottom"

  // ────── TIPO (mutuamente exclusivo) ──────
  final TipoTrabalhoMecanico? tipo; // torque OU tensionamento

  // ────── DADOS ──────
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<String> fotos;
  final String? observacoes;
  final bool fotosNA;
  final bool observacoesNA;

  // ────── N/A ──────
  final bool isNA;
  final String? motivoNA; // Texto original
  final String? motivoNAKey; // Chave para tradução

  // ────── METADATA ──────
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  TrabalhoLigacao({
    required this.id,
    required this.turbinaId,
    required this.componenteA,
    required this.componenteB,
    required this.nomeLigacao,
    this.tipo,
    this.dataInicio,
    this.dataFim,
    this.fotos = const [],
    this.observacoes,
    this.fotosNA = false,
    this.observacoesNA = false,
    this.isNA = false,
    this.motivoNA,
    this.motivoNAKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy,
    this.updatedBy,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ────── PROGRESSO AUTOMÁTICO ──────
  double get progresso {
    if (isNA) return 100.0;

    int total = 3; // Tipo + Datas
    int preenchidos = 0;

    if (tipo != null) preenchidos++;
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

  // ────── STATUS ──────
  String getStatus(String locale) {
    if (isNA) return InstallationTranslations.getString('na', locale);
    final prog = progresso;
    if (prog == 0) return InstallationTranslations.getString('pending', locale);
    if (prog == 100) {
      return InstallationTranslations.getString('complete', locale);
    }
    return InstallationTranslations.getString('inProgress', locale);
  }

  String get status => getStatus('pt');

  // ────── VALIDAÇÕES ──────
  bool get isValid {
    if (isNA) return motivoNA != null && motivoNA!.isNotEmpty;

    // Tipo obrigatório
    if (tipo == null) return false;

    // Datas obrigatórias
    if (dataInicio == null || dataFim == null) return false;

    // Data fim não pode ser antes de data início
    if (dataFim!.isBefore(dataInicio!)) return false;

    return true;
  }

  // ────── CONVERSÃO FIRESTORE ──────
  factory TrabalhoLigacao.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TrabalhoLigacao(
      id: doc.id,
      turbinaId: data['turbinaId'] ?? '',
      componenteA: data['componenteA'] ?? '',
      componenteB: data['componenteB'] ?? '',
      nomeLigacao: data['nomeLigacao'] ?? '',
      tipo: data['tipo'] != null
          ? TipoTrabalhoMecanicoExtension.fromString(data['tipo'])
          : null,
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
      'componenteA': componenteA,
      'componenteB': componenteB,
      'nomeLigacao': nomeLigacao,
      'tipo': tipo?.toString().split('.').last,
      'dataInicio': dataInicio != null ? Timestamp.fromDate(dataInicio!) : null,
      'dataFim': dataFim != null ? Timestamp.fromDate(dataFim!) : null,
      'fotos': fotos,
      'observacoes': observacoes,
      'fotosNA': fotosNA,
      'observacoesNA': observacoesNA,
      'isNA': isNA,
      'motivoNA': motivoNA,
      'motivoNAKey': motivoNAKey,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  // ────── COPY WITH ──────
  TrabalhoLigacao copyWith({
    String? id,
    String? turbinaId,
    String? componenteA,
    String? componenteB,
    String? nomeLigacao,
    TipoTrabalhoMecanico? tipo,
    DateTime? dataInicio,
    DateTime? dataFim,
    List<String>? fotos,
    String? observacoes,
    bool? fotosNA,
    bool? observacoesNA,
    bool? isNA,
    String? motivoNA,
    String? motivoNAKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return TrabalhoLigacao(
      id: id ?? this.id,
      turbinaId: turbinaId ?? this.turbinaId,
      componenteA: componenteA ?? this.componenteA,
      componenteB: componenteB ?? this.componenteB,
      nomeLigacao: nomeLigacao ?? this.nomeLigacao,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
