import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/app_colors.dart';
import '../models/torque_tensioning.dart';
import '../services/torque_tensioning_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TORQUE TENSIONING EDIT DIALOG - 6 TABS COMPLETO
// ═══════════════════════════════════════════════════════════════════════════

class TorqueTensioningEditDialog extends ConsumerStatefulWidget {
  final TorqueTensioning conexao;
  final String turbinaId;
  final String projectId;

  const TorqueTensioningEditDialog({
    super.key,
    required this.conexao,
    required this.turbinaId,
    required this.projectId,
  });

  @override
  ConsumerState<TorqueTensioningEditDialog> createState() =>
      _TorqueTensioningEditDialogState();
}

class _TorqueTensioningEditDialogState
    extends ConsumerState<TorqueTensioningEditDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  // ══════════════════════════════════════════════════════════════════════════
  // CONTROLLERS - TODOS OS CAMPOS
  // ══════════════════════════════════════════════════════════════════════════

  // Tab 1: Dados Técnicos
  final _torqueValueController = TextEditingController();
  String _torqueUnit = 'Nm';
  final _tensioningValueController = TextEditingController();
  String _tensioningUnit = 'kN';
  final _boltMetricController = TextEditingController();
  final _boltQuantityController = TextEditingController();
  String _boltType = 'Stud';

  // Tab 2: Rastreabilidade Parafusos
  final _boltBatchController = TextEditingController();
  final _boltVUIController = TextEditingController();
  final _boltSerialController = TextEditingController();
  final _boltItemController = TextEditingController();

  // Tab 3: Equipamento
  final _torqueWrenchIdController = TextEditingController();
  final _torqueWrenchSerialController = TextEditingController();
  DateTime? _torqueWrenchCalibrationDate;
  final _tensioningEquipmentIdController = TextEditingController();
  final _tensioningEquipmentSerialController = TextEditingController();

  // Tab 4: Procedimentos
  final _workInstructionController = TextEditingController();
  final _qualityCheckController = TextEditingController();
  final _inspectorNameController = TextEditingController();
  String? _inspectorSignatureUrl;
  DateTime? _inspectorSignedAt;

  // Tab 5: Condições Ambientais
  final _temperaturaController = TextEditingController();
  final _humidadeController = TextEditingController();
  String _condicoesMeteo = 'Céu limpo';

  // Tab 6: Fotos & Observações
  List<String> _photoUrls = [];
  final _observacoesController = TextEditingController();

  // Datas de Execução
  DateTime? _dataInicio;
  DateTime? _dataFim;

  // ══════════════════════════════════════════════════════════════════════════
  // INIT STATE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  void _loadData() {
    final c = widget.conexao;

    // Tab 1
    if (c.torqueValue != null) {
      _torqueValueController.text = c.torqueValue.toString();
    }
    if (c.torqueUnit != null) _torqueUnit = c.torqueUnit!;
    if (c.tensioningValue != null) {
      _tensioningValueController.text = c.tensioningValue.toString();
    }
    if (c.tensioningUnit != null) _tensioningUnit = c.tensioningUnit!;
    if (c.boltMetric != null) _boltMetricController.text = c.boltMetric!;
    if (c.boltQuantity != null) {
      _boltQuantityController.text = c.boltQuantity.toString();
    }
    if (c.boltType != null) _boltType = c.boltType!;

    // Tab 2
    if (c.boltBatch != null) _boltBatchController.text = c.boltBatch!;
    if (c.boltVUI != null) _boltVUIController.text = c.boltVUI!;
    if (c.boltSerialNumber != null) {
      _boltSerialController.text = c.boltSerialNumber!;
    }
    if (c.boltItemNumber != null) _boltItemController.text = c.boltItemNumber!;

    // Tab 3
    if (c.torqueWrenchId != null) {
      _torqueWrenchIdController.text = c.torqueWrenchId!;
    }
    if (c.torqueWrenchSerial != null) {
      _torqueWrenchSerialController.text = c.torqueWrenchSerial!;
    }
    _torqueWrenchCalibrationDate = c.torqueWrenchCalibrationDate;
    if (c.tensioningEquipmentId != null) {
      _tensioningEquipmentIdController.text = c.tensioningEquipmentId!;
    }
    if (c.tensioningEquipmentSerial != null) {
      _tensioningEquipmentSerialController.text = c.tensioningEquipmentSerial!;
    }

    // Tab 4
    if (c.workInstructionNumber != null) {
      _workInstructionController.text = c.workInstructionNumber!;
    }
    if (c.qualityCheckNumber != null) {
      _qualityCheckController.text = c.qualityCheckNumber!;
    }
    if (c.inspectorName != null) {
      _inspectorNameController.text = c.inspectorName!;
    }
    _inspectorSignatureUrl = c.inspectorSignature;
    _inspectorSignedAt = c.inspectorSignedAt;

    // Tab 5
    if (c.temperatura != null) {
      _temperaturaController.text = c.temperatura.toString();
    }
    if (c.humidade != null) _humidadeController.text = c.humidade.toString();
    if (c.condicoesMeteo != null) _condicoesMeteo = c.condicoesMeteo!;

    // Tab 6
    _photoUrls = List.from(c.photoUrls);
    if (c.observacoes != null) _observacoesController.text = c.observacoes!;

    // Datas
    _dataInicio = c.dataInicio;
    _dataFim = c.dataFim;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _torqueValueController.dispose();
    _tensioningValueController.dispose();
    _boltMetricController.dispose();
    _boltQuantityController.dispose();
    _boltBatchController.dispose();
    _boltVUIController.dispose();
    _boltSerialController.dispose();
    _boltItemController.dispose();
    _torqueWrenchIdController.dispose();
    _torqueWrenchSerialController.dispose();
    _tensioningEquipmentIdController.dispose();
    _tensioningEquipmentSerialController.dispose();
    _workInstructionController.dispose();
    _qualityCheckController.dispose();
    _inspectorNameController.dispose();
    _temperaturaController.dispose();
    _humidadeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTab1DadosTecnicos(),
                    _buildTab2RastreabilidadeParafusos(),
                    _buildTab3Equipamento(),
                    _buildTab4Procedimentos(),
                    _buildTab5CondicoesAmbientais(),
                    _buildTab6FotosObservacoes(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primaryBlue,
      child: Row(
        children: [
          Icon(Icons.handyman, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Torque & Tensionamento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.conexao.componenteOrigem} → ${widget.conexao.componenteDestino}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TABS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTabs() {
    return Container(
      color: AppColors.primaryBlue,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(icon: Icon(Icons.build, size: 20), text: 'Dados'),
          Tab(icon: Icon(Icons.qr_code, size: 20), text: 'Parafusos'),
          Tab(icon: Icon(Icons.construction, size: 20), text: 'Equipamento'),
          Tab(icon: Icon(Icons.description, size: 20), text: 'Procedimentos'),
          Tab(icon: Icon(Icons.cloud, size: 20), text: 'Condições'),
          Tab(icon: Icon(Icons.photo_camera, size: 20), text: 'Fotos'),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: DADOS TÉCNICOS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTab1DadosTecnicos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ════════════════════════════════════════════════════════════════
          // TORQUE
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(Icons.build, 'Torque'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _torqueValueController,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: '1200',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _torqueUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unidade',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Nm', 'kNm', 'ft-lb'].map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (v) => setState(() => _torqueUnit = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ════════════════════════════════════════════════════════════════
          // TENSIONAMENTO
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(Icons.compress, 'Tensionamento'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _tensioningValueController,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: '850',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _tensioningUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unidade',
                    border: OutlineInputBorder(),
                  ),
                  items: ['kN', 'lbf', 'MPa'].map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (v) => setState(() => _tensioningUnit = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ════════════════════════════════════════════════════════════════
          // ESPECIFICAÇÕES PARAFUSOS
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(Icons.hardware, 'Especificações dos Parafusos'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _boltMetricController,
            decoration: const InputDecoration(
              labelText: 'Métrica',
              hintText: 'M36, M42, 2 inch',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _boltQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    hintText: '72',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _boltType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Stud', 'Bolt', 'Hex Bolt', 'Screw'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (v) => setState(() => _boltType = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ════════════════════════════════════════════════════════════════
          // DATAS DE EXECUÇÃO
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(Icons.calendar_today, 'Execução'),
          const SizedBox(height: 12),
          _buildDatePicker(
            label: 'Data Início',
            date: _dataInicio,
            onChanged: (d) => setState(() => _dataInicio = d),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(
            label: 'Data Fim',
            date: _dataFim,
            onChanged: (d) => setState(() => _dataFim = d),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: RASTREABILIDADE PARAFUSOS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTab2RastreabilidadeParafusos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.qr_code_2, 'Rastreabilidade dos Parafusos'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _boltBatchController,
            decoration: const InputDecoration(
              labelText: 'Batch / Lote',
              hintText: 'BATCH-2024-A-001',
              border: OutlineInputBorder(),
              helperText: 'Lote de fabricação dos parafusos',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _boltVUIController,
            decoration: const InputDecoration(
              labelText: 'VUI',
              hintText: 'VUI-M36-12345',
              border: OutlineInputBorder(),
              helperText: 'Código VUI dos parafusos',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _boltSerialController,
            decoration: const InputDecoration(
              labelText: 'Serial Number',
              hintText: 'SN-BOLT-98765-2024',
              border: OutlineInputBorder(),
              helperText: 'Número de série dos parafusos',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _boltItemController,
            decoration: const InputDecoration(
              labelText: 'Item Number / Part Number',
              hintText: 'PN-M36X120-HEX-STUD',
              border: OutlineInputBorder(),
              helperText: 'Número de peça dos parafusos',
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: EQUIPAMENTO
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTab3Equipamento() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ════════════════════════════════════════════════════════════════
          // CHAVE DE TORQUE
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(Icons.build_circle, 'Chave de Torque'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _torqueWrenchIdController,
            decoration: const InputDecoration(
              labelText: 'ID do Equipamento',
              hintText: 'TORQUE-WRENCH-005',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _torqueWrenchSerialController,
            decoration: const InputDecoration(
              labelText: 'Número de Série',
              hintText: 'SN-TW-2023-0456',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(
            label: 'Data de Calibração',
            date: _torqueWrenchCalibrationDate,
            onChanged: (d) => setState(() => _torqueWrenchCalibrationDate = d),
            helperText: 'Data da última calibração',
          ),

          const SizedBox(height: 24),

          // ════════════════════════════════════════════════════════════════
          // EQUIPAMENTO TENSIONAMENTO
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(Icons.compress, 'Equipamento de Tensionamento'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tensioningEquipmentIdController,
            decoration: const InputDecoration(
              labelText: 'ID do Equipamento',
              hintText: 'TENSIONER-HYDR-012',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tensioningEquipmentSerialController,
            decoration: const InputDecoration(
              labelText: 'Número de Série',
              hintText: 'SN-TENS-2024-0789',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 4: PROCEDIMENTOS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTab4Procedimentos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.description, 'Procedimentos & Qualidade'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _workInstructionController,
            decoration: const InputDecoration(
              labelText: 'Work Instruction Number',
              hintText: 'WI-TOWER-BOLTING-001-Rev3',
              border: OutlineInputBorder(),
              helperText: 'Número da instrução de trabalho',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qualityCheckController,
            decoration: const InputDecoration(
              labelText: 'Quality Check / ITP Number',
              hintText: 'QC-WTG01-TOWER-20260124-001',
              border: OutlineInputBorder(),
              helperText: 'Número do controlo de qualidade',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _inspectorNameController,
            decoration: const InputDecoration(
              labelText: 'Nome do Inspetor',
              hintText: 'João Silva - Cert. QC-Level-2',
              border: OutlineInputBorder(),
              helperText: 'Nome e certificação do inspetor',
            ),
          ),
          const SizedBox(height: 16),

          // Assinatura Digital (placeholder - implementação futura)
          if (_inspectorSignatureUrl != null) ...[
            Text('Assinado em: ${_formatDateTime(_inspectorSignedAt!)}'),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar assinatura digital
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Assinatura digital em desenvolvimento'),
                ),
              );
            },
            icon: const Icon(Icons.draw),
            label: Text(_inspectorSignatureUrl == null
                ? 'Assinar Digitalmente'
                : 'Ver Assinatura'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 5: CONDIÇÕES AMBIENTAIS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTab5CondicoesAmbientais() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.wb_sunny, 'Condições Ambientais'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _temperaturaController,
            decoration: const InputDecoration(
              labelText: 'Temperatura (°C)',
              hintText: '18.5',
              border: OutlineInputBorder(),
              suffixText: '°C',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _humidadeController,
            decoration: const InputDecoration(
              labelText: 'Humidade Relativa (%)',
              hintText: '65',
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _condicoesMeteo,
            decoration: const InputDecoration(
              labelText: 'Condições Meteorológicas',
              border: OutlineInputBorder(),
            ),
            items: [
              'Céu limpo',
              'Sol',
              'Nublado',
              'Chuva leve',
              'Chuva forte',
              'Vento forte',
              'Neve',
            ].map((cond) {
              return DropdownMenuItem(value: cond, child: Text(cond));
            }).toList(),
            onChanged: (v) => setState(() => _condicoesMeteo = v!),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 6: FOTOS & OBSERVAÇÕES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTab6FotosObservacoes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ════════════════════════════════════════════════════════════════
          // FOTOS
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(
              Icons.photo_library, 'Fotos (${_photoUrls.length}/10)'),
          const SizedBox(height: 12),

          if (_photoUrls.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _photoUrls.map((url) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.lightGray,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _handleDeletePhoto(url),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          if (_photoUrls.length < 10) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingPhoto
                        ? null
                        : () => _handleAddPhoto(ImageSource.gallery),
                    icon: _isUploadingPhoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingPhoto
                        ? null
                        : () => _handleAddPhoto(ImageSource.camera),
                    icon: _isUploadingPhoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
                    label: const Text('Câmara'),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // ════════════════════════════════════════════════════════════════
          // OBSERVAÇÕES
          // ════════════════════════════════════════════════════════════════
          _buildSectionHeader(Icons.notes, 'Observações'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _observacoesController,
            decoration: const InputDecoration(
              labelText: 'Notas Técnicas',
              hintText: 'Torque aplicado em 3 passes conforme WI-001...',
              border: OutlineInputBorder(),
              helperText: 'Detalhes sobre a execução',
            ),
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FOOTER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Progresso: ${widget.conexao.progresso}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'A guardar...' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS - UI COMPONENTS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime) onChanged,
    String? helperText,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: helperText,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date != null ? _formatDate(date) : 'Selecionar data'),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilizador não autenticado');

      final service = TorqueTensioningService();

      final updated = widget.conexao.copyWith(
        // Tab 1
        torqueValue: _torqueValueController.text.isEmpty
            ? null
            : double.tryParse(_torqueValueController.text),
        torqueUnit: _torqueValueController.text.isEmpty ? null : _torqueUnit,
        tensioningValue: _tensioningValueController.text.isEmpty
            ? null
            : double.tryParse(_tensioningValueController.text),
        tensioningUnit:
            _tensioningValueController.text.isEmpty ? null : _tensioningUnit,
        boltMetric: _boltMetricController.text.isEmpty
            ? null
            : _boltMetricController.text,
        boltQuantity: _boltQuantityController.text.isEmpty
            ? null
            : int.tryParse(_boltQuantityController.text),
        boltType: _boltMetricController.text.isEmpty ? null : _boltType,
        dataInicio: _dataInicio,
        dataFim: _dataFim,

        // Tab 2
        boltBatch: _boltBatchController.text.isEmpty
            ? null
            : _boltBatchController.text,
        boltVUI:
            _boltVUIController.text.isEmpty ? null : _boltVUIController.text,
        boltSerialNumber: _boltSerialController.text.isEmpty
            ? null
            : _boltSerialController.text,
        boltItemNumber:
            _boltItemController.text.isEmpty ? null : _boltItemController.text,

        // Tab 3
        torqueWrenchId: _torqueWrenchIdController.text.isEmpty
            ? null
            : _torqueWrenchIdController.text,
        torqueWrenchSerial: _torqueWrenchSerialController.text.isEmpty
            ? null
            : _torqueWrenchSerialController.text,
        torqueWrenchCalibrationDate: _torqueWrenchCalibrationDate,
        tensioningEquipmentId: _tensioningEquipmentIdController.text.isEmpty
            ? null
            : _tensioningEquipmentIdController.text,
        tensioningEquipmentSerial:
            _tensioningEquipmentSerialController.text.isEmpty
                ? null
                : _tensioningEquipmentSerialController.text,

        // Tab 4
        workInstructionNumber: _workInstructionController.text.isEmpty
            ? null
            : _workInstructionController.text,
        qualityCheckNumber: _qualityCheckController.text.isEmpty
            ? null
            : _qualityCheckController.text,
        inspectorName: _inspectorNameController.text.isEmpty
            ? null
            : _inspectorNameController.text,
        inspectorSignature: _inspectorSignatureUrl,
        inspectorSignedAt: _inspectorSignedAt,

        // Tab 5
        temperatura: _temperaturaController.text.isEmpty
            ? null
            : double.tryParse(_temperaturaController.text),
        humidade: _humidadeController.text.isEmpty
            ? null
            : double.tryParse(_humidadeController.text),
        condicoesMeteo: _condicoesMeteo,

        // Tab 6
        photoUrls: _photoUrls,
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,

        // Metadata
        updatedAt: DateTime.now(),
        updatedBy: user.uid,
      );

      await service.updateConexao(widget.conexao.id, updated);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexão atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleAddPhoto(ImageSource source) async {
    setState(() => _isUploadingPhoto = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      final file = File(pickedFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final photoIndex = _photoUrls.length + 1;
      final fileName = '${timestamp}_$photoIndex.jpg';

      final storageRef = FirebaseStorage.instance.ref().child(
            'projects/${widget.projectId}/turbinas/${widget.turbinaId}/torque/${widget.conexao.id}/$fileName',
          );

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        _photoUrls.add(downloadUrl);
        _isUploadingPhoto = false;
      });

      // Guardar imediatamente
      final service = TorqueTensioningService();
      await service.adicionarFoto(widget.conexao.id, downloadUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _handleDeletePhoto(String photoUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Foto'),
        content: const Text('Tem a certeza que deseja deletar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _photoUrls.remove(photoUrl));

      final service = TorqueTensioningService(); // ← ASSIM
      await service.removerFoto(widget.conexao.id, photoUrl);

      // Deletar do Storage
      final ref = FirebaseStorage.instance.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORMAT HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
