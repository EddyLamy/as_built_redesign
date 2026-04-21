import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/fase_componente.dart';
import '../../models/installation/tipo_fase.dart';
import '../../services/installation/fase_componente_service.dart';
import '../../providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/component_mapping.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' show Platform;
// ════════════════════════════════════════════════════════════════════════════
// 🆕 IMPORTS DO OCR
// ════════════════════════════════════════════════════════════════════════════
import 'package:as_built/services/ocr_factory.dart';
import 'package:as_built/services/ocr_service.dart';

class FaseEditDialog extends ConsumerStatefulWidget {
  final FaseComponente fase;
  final String turbinaId;

  const FaseEditDialog({
    super.key,
    required this.fase,
    required this.turbinaId,
  });

  @override
  ConsumerState<FaseEditDialog> createState() => _FaseEditDialogState();
}

class _FaseEditDialogState extends ConsumerState<FaseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = FaseComponenteService();

  // ════════════════════════════════════════════════════════════════════════════
  // 🆕 OCR SERVICE
  // ════════════════════════════════════════════════════════════════════════════
  late OCRService _ocrService;
  bool _isProcessingOCR = false;
  final ImagePicker _imagePicker = ImagePicker();

  late DateTime? _dataInicio;
  late DateTime? _dataFim;
  TimeOfDay? _horaRecepcao;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  final _vuiController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _itemNumberController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _posicao;
  List<String> _fotos = [];
  bool _isFaseNA = false;
  String? _motivoNA;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    debugPrint('\n🔵 FASE EDIT DIALOG - INIT');
    debugPrint('   Fase ID: ${widget.fase.id}');
    debugPrint('   Turbina ID: ${widget.turbinaId}');
    debugPrint('   Componente ID: ${widget.fase.componenteId}');
    debugPrint('   Tipo: ${widget.fase.tipo}');

    _dataInicio = widget.fase.dataInicio;
    _dataFim = widget.fase.dataFim;
    _horaRecepcao = widget.fase.horaRecepcao;
    _horaInicio = widget.fase.horaInicio;
    _horaFim = widget.fase.horaFim;
    _vuiController.text = widget.fase.vui ?? '';
    _serialNumberController.text = widget.fase.serialNumber ?? '';
    _itemNumberController.text = widget.fase.itemNumber ?? '';
    _observacoesController.text = widget.fase.observacoes ?? '';
    _posicao = widget.fase.posicao;
    _fotos = List.from(widget.fase.fotos);
    _isFaseNA = widget.fase.isFaseNA;
    _motivoNA = widget.fase.motivoNA;

    // ════════════════════════════════════════════════════════════════════════
    // 🆕 INICIALIZAR OCR
    // ════════════════════════════════════════════════════════════════════════
    _ocrService = OCRFactory.criarServicoOCR();
    _ocrService.inicializar();
  }

  @override
  void dispose() {
    _vuiController.dispose();
    _serialNumberController.dispose();
    _itemNumberController.dispose();
    _observacoesController.dispose();

    // ════════════════════════════════════════════════════════════════════════
    // 🆕 LIMPAR OCR
    // ════════════════════════════════════════════════════════════════════════
    _ocrService.dispose();

    super.dispose();
  }

  // ✅ MÉTODO AUXILIAR PARA OBTER TRADUÇÃO SEGURA
  String _t(Map<String, String>? translations, String key, String fallback) {
    if (translations == null) return fallback;
    return translations[key] ?? fallback;
  }

  String _buildComponentDisplayName(Map<String, String> translations) {
    final fullId = widget.fase.componenteId;
    final hardcodedId = ComponentMapping.extractHardcodedId(fullId);
    final translated = _t(translations, hardcodedId, '');

    if (translated.isNotEmpty && translated != hardcodedId) {
      return translated;
    }

    final mappedName = ComponentMapping.getComponentName(fullId);
    if (mappedName != null && mappedName.isNotEmpty) {
      return mappedName;
    }

    return hardcodedId.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogRadius = BorderRadius.circular(28);
    final dialogBackground =
        theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final footerBackground = isDark
        ? AppColors.glassSurfaceStrongDark
        : AppColors.glassSurfaceStrongLight;
    final outlineColor = theme.colorScheme.outline;

    // ✅ OBTER LOCALE COM FALLBACK COMPLETO
    final String safeLocale = ref.watch(localeStringProvider);

    // ✅ OBTER TRADUÇÕES CORRETAS (estrutura aninhada convertida para plana)
    final Map<String, String> t = <String, String>{};
    InstallationTranslations.translations.forEach((key, value) {
      t[key] = value[safeLocale] ?? value['pt'] ?? key;
    });

    // ✅ OBTER NOME DO TIPO COM TRY-CATCH
    String tipoNome = 'Fase';
    try {
      tipoNome = widget.fase.tipo.getName(safeLocale);
    } catch (e) {
      debugPrint('⚠️ Erro ao obter nome do tipo: $e');
      switch (widget.fase.tipo) {
        case TipoFase.recepcao:
          tipoNome = _t(t, 'reception', 'Receção');
          break;
        case TipoFase.preparacao:
          tipoNome = _t(t, 'preparation', 'Preparação');
          break;
        case TipoFase.preInstalacao:
          tipoNome = _t(t, 'preInstallation', 'Pré-Instalação');
          break;
        case TipoFase.instalacao:
          tipoNome = _t(t, 'installation', 'Instalação');
          break;
        default:
          tipoNome = 'Fase';
      }
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: dialogBackground,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: dialogRadius,
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = MediaQuery.of(context).size.height;
          final maxDialogHeight =
              screenHeight - 48; // 24 padding top + 24 bottom

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: maxDialogHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: dialogRadius.topLeft,
                      topRight: dialogRadius.topRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tipoNome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _buildComponentDisplayName(t),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          debugPrint('🔴 Dialog CANCELADO');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ════════════════════════════════════════════════════════
                          // 🆕 INDICADOR DE OCR PROCESSANDO
                          // ════════════════════════════════════════════════════════
                          if (_isProcessingOCR)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.warningOrange
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.warningOrange
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.warningOrange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '🔍 Extraindo texto da foto...',
                                          style: const TextStyle(
                                            color: AppColors.warningOrange,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Identificando VUI, Serial e Item',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.mediumGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Botão N/A
                          _buildNAButton(t),

                          if (!_isFaseNA) ...[
                            const SizedBox(height: 16),
                            _buildDataFields(t),
                            const SizedBox(height: 16),
                            ..._buildTipoSpecificFields(t),
                            const SizedBox(height: 16),
                            _buildFotosSection(t),
                            const SizedBox(height: 16),
                            _buildObservacoesField(t),
                          ] else ...[
                            const SizedBox(height: 16),
                            _buildMotivoNAField(t),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: footerBackground,
                    borderRadius: BorderRadius.only(
                      bottomLeft: dialogRadius.bottomLeft,
                      bottomRight: dialogRadius.bottomRight,
                    ),
                    border: Border(
                      top: BorderSide(color: outlineColor),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progresso
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${_t(t, 'progresso', 'Progresso')}: ${_calcularProgresso()}%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // Botões
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Botão Limpar Campos
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _limparCampos,
                              icon: const Icon(Icons.clear_all,
                                  size: 18, color: AppColors.warningOrange),
                              label: const Text(
                                'Limpar',
                                style: TextStyle(
                                    color: AppColors.warningOrange,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                          // Botão Cancelar
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                debugPrint('🔴 Botão CANCELAR clicado');
                                Navigator.pop(context);
                              },
                              child: Text(
                                _t(t, 'cancelar', 'Cancelar'),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          // Botão Guardar
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _guardar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _t(t, 'guardar', 'Guardar'),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNAButton(Map<String, String> t) {
    return SwitchListTile(
      value: _isFaseNA,
      onChanged: (value) {
        debugPrint('🔵 N/A alterado para: $value');
        setState(() {
          _isFaseNA = value;
        });
      },
      title: Text(
        _t(t, 'naoAplicavel', 'Não Aplicável (N/A)'),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: _isFaseNA
          ? Text(_t(t, 'faseNaoAplicavel', 'Esta fase não é aplicável'))
          : null,
      activeThumbColor: Colors.orange,
    );
  }

  Widget _buildDataFields(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.orange),
          title: Text(_t(t, 'dataInicio', 'Data Início')),
          subtitle: Text(_formatDate(_dataInicio)),
          trailing: const Icon(Icons.edit, size: 20),
          onTap: () async {
            final data = await showDatePicker(
              context: context,
              initialDate: _dataInicio ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (data != null) {
              setState(() {
                _dataInicio = data;
                if (_dataFim != null && _dataFim!.isBefore(_dataInicio!)) {
                  _dataFim = _dataInicio;
                }
              });
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.event, color: Colors.orange),
          title: Text(_t(t, 'dataFim', 'Data Fim')),
          subtitle: Text(_formatDate(_dataFim)),
          trailing: const Icon(Icons.edit, size: 20),
          onTap: () async {
            final data = await showDatePicker(
              context: context,
              initialDate: _dataFim ?? DateTime.now(),
              firstDate: _dataInicio ?? DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (data != null) {
              setState(() {
                _dataFim = data;
              });
            }
          },
        ),
        if (widget.fase.tipo == TipoFase.recepcao)
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.orange),
            title: Text(_t(t, 'hora', 'Hora')),
            subtitle: Text(_horaRecepcao != null
                ? _horaRecepcao!.format(context)
                : '--:--'),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: () async {
              final hora = await showTimePicker(
                context: context,
                initialTime: _horaRecepcao ?? TimeOfDay.now(),
              );
              if (hora != null) {
                setState(() {
                  _horaRecepcao = hora;
                });
              }
            },
          ),
        if (widget.fase.tipo == TipoFase.instalacao) ...[
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.orange),
            title: Text(_t(t, 'horaInicio', 'Hora Início')),
            subtitle: Text(
                _horaInicio != null ? _horaInicio!.format(context) : '--:--'),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: () async {
              final hora = await showTimePicker(
                context: context,
                initialTime: _horaInicio ?? TimeOfDay.now(),
              );
              if (hora != null) {
                setState(() {
                  _horaInicio = hora;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.orange),
            title: Text(_t(t, 'horaFim', 'Hora Fim')),
            subtitle:
                Text(_horaFim != null ? _horaFim!.format(context) : '--:--'),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: () async {
              final hora = await showTimePicker(
                context: context,
                initialTime: _horaFim ?? TimeOfDay.now(),
              );
              if (hora != null) {
                setState(() {
                  _horaFim = hora;
                });
              }
            },
          ),
        ],
      ],
    );
  }

  List<Widget> _buildTipoSpecificFields(Map<String, String> t) {
    switch (widget.fase.tipo) {
      case TipoFase.recepcao:
        return [
          TextFormField(
            controller: _vuiController,
            decoration: const InputDecoration(
              labelText: 'VUI',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _serialNumberController,
            decoration: InputDecoration(
              labelText: _t(t, 'serial', 'Serial'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _itemNumberController,
            decoration: InputDecoration(
              labelText: _t(t, 'item', 'Item'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.inventory),
            ),
          ),
        ];

      case TipoFase.instalacao:
        if (widget.fase.componenteId.contains('Blade') ||
            widget.fase.componenteId.contains('blade')) {
          return [
            DropdownButtonFormField<String>(
              initialValue: _posicao,
              decoration: InputDecoration(
                labelText: _t(t, 'posicaoBlade', 'Posição Blade'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
              ),
              items: ['A', 'B', 'C'].map((pos) {
                return DropdownMenuItem(
                  value: pos,
                  child: Text('Posição $pos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _posicao = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _vuiController,
              decoration: InputDecoration(
                labelText: 'VUI (${_t(t, 'readonly', 'readonly')})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
                enabled: false,
              ),
            ),
          ];
        }
        return [];

      default:
        return [];
    }
  }

  Widget _buildFotosSection(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t(t, 'fotos', 'Fotos'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _adicionarFoto,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_t(t, 'adicionar', 'Adicionar')),
            ),
          ],
        ),
        if (_fotos.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fotos.map((url) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _fotos.remove(url);
                        });
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 10),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          )
        else
          Text(
            _t(t, 'nenhumaFoto', 'Nenhuma foto adicionada'),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildObservacoesField(Map<String, String> t) {
    return TextFormField(
      controller: _observacoesController,
      decoration: InputDecoration(
        labelText: _t(t, 'observacoes', 'Observações'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.notes),
        hintText: _t(t, 'observacoesOpcionais', 'Observações opcionais...'),
      ),
      maxLines: 3,
    );
  }

  Widget _buildMotivoNAField(Map<String, String> t) {
    return TextFormField(
      initialValue: _motivoNA ?? '',
      decoration: InputDecoration(
        labelText: _t(t, 'motivoNA', 'Motivo N/A'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.info_outline),
        hintText: _t(t, 'indiqueMotivoNA', 'Indique o motivo...'),
      ),
      maxLines: 3,
      onChanged: (value) {
        _motivoNA = value;
      },
      validator: (value) {
        if (_isFaseNA && (value == null || value.isEmpty)) {
          return _t(t, 'motivoObrigatorio', 'Motivo obrigatório');
        }
        return null;
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO ADICIONAR FOTO - COMPLETO COM OCR
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _adicionarFoto() async {
    try {
      debugPrint('📸 _adicionarFoto: Iniciando processo de foto');

      // ════════════════════════════════════════════════════════════════════
      // 1. ESCOLHER SOURCE BASEADO NA PLATAFORMA
      // ════════════════════════════════════════════════════════════════════
      ImageSource? source;

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: Perguntar se quer câmara ou galeria
        source = await showLiquidDialog<ImageSource>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Adicionar Foto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.orange),
                  title: const Text('Tirar Foto'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Colors.orange),
                  title: const Text('Escolher da Galeria'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      } else {
        // Desktop: Apenas galeria (sem câmara)
        source = ImageSource.gallery;
        debugPrint('💻 Desktop detectado: usando apenas galeria');
      }

      if (source == null) {
        debugPrint('⚠️ Utilizador cancelou seleção de source');
        return;
      }

      // ════════════════════════════════════════════════════════════════════
      // 2. TIRAR/ESCOLHER FOTO
      // ════════════════════════════════════════════════════════════════════
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        debugPrint('⚠️ Nenhuma imagem selecionada');
        return;
      }

      debugPrint('✅ Foto capturada: ${image.path}');

      // ════════════════════════════════════════════════════════════════════
      // 3. PERGUNTAR SE QUER OCR (APENAS EM MOBILE E SE FOR RECEÇÃO)
      // ════════════════════════════════════════════════════════════════════
      if (_ocrService.isOCRAvailable && widget.fase.tipo == TipoFase.recepcao) {
        final shouldExtractText = await _showOCRConfirmDialog();

        if (shouldExtractText == true) {
          await _extractTextFromImage(image.path);
        } else {
          debugPrint('⏭️ Utilizador optou por não usar OCR');
        }
      } else if (!_ocrService.isOCRAvailable) {
        debugPrint(
            '⚠️ OCR não disponível nesta plataforma (${OCRFactory.platformName})');
      }

      // ════════════════════════════════════════════════════════════════════
      // 4. UPLOAD PARA FIREBASE
      // ════════════════════════════════════════════════════════════════════
      final bytes = await image.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          'turbinas/${widget.turbinaId}/componentes/${widget.fase.componenteId}/${widget.fase.tipo.name}/foto_$timestamp.jpg';

      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      setState(() {
        _fotos.add(url);
      });

      debugPrint('✅ Foto adicionada à lista. URL: $url');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Foto adicionada com sucesso'),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao adicionar foto: $e');
      debugPrint('StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 DIALOG DE CONFIRMAÇÃO DE OCR
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool?> _showOCRConfirmDialog() {
    return showLiquidDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Extrair Texto?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quer extrair automaticamente o VUI, Serial e Item desta foto?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Os campos serão preenchidos automaticamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não, obrigado'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Sim, extrair!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 EXTRAIR TEXTO DA IMAGEM (OCR)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _extractTextFromImage(String imagePath) async {
    setState(() => _isProcessingOCR = true);

    try {
      debugPrint('🔍 Iniciando OCR na imagem: $imagePath');

      // ════════════════════════════════════════════════════════════════════
      // 1. EXTRAIR CAMPOS
      // ════════════════════════════════════════════════════════════════════
      final dados = await _ocrService.extrairDadosComponente(imagePath);

      if (kDebugMode && mounted) {
        await _showOCRDebugDialog(dados);
      }

      debugPrint('📊 Dados extraídos:');
      debugPrint('   VUI: ${dados['vui']}');
      debugPrint('   Serial: ${dados['serial']}');
      debugPrint('   Item: ${dados['item']}');

      // ════════════════════════════════════════════════════════════════════
      // 2. PREENCHER CAMPOS
      // ════════════════════════════════════════════════════════════════════
      setState(() {
        if (dados['vui']!.isNotEmpty) {
          _vuiController.text = dados['vui']!;
          debugPrint('   ✅ VUI preenchido: ${dados['vui']}');
        }

        if (dados['serial']!.isNotEmpty) {
          _serialNumberController.text = dados['serial']!;
          debugPrint('   ✅ Serial preenchido: ${dados['serial']}');
        }

        if (dados['item']!.isNotEmpty) {
          _itemNumberController.text = dados['item']!;
          debugPrint('   ✅ Item preenchido: ${dados['item']}');
        }
      });

      // ════════════════════════════════════════════════════════════════════
      // 3. FEEDBACK AO UTILIZADOR
      // ════════════════════════════════════════════════════════════════════
      final camposPreenchidos = [
        if (dados['vui']!.isNotEmpty) 'VUI',
        if (dados['serial']!.isNotEmpty) 'Serial',
        if (dados['item']!.isNotEmpty) 'Item',
      ];

      if (mounted) {
        if (camposPreenchidos.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Campos preenchidos: ${camposPreenchidos.join(', ')}',
              ),
              backgroundColor: AppColors.successGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Nenhum campo identificado na foto'),
              backgroundColor: AppColors.warningOrange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro no OCR: $e');
      debugPrint('StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao extrair texto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingOCR = false);
      }
    }
  }

  Future<void> _showOCRDebugDialog(Map<String, String> dados) {
    final source = dados['debug_source'] ?? 'N/A';
    final rawText = dados['debug_rawText'] ?? '';
    final layoutVui = dados['debug_layout_vui'] ?? '';
    final layoutSerial = dados['debug_layout_serial'] ?? '';
    final layoutItem = dados['debug_layout_item'] ?? '';
    final sectionVui = dados['debug_sections_vui'] ?? '';
    final sectionSerial = dados['debug_sections_serial'] ?? '';
    final sectionItem = dados['debug_sections_item'] ?? '';
    final heuristicVui = dados['debug_heuristic_vui'] ?? '';
    final heuristicSerial = dados['debug_heuristic_serial'] ?? '';
    final heuristicItem = dados['debug_heuristic_item'] ?? '';

    return showLiquidDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OCR Debug (dev)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Fonte: $source'),
                const SizedBox(height: 8),
                Text(
                    'Layout → VUI: $layoutVui | Serial: $layoutSerial | Item: $layoutItem'),
                const SizedBox(height: 4),
                Text(
                    'Secções → VUI: $sectionVui | Serial: $sectionSerial | Item: $sectionItem'),
                const SizedBox(height: 4),
                Text(
                    'Heurística → VUI: $heuristicVui | Serial: $heuristicSerial | Item: $heuristicItem'),
                const SizedBox(height: 8),
                Text(
                    'Final → VUI: ${dados['vui']} | Serial: ${dados['serial']} | Item: ${dados['item']}'),
                const SizedBox(height: 12),
                const Text('Texto OCR bruto:'),
                const SizedBox(height: 6),
                SelectableText(
                  rawText.isEmpty ? '(vazio)' : rawText,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  int _calcularProgresso() {
    if (_isFaseNA) return 100;

    int total = 2;
    int preenchidos = 0;

    if (_dataInicio != null) preenchidos++;
    if (_dataFim != null) preenchidos++;

    if (widget.fase.tipo == TipoFase.recepcao) {
      total += 1;
      if (_horaRecepcao != null) preenchidos++;

      total += 3;
      if (_vuiController.text.isNotEmpty) preenchidos++;
      if (_serialNumberController.text.isNotEmpty) preenchidos++;
      if (_itemNumberController.text.isNotEmpty) preenchidos++;
    }

    if (widget.fase.tipo == TipoFase.instalacao) {
      total += 2;
      if (_horaInicio != null) preenchidos++;
      if (_horaFim != null) preenchidos++;

      if (widget.fase.componenteId.contains('Blade') ||
          widget.fase.componenteId.contains('blade')) {
        total += 1;
        if (_posicao != null) preenchidos++;
      }
    }

    return ((preenchidos / total) * 100).round();
  }

  void _limparCampos() {
    showLiquidDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warningOrange),
            SizedBox(width: 12),
            Text('Limpar Campos'),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja limpar todos os campos?\n\n'
          'Os dados preenchidos serão apagados permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              setState(() {
                _isSaving = true;
              });

              try {
                debugPrint('\n🗑️ Limpando dados da fase no Firebase...');

                final batch = FirebaseFirestore.instance.batch();

                // 1. Limpar fases_componente/
                final faseRef = FirebaseFirestore.instance
                    .collection('fases_componente')
                    .doc(widget.fase.id);

                batch.update(faseRef, {
                  'vui': FieldValue.delete(),
                  'serialNumber': FieldValue.delete(),
                  'itemNumber': FieldValue.delete(),
                  'observacoes': FieldValue.delete(),
                  'dataInicio': FieldValue.delete(),
                  'dataFim': FieldValue.delete(),
                  'horaRecepcao': FieldValue.delete(),
                  'horaInicio': FieldValue.delete(),
                  'horaFim': FieldValue.delete(),
                  'fotos': [],
                  'progresso': 0.0,
                });

                // 2. Limpar installation_data/
                final installationRef = FirebaseFirestore.instance
                    .collection('installation_data')
                    .doc(widget.turbinaId)
                    .collection('components')
                    .doc(widget.fase.componenteId);

                batch.set(
                    installationRef,
                    {
                      'reception': {
                        'vui': FieldValue.delete(),
                        'serialNumber': FieldValue.delete(),
                        'itemNumber': FieldValue.delete(),
                        'observacoes': FieldValue.delete(),
                        'dataInicio': FieldValue.delete(),
                        'dataFim': FieldValue.delete(),
                        'horaRecepcao': FieldValue.delete(),
                        'fotos': [],
                        'isCompleted': false,
                        'isFaseNA': false,
                        'updatedAt': FieldValue.serverTimestamp(),
                      }
                    },
                    SetOptions(merge: true));

                await batch.commit();
                debugPrint('✅ Dados limpos com sucesso!\n');

                if (mounted) {
                  setState(() {
                    _vuiController.clear();
                    _serialNumberController.clear();
                    _itemNumberController.clear();
                    _observacoesController.clear();
                    _dataInicio = null;
                    _dataFim = null;
                    _horaRecepcao = null;
                    _horaInicio = null;
                    _horaFim = null;
                    _fotos.clear();
                  });
                }

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Campos limpos com sucesso'),
                    backgroundColor: AppColors.successGreen,
                    duration: Duration(seconds: 2),
                  ),
                );

                navigator.pop(true);
              } catch (e) {
                debugPrint('❌ Erro ao limpar campos: $e');

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Erro ao limpar campos: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isSaving = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningOrange,
            ),
            child: const Text('Limpar e Guardar'),
          ),
        ],
      ),
    );
  }

  void _guardar() async {
    debugPrint('\n🟢🟢🟢 MÉTODO _guardar() CHAMADO! 🟢🟢🟢');
    debugPrint('   Fase ID: ${widget.fase.id}');

    if (widget.fase.id.isEmpty) {
      debugPrint('❌❌❌ ERRO CRÍTICO: Fase ID está VAZIO!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ERRO: ID da fase está vazio!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) {
      debugPrint('⚠️ Formulário não validou');
      return;
    }

    // ── Verificar VUI duplicado ──
    final vuiNovo = _vuiController.text.trim();
    if (vuiNovo.isNotEmpty && vuiNovo != (widget.fase.vui ?? '')) {
      final duplicado =
          await _service.checkVuiDuplicado(vuiNovo, widget.fase.id);
      if (duplicado != null && mounted) {
        // Buscar nome legível da turbina
        final turbinaNome =
            await _service.getTurbinaNome(duplicado.turbinaId) ??
                duplicado.turbinaId;
        if (!mounted) return;

        // Derivar nome do componente: remover sufixo "_turbinaId" e capitalizar
        String componenteNome = duplicado.componenteId;
        final suffix = '_${duplicado.turbinaId}';
        if (componenteNome.endsWith(suffix)) {
          componenteNome = componenteNome.substring(
              0, componenteNome.length - suffix.length);
        }
        componenteNome = componenteNome
            .split('_')
            .map((w) =>
                w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');

        final continuar = await showLiquidDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text('VUI Duplicado'),
              ],
            ),
            content: Text(
              'O VUI "$vuiNovo" já está registado:\n\n'
              '• Turbina: $turbinaNome\n'
              '• Componente: $componenteNome\n\n'
              'Deseja continuar mesmo assim?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
        if (continuar != true) return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final progresso = _calcularProgresso();
      debugPrint('   Progresso calculado: $progresso%');

      final faseAtualizada = widget.fase.copyWith(
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        horaRecepcao: _horaRecepcao,
        horaInicio: _horaInicio,
        horaFim: _horaFim,
        vui: _vuiController.text.isEmpty ? null : _vuiController.text,
        serialNumber: _serialNumberController.text.isEmpty
            ? null
            : _serialNumberController.text,
        itemNumber: _itemNumberController.text.isEmpty
            ? null
            : _itemNumberController.text,
        posicao: _posicao,
        fotos: _fotos,
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
        isFaseNA: _isFaseNA,
        motivoNA: _motivoNA,
        progresso: progresso.toDouble(),
      );

      await _service.updateFase(widget.fase.id, faseAtualizada);

      debugPrint('✅ updateFase() completou sem erros!');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fase atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌❌❌ ERRO em _guardar(): $e');
      debugPrint('StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
