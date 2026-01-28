import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tipo_fase.dart';

// ═══════════════════════════════════════════════════════
// FASE DE COMPONENTE
// ═══════════════════════════════════════════════════════

class FaseComponente {
  final String id;
  final String turbinaId;
  final String componenteId;
  final TipoFase tipo;

  // ────── DATAS (TODAS as fases têm) ──────
  final DateTime? dataInicio;
  final DateTime? dataFim;

  // ────── HORAS (depende do tipo) ──────
  final TimeOfDay? horaRecepcao; // Receção: hora única
  final TimeOfDay? horaInicio; // Instalação/Pré-Instalação
  final TimeOfDay? horaFim; // Instalação/Pré-Instalação

  // ────── TRACEABILIDADE ──────
  final String? vui;
  final String? serialNumber;
  final String? itemNumber;
  final String? posicao; // APENAS Blades na Instalação (A/B/C)

  // ────── OPCIONAL ──────
  final List<String> fotos;
  final String? observacoes;
  final bool fotosNA;
  final bool observacoesNA;

  // ────── N/A ──────
  final bool isFaseNA;
  final String? motivoNA; // Texto original do user
  final String? motivoNAKey; // Chave para tradução (ex: 'preMounted')

  // ────── METADATA ──────
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  FaseComponente({
    required this.id,
    required this.turbinaId,
    required this.componenteId,
    required this.tipo,
    this.dataInicio,
    this.dataFim,
    this.horaRecepcao,
    this.horaInicio,
    this.horaFim,
    this.vui,
    this.serialNumber,
    this.itemNumber,
    this.posicao,
    this.fotos = const [],
    this.observacoes,
    this.fotosNA = false,
    this.observacoesNA = false,
    this.isFaseNA = false,
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
    if (isFaseNA) return 100.0;

    int total = 2; // Datas sempre obrigatórias
    int preenchidos = 0;

    // Datas
    if (dataInicio != null) preenchidos++;
    if (dataFim != null) preenchidos++;

    // Horas (se aplicável)
    if (tipo.requerHoras) {
      if (tipo == TipoFase.recepcao) {
        total += 1;
        if (horaRecepcao != null) preenchidos++;
      } else {
        // Instalação ou Pré-Instalação
        total += 2;
        if (horaInicio != null) preenchidos++;
        if (horaFim != null) preenchidos++;
      }
    }

    // Traceabilidade (Receção + Instalação)
    if (tipo.requerTraceabilidade) {
      total += 3;
      if (vui != null && vui!.isNotEmpty) preenchidos++;
      if (serialNumber != null && serialNumber!.isNotEmpty) preenchidos++;
      if (itemNumber != null && itemNumber!.isNotEmpty) preenchidos++;
    }

    // Posição (validado externamente se é Blade)
    if (posicao != null && posicao!.isNotEmpty) {
      total += 1;
      preenchidos++;
    }

    // Fotos (se não N/A)
    if (!fotosNA) {
      total += 1;
      if (fotos.isNotEmpty) preenchidos++;
    }

    // Observações (se não N/A)
    if (!observacoesNA) {
      total += 1;
      if (observacoes != null && observacoes!.isNotEmpty) preenchidos++;
    }

    return total > 0 ? (preenchidos / total) * 100 : 0;
  }

  // ────── STATUS ──────
  String getStatus(String locale) {
    // Import será adicionado: import 'installation_translations.dart';
    if (isFaseNA) return 'N/A'; // InstallationTranslations.get('na', locale)
    final prog = progresso;
    if (prog == 0) return locale == 'pt' ? 'Pendente' : 'Pending';
    if (prog == 100) return locale == 'pt' ? 'Completo' : 'Complete';
    return locale == 'pt' ? 'Em Curso' : 'In Progress';
  }

  String get status => getStatus('pt');

  // ────── VALIDAÇÕES ──────
  bool get isValid {
    if (isFaseNA) return motivoNA != null && motivoNA!.isNotEmpty;

    // Datas obrigatórias
    if (dataInicio == null || dataFim == null) return false;

    // Data fim não pode ser antes de data início
    if (dataFim!.isBefore(dataInicio!)) return false;

    return true;
  }

  // ────── CONVERSÃO FIRESTORE ──────
  factory FaseComponente.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FaseComponente(
      id: doc.id,
      turbinaId: data['turbinaId'] ?? '',
      componenteId: data['componenteId'] ?? '',
      tipo: TipoFaseExtension.fromString(data['tipo'] ?? 'recepcao'),
      dataInicio: data['dataInicio'] != null
          ? (data['dataInicio'] as Timestamp).toDate()
          : null,
      dataFim: data['dataFim'] != null
          ? (data['dataFim'] as Timestamp).toDate()
          : null,
      horaRecepcao: data['horaRecepcao'] != null
          ? _timeFromString(data['horaRecepcao'])
          : null,
      horaInicio: data['horaInicio'] != null
          ? _timeFromString(data['horaInicio'])
          : null,
      horaFim:
          data['horaFim'] != null ? _timeFromString(data['horaFim']) : null,
      vui: data['vui'],
      serialNumber: data['serialNumber'],
      itemNumber: data['itemNumber'],
      posicao: data['posicao'],
      fotos: List<String>.from(data['fotos'] ?? []),
      observacoes: data['observacoes'],
      fotosNA: data['fotosNA'] ?? false,
      observacoesNA: data['observacoesNA'] ?? false,
      isFaseNA: data['isFaseNA'] ?? false,
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
      'componenteId': componenteId,
      'tipo': tipo.toString().split('.').last,
      'dataInicio': dataInicio != null ? Timestamp.fromDate(dataInicio!) : null,
      'dataFim': dataFim != null ? Timestamp.fromDate(dataFim!) : null,
      'horaRecepcao':
          horaRecepcao != null ? _timeToString(horaRecepcao!) : null,
      'horaInicio': horaInicio != null ? _timeToString(horaInicio!) : null,
      'horaFim': horaFim != null ? _timeToString(horaFim!) : null,
      'vui': vui,
      'serialNumber': serialNumber,
      'itemNumber': itemNumber,
      'posicao': posicao,
      'fotos': fotos,
      'observacoes': observacoes,
      'fotosNA': fotosNA,
      'observacoesNA': observacoesNA,
      'isFaseNA': isFaseNA,
      'motivoNA': motivoNA,
      'motivoNAKey': motivoNAKey,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  // ────── HELPERS ──────
  static TimeOfDay _timeFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // ────── COPY WITH ──────
  FaseComponente copyWith({
    String? id,
    String? turbinaId,
    String? componenteId,
    TipoFase? tipo,
    DateTime? dataInicio,
    DateTime? dataFim,
    TimeOfDay? horaRecepcao,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFim,
    String? vui,
    String? serialNumber,
    String? itemNumber,
    String? posicao,
    List<String>? fotos,
    String? observacoes,
    bool? fotosNA,
    bool? observacoesNA,
    bool? isFaseNA,
    String? motivoNA,
    String? motivoNAKey,
    double? progresso,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return FaseComponente(
      id: id ?? this.id,
      turbinaId: turbinaId ?? this.turbinaId,
      componenteId: componenteId ?? this.componenteId,
      tipo: tipo ?? this.tipo,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      horaRecepcao: horaRecepcao ?? this.horaRecepcao,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      vui: vui ?? this.vui,
      serialNumber: serialNumber ?? this.serialNumber,
      itemNumber: itemNumber ?? this.itemNumber,
      posicao: posicao ?? this.posicao,
      fotos: fotos ?? this.fotos,
      observacoes: observacoes ?? this.observacoes,
      fotosNA: fotosNA ?? this.fotosNA,
      observacoesNA: observacoesNA ?? this.observacoesNA,
      isFaseNA: isFaseNA ?? this.isFaseNA,
      motivoNA: motivoNA ?? this.motivoNA,
      motivoNAKey: motivoNAKey ?? this.motivoNAKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
