import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_providers.dart';
import '../../models/componente.dart';
import '../../core/localization/translation_helper.dart';
import '../../utils/component_mapping.dart';
import '../../services/installation/photo_service.dart';
import '../../providers/permission_provider.dart';
import '../../utils/map_launcher.dart';
import '../../utils/platform_helper.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/ncr/turbine_ncr_section.dart';

class TurbinaDetalhesScreen extends ConsumerStatefulWidget {
  final String turbinaId;
  final int numberOfMiddleSections;

  const TurbinaDetalhesScreen({
    super.key,
    required this.turbinaId,
    this.numberOfMiddleSections = 3,
  });

  @override
  ConsumerState<TurbinaDetalhesScreen> createState() =>
      _TurbinaDetalhesScreenState();
}

class _TurbinaDetalhesScreenState extends ConsumerState<TurbinaDetalhesScreen> {
  final Map<String, bool> _expandedCategories = {
    'Main Components': false,
    'Electrical Systems': false,
    'Mechanical Systems': false,
    'Auxiliary Systems': false,
    'Civil Works': false,
  };
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();

  bool _isMigrating = false;
  bool _isSavingLocation = false;

  bool get _canCaptureGps => PlatformHelper.isMobile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedTurbinaIdProvider.notifier).setValue(widget.turbinaId);
      _checkAndMigrateIfNeeded();
    });
  }

  Future<void> _checkAndMigrateIfNeeded() async {
    setState(() => _isMigrating = true);

    try {
      final componenteService = ref.read(componenteServiceProvider);
      final status =
          await componenteService.getMigrationStatus(widget.turbinaId);

      debugPrint('📊 Status migração As-Built:');
      debugPrint('   Total: ${status['total']}');
      debugPrint('   Migrados: ${status['migrated']}');
      debugPrint('   Pendentes: ${status['pending']}');

      if (status['pending'] > 0) {
        debugPrint('🔄 As-Built: Migrando ${status['pending']} componentes...');
        await componenteService.migrateComponentesForTurbina(widget.turbinaId);
        debugPrint('✅ As-Built: Migração automática concluída!');
      }

      // ════════════════════════════════════════════════════════════════════
      // 🔧 CORREÇÃO AUTOMÁTICA DE COMPONENTES (SÓ UMA VEZ)
      // ════════════════════════════════════════════════════════════════════
      await _checkAndFixComponentsIfNeeded();
    } catch (e) {
      debugPrint('❌ Erro na migração automática: $e');
    } finally {
      if (mounted) {
        setState(() => _isMigrating = false);
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 VERIFICAR E CORRIGIR COMPONENTES AUTOMATICAMENTE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _checkAndFixComponentsIfNeeded() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Verificar se já foi feita a correção nesta turbina
      final turbinaDoc =
          await firestore.collection('turbinas').doc(widget.turbinaId).get();

      final turbinaData = turbinaDoc.data();
      final alreadyFixed = turbinaData?['componentsFixed'] == true;

      if (alreadyFixed) {
        debugPrint(
            '✅ Componentes desta turbina já foram corrigidos anteriormente');
        return;
      }

      debugPrint(
          '🔄 Primeira vez abrindo esta turbina. Verificando componentes...');

      // Buscar componentes da turbina
      final snapshot = await firestore
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .get();

      // Verificar se há componentes que precisam de correção
      bool needsFix = false;

      final problematicNames = [
        'Trafo',
        'Nacelle Top Cooler',
        'Ground Controller',
        'Anchor bolts',
        'Blade 1 / a',
        'Blade 2 / b',
        'Blade 3 / c',
      ];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nome = data['nome'] as String;

        // Verificar se tem nome problemático OU não tem hardcodedId
        if (problematicNames.contains(nome) ||
            !data.containsKey('hardcodedId') ||
            data['hardcodedId'] == null) {
          needsFix = true;
          break;
        }
      }

      // Verificar se faltam componentes novos
      final requiredComponents = [
        'transformador',
        'gerador',
        'light_control',
        'light_battery',
        'ups',
        'gearbox',
        'coupling',
        'lift_cables',
        'aviation_light_1',
        'aviation_light_2',
        'grua_interna',
        'cms',
      ];

      for (var hardcodedId in requiredComponents) {
        final componentId = '${hardcodedId}_${widget.turbinaId}';
        final exists =
            await firestore.collection('componentes').doc(componentId).get();

        if (!exists.exists) {
          needsFix = true;
          debugPrint('⚠️  Componente faltando: $hardcodedId');
          break;
        }
      }

      if (needsFix) {
        debugPrint(
            '🔧 Componentes precisam de correção. Corrigindo automaticamente...');
        await _fixAllComponents();

        // Marcar turbina como corrigida
        await firestore.collection('turbinas').doc(widget.turbinaId).update({
          'componentsFixed': true,
          'componentsFixedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Componentes corrigidos e turbina marcada!');
      } else {
        debugPrint('✅ Todos os componentes estão OK!');

        // Marcar como OK mesmo sem correção
        await firestore.collection('turbinas').doc(widget.turbinaId).update({
          'componentsFixed': true,
          'componentsFixedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('❌ Erro na verificação automática: $e');
      // Não bloquear a UI por erro de verificação
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final turbinaAsync = ref.watch(selectedTurbinaProvider);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final panelColor = AppColors.adaptivePanelSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);

    if (_isMigrating) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: DashboardShortcutTitle(
            child: turbinaAsync.when(
              data: (turbina) => Text(turbina?.nome ?? 'Turbina'),
              loading: () => Text(t.translate('loading')),
              error: (_, __) => Text(t.translate('error')),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(strokeWidth: 6),
              ),
              const SizedBox(height: 24),
              Text(
                t.translate('preparing_components'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  t.translate('migration_once_per_turbine'),
                  style: TextStyle(fontSize: 14, color: secondaryText),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: outlineColor),
                ),
                child: Column(
                  children: [
                    Text(
                      '🔧 ${t.translate('syncing_from_installation')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '✓ ${t.translate('adding_hardcoded_ids')}\n'
                      '✓ ${t.translate('fixing_component_names')}\n'
                      '✓ ${t.translate('creating_missing_components')}',
                      style: TextStyle(fontSize: 11, color: secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: turbinaAsync.when(
            data: (turbina) =>
                Text(turbina?.nome ?? t.translate('turbine_details')),
            loading: () => Text(t.translate('loading')),
            error: (_, __) => Text(t.translate('error')),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final turbinaService = ref.read(turbinaServiceProvider);
              turbinaService.atualizarProgressoTurbina(widget.turbinaId);
            },
            tooltip: t.translate('refresh_progress'),
          ),
        ],
      ),
      body: turbinaAsync.when(
        data: (turbina) {
          if (turbina == null) {
            return Center(child: Text(t.translate('turbine_not_found')));
          }
          return _buildContent(context, turbina, t);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('${t.translate('error')}: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, dynamic turbina, TranslationHelper t) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderCard(turbina, t),
          TurbineNcrSection(
            projectId: turbina.projectId,
            turbinaId: turbina.id,
            turbinaNome: turbina.nome,
          ),
          _buildCategoriesSection(t),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(dynamic turbina, TranslationHelper t) {
    final permissions = ref.watch(permissionProvider(turbina.projectId));
    final canEditLocation = permissions.canManageEquipmentAndDocs;
    final color = AppColors.getStatusColor(turbina.status);
    final progresso = turbina.progresso;
    final location = (turbina.localizacao as String?)?.trim() ?? '';
    _syncLocationDraft(location);
    final draftLocation = _locationController.text.trim();
    final parsedCoordinates = MapLauncher.tryParseCoordinates(draftLocation);
    final hasLocation = draftLocation.isNotEmpty;
    final isDesktop = !PlatformHelper.isMobile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    final trackColor = AppColors.adaptiveProgressTrack(context);
    final gradientColors = isDark
        ? <Color>[
            AppColors.glassSurfaceStrongDark,
            color.withValues(alpha: 0.18),
            AppColors.glassCanvasDark,
          ]
        : <Color>[
            color.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.96),
          ];

    if (isDesktop) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: outlineColor, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
              blurRadius: isDark ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _buildDesktopLocationCard(
                turbina,
                t,
                canEditLocation: canEditLocation,
                color: color,
                primaryText: primaryText,
                secondaryText: secondaryText,
                outlineColor: outlineColor,
                isDark: isDark,
                location: location,
                draftLocation: draftLocation,
                hasLocation: hasLocation,
                parsedCoordinates: parsedCoordinates,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 260,
              child: _buildDesktopProgressCard(
                turbina,
                t,
                color: color,
                progresso: progresso,
                primaryText: primaryText,
                secondaryText: secondaryText,
                outlineColor: outlineColor,
                trackColor: trackColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _buildDesktopMapCard(
                t,
                parsedCoordinates,
                primaryText: primaryText,
                secondaryText: secondaryText,
                outlineColor: outlineColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outlineColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: isDark ? 18 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 108,
                  height: 108,
                  child: CircularProgressIndicator(
                    value: progresso / 100,
                    strokeWidth: 8,
                    backgroundColor: trackColor,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${progresso.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      t.translateStatus(turbina.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            turbina.nome,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${t.translate('status')}: ${t.translateStatus(turbina.status)}",
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: outlineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        parsedCoordinates != null
                            ? t.translate('gps_coordinates')
                            : t.translate('location'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _locationController,
                  focusNode: _locationFocusNode,
                  readOnly: !canEditLocation || _isSavingLocation,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (canEditLocation) {
                      _saveTurbinaLocation(turbina, t);
                    }
                  },
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: t.translate('coordinates_hint_turbine'),
                    hintStyle: TextStyle(color: secondaryText),
                    prefixIcon:
                        Icon(Icons.edit_location_alt_outlined, color: color),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.white.withValues(alpha: 0.84),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                if (canEditLocation) ...[
                  const SizedBox(height: 6),
                  Text(
                    t.translate('manual_coordinates_hint'),
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                ],
                if (!canEditLocation) ...[
                  const SizedBox(height: 6),
                  Text(
                    hasLocation
                        ? parsedCoordinates?.displayValue ?? draftLocation
                        : t.translate('no_location_available'),
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (canEditLocation && _canCaptureGps)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _isSavingLocation
                            ? null
                            : () => _captureCurrentGpsLocation(turbina, t),
                        icon: const Icon(Icons.my_location, size: 16),
                        label: Text(t.translate('capture_gps')),
                      ),
                      OutlinedButton.icon(
                        onPressed: hasLocation
                            ? () => _openTurbineMap(draftLocation, t)
                            : null,
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: Text(t.translate('open_in_maps')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed:
                            _isSavingLocation || draftLocation == location
                                ? null
                                : () => _saveTurbinaLocation(turbina, t),
                        icon: _isSavingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 16),
                        label: Text(t.translate('save')),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLocationCard(
    dynamic turbina,
    TranslationHelper t, {
    required bool canEditLocation,
    required Color color,
    required Color primaryText,
    required Color secondaryText,
    required Color outlineColor,
    required bool isDark,
    required String location,
    required String draftLocation,
    required bool hasLocation,
    required ParsedCoordinates? parsedCoordinates,
  }) {
    return _buildDesktopPanel(
      outlineColor: outlineColor,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                parsedCoordinates != null
                    ? t.translate('gps_coordinates')
                    : t.translate('location'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _locationController,
            focusNode: _locationFocusNode,
            readOnly: !canEditLocation || _isSavingLocation,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (canEditLocation) {
                _saveTurbinaLocation(turbina, t);
              }
            },
            style: TextStyle(fontSize: 14, color: primaryText),
            decoration: InputDecoration(
              hintText: t.translate('coordinates_hint_turbine'),
              hintStyle: TextStyle(color: secondaryText),
              prefixIcon: Icon(Icons.edit_location_alt_outlined, color: color),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white.withValues(alpha: 0.88),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: outlineColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canEditLocation
                ? t.translate('manual_coordinates_hint')
                : hasLocation
                    ? parsedCoordinates?.displayValue ?? draftLocation
                    : t.translate('no_location_available'),
            style: TextStyle(
              fontSize: 12,
              color: secondaryText,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasLocation
                      ? () => _openTurbineMap(draftLocation, t)
                      : null,
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: Text(t.translate('open_in_maps')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSavingLocation || draftLocation == location
                      ? null
                      : () => _saveTurbinaLocation(turbina, t),
                  icon: _isSavingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(t.translate('save')),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProgressCard(
    dynamic turbina,
    TranslationHelper t, {
    required Color color,
    required double progresso,
    required Color primaryText,
    required Color secondaryText,
    required Color outlineColor,
    required Color trackColor,
    required bool isDark,
  }) {
    return _buildDesktopPanel(
      outlineColor: outlineColor,
      isDark: isDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 112,
                  height: 112,
                  child: CircularProgressIndicator(
                    value: progresso / 100,
                    strokeWidth: 8,
                    backgroundColor: trackColor,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${progresso.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      t.translateStatus(turbina.status),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            turbina.nome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${t.translate('status')}: ${t.translateStatus(turbina.status)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMapCard(
    TranslationHelper t,
    ParsedCoordinates? parsedCoordinates, {
    required Color primaryText,
    required Color secondaryText,
    required Color outlineColor,
    required bool isDark,
  }) {
    return _buildDesktopPanel(
      outlineColor: outlineColor,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined,
                  size: 20, color: AppColors.accentTeal),
              const SizedBox(width: 8),
              Text(
                t.translate('open_in_maps'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: parsedCoordinates == null
                  ? Container(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF4F7FB),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.map,
                                  size: 34,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                t.translate('map_preview_waiting'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.translate('map_preview_hint'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              parsedCoordinates.latitude,
                              parsedCoordinates.longitude,
                            ),
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.asbuilt.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    parsedCoordinates.latitude,
                                    parsedCoordinates.longitude,
                                  ),
                                  width: 56,
                                  height: 56,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppColors.errorRed,
                                    size: 38,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Text(
                                parsedCoordinates.displayValue,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPanel({
    required Widget child,
    required Color outlineColor,
    required bool isDark,
  }) {
    return Container(
      height: 252,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outlineColor),
      ),
      child: child,
    );
  }

  Future<void> _openTurbineMap(String location, TranslationHelper t) async {
    final opened = await MapLauncher.openLocation(location);
    if (!mounted || opened) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.translate('unable_to_open_map'))),
    );
  }

  Future<void> _captureCurrentGpsLocation(
      dynamic turbina, TranslationHelper t) async {
    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!servicesEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.translate('location_services_disabled'))),
          );
        }
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.translate('location_permission_denied'))),
          );
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('location_permission_denied_forever')),
            ),
          );
        }
        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final capturedLocation =
          MapLauncher.formatCoordinates(position.latitude, position.longitude);
      _locationController.value = TextEditingValue(
        text: capturedLocation,
        selection: TextSelection.collapsed(offset: capturedLocation.length),
      );

      await _saveTurbinaLocation(
        turbina,
        t,
        locationOverride: capturedLocation,
        successMessage: t.translate('gps_capture_success'),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.translate('gps_capture_error')}: $error')),
      );
    }
  }

  void _syncLocationDraft(String persistedLocation) {
    if (_locationFocusNode.hasFocus) {
      return;
    }

    if (_locationController.text == persistedLocation) {
      return;
    }

    _locationController.value = TextEditingValue(
      text: persistedLocation,
      selection: TextSelection.collapsed(offset: persistedLocation.length),
    );
  }

  Future<void> _saveTurbinaLocation(
    dynamic turbina,
    TranslationHelper t, {
    String? locationOverride,
    String? successMessage,
  }) async {
    final newLocation = (locationOverride ?? _locationController.text).trim();
    final currentLocation = (turbina.localizacao as String?)?.trim() ?? '';

    if (_isSavingLocation || newLocation == currentLocation) {
      return;
    }

    setState(() => _isSavingLocation = true);

    try {
      final turbinaService = ref.read(turbinaServiceProvider);
      await turbinaService.updateTurbina(turbina.id, {
        'localizacao': newLocation.isEmpty ? null : newLocation,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage ?? t.translate('record_saved'))),
      );
      _locationFocusNode.unfocus();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.translate('error')}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingLocation = false);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 DEFINIÇÃO DE COMPONENTES POR CATEGORIA (HARDCODED)
  // ══════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> _getMainComponents() {
    List<Map<String, dynamic>> components = [
      {'id': 'top_cooler', 'nameKey': 'top_cooler', 'icon': Icons.ac_unit},
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

    for (int i = 1; i <= widget.numberOfMiddleSections; i++) {
      components.add({
        'id': 'middle$i',
        'nameKey': 'tower_middle',
        'displayName': 'Middle $i',
        'icon': Icons.filter_2,
      });
    }

    components.addAll([
      {'id': 'top', 'nameKey': 'tower_top', 'icon': Icons.filter_3},
      {'id': 'nacelle', 'nameKey': 'nacelle', 'icon': Icons.home_work},
      {'id': 'drive_train', 'nameKey': 'drive_train', 'icon': Icons.settings},
      {'id': 'hub', 'nameKey': 'hub', 'icon': Icons.album},
      {
        'id': 'blade_1',
        'nameKey': 'blade',
        'displayName': 'Blade 1',
        'icon': Icons.wind_power
      },
      {
        'id': 'blade_2',
        'nameKey': 'blade',
        'displayName': 'Blade 2',
        'icon': Icons.wind_power
      },
      {
        'id': 'blade_3',
        'nameKey': 'blade',
        'displayName': 'Blade 3',
        'icon': Icons.wind_power
      },
    ]);

    return components;
  }

  List<Map<String, dynamic>> _getElectricalSystemsComponents() {
    return [
      {'id': 'mv_cable', 'nameKey': 'mv_cable', 'icon': Icons.cable},
      {'id': 'swg', 'nameKey': 'swg', 'icon': Icons.electrical_services},
      {'id': 'transformador', 'nameKey': 'transformador', 'icon': Icons.power},
      {'id': 'gerador', 'nameKey': 'gerador', 'icon': Icons.electric_bolt},
      {
        'id': 'ground_control',
        'nameKey': 'ground_control',
        'icon': Icons.power_input
      },
      {
        'id': 'light_control',
        'nameKey': 'light_control',
        'icon': Icons.lightbulb
      },
      {
        'id': 'light_battery',
        'nameKey': 'light_battery',
        'icon': Icons.battery_charging_full
      },
      {'id': 'ups', 'nameKey': 'ups', 'icon': Icons.power_settings_new},
    ];
  }

  List<Map<String, dynamic>> _getMechanicalSystemsComponents() {
    return [
      {
        'id': 'gearbox',
        'nameKey': 'gearbox',
        'icon': Icons.settings_applications
      },
      {'id': 'coupling', 'nameKey': 'coupling', 'icon': Icons.link},
      {'id': 'service_lift', 'nameKey': 'service_lift', 'icon': Icons.elevator},
      {'id': 'lift_cables', 'nameKey': 'lift_cables', 'icon': Icons.cable},
    ];
  }

  List<Map<String, dynamic>> _getAuxiliarySystemsComponents() {
    return [
      {'id': 'resq', 'nameKey': 'resq', 'icon': Icons.sos},
      {
        'id': 'aviation_light_1',
        'nameKey': 'aviation_light_1',
        'icon': Icons.local_airport
      },
      {
        'id': 'aviation_light_2',
        'nameKey': 'aviation_light_2',
        'icon': Icons.flight
      },
      {
        'id': 'grua_interna',
        'nameKey': 'grua_interna',
        'icon': Icons.construction
      },
      {'id': 'cms', 'nameKey': 'cms', 'icon': Icons.monitor_heart},
      {'id': 'spare_parts', 'nameKey': 'spare_parts', 'icon': Icons.inventory},
      {
        'id': 'bodies_parts',
        'nameKey': 'bodies_parts',
        'icon': Icons.view_in_ar
      },
    ];
  }

  List<Map<String, dynamic>> _getCivilWorksComponents() {
    return [
      {'id': 'anchor_bolts', 'nameKey': 'anchor_bolts', 'icon': Icons.handyman},
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 SEÇÃO DE CATEGORIAS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoriesSection(TranslationHelper t) {
    final categories = {
      'Main Components': _getMainComponents(),
      'Electrical Systems': _getElectricalSystemsComponents(),
      'Mechanical Systems': _getMechanicalSystemsComponents(),
      'Auxiliary Systems': _getAuxiliarySystemsComponents(),
      'Civil Works': _getCivilWorksComponents(),
    };

    final projectId = ref.watch(selectedProjectIdProvider); // ← NOVO
    final permissions = ref.watch(permissionProvider(projectId)); // ← NOVO
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: categories.entries.map((entry) {
          return _buildCategoryCard(entry.key, entry.value, t, permissions);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryCard(
      String categoria,
      List<Map<String, dynamic>> components,
      TranslationHelper t,
      PermissionNotifier permissions) {
    final isExpanded = _expandedCategories[categoria] ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(categoria);
    final panelColor = AppColors.adaptivePanelSurface(context);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    final categoryLabel = _getCategoryLabel(categoria, t);
    final allowsDynamicComponents = const {
      'Main Components',
      'Electrical Systems',
      'Mechanical Systems',
      'Auxiliary Systems',
      'Civil Works',
    }.contains(categoria);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: panelColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[categoria] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(categoria),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categoryLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ),

                  // ════════════════════════════════════════════════════════════════
                  // 🆕 ADICIONAR ISTO (botão "+")
                  // ════════════════════════════════════════════════════════════════
                  if (allowsDynamicComponents &&
                      isExpanded &&
                      permissions.canManageEquipmentAndDocs)
                    IconButton(
                      icon: Icon(Icons.add_circle, color: categoryColor),
                      onPressed: () => _showAddDynamicComponentDialog(
                        context,
                        categoria,
                        categoryColor,
                        t,
                      ),
                      tooltip: t.translate('add_component_dialog_title'),
                    ),
                  // ════════════════════════════════════════════════════════════════

                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark ? categoryColor : AppColors.mediumGray,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildComponentsGridWithDynamic(components, categoria, t),
            ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String categoria, TranslationHelper t) {
    switch (categoria) {
      case 'Main Components':
        return t.translate('main_components');
      case 'Electrical Systems':
        return t.translate('electrical_systems');
      case 'Mechanical Systems':
        return t.translate('mechanical_systems');
      case 'Auxiliary Systems':
        return t.translate('auxiliary_systems');
      case 'Civil Works':
        return t.translate('civil_works');
      default:
        return t.translateValueOrKey(categoria);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 CARD DE COMPONENTE COM SINCRONIZAÇÃO EM TEMPO REAL
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildComponentCard(
      Map<String, dynamic> component, TranslationHelper t) {
    final componentHardcodedId = component['id'] as String;
    final fullComponentId = ComponentMapping.buildFullComponentId(
      componentHardcodedId,
      widget.turbinaId,
    );

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('installation_data')
          .doc(widget.turbinaId)
          .collection('components')
          .doc(fullComponentId)
          .snapshots(),
      builder: (context, snapshot) {
        // ─────────────────────────────────────────────────────────────────
        // LOADING
        // ─────────────────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCardSkeleton(component, t);
        }

        // ─────────────────────────────────────────────────────────────────
        // ERROR
        // ─────────────────────────────────────────────────────────────────
        if (snapshot.hasError) {
          debugPrint('❌ Erro ao buscar $fullComponentId: ${snapshot.error}');
          return _buildErrorCard(component, t);
        }

        // ─────────────────────────────────────────────────────────────────
        // SEM DADOS
        // ─────────────────────────────────────────────────────────────────
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyCard(component, t);
        }

        // ─────────────────────────────────────────────────────────────────
        // DADOS RECEBIDOS ✅
        // ─────────────────────────────────────────────────────────────────
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return _buildEmptyCard(component, t);
        }

        // Calcular progresso
        double progresso = _calculateProgressFromData(data);

        // Extrair VUI
        String? vui;
        if (data['reception'] != null) {
          final reception = data['reception'] as Map<String, dynamic>;
          vui = reception['vui'] as String?;
        }

        return _buildFilledCard(component, progresso, vui, t);
      },
    );
  }

  double _calculateProgressFromData(Map<String, dynamic> data) {
    double progress = 0;

    // Receção: 20%
    if (data['reception'] != null) {
      final reception = data['reception'] as Map<String, dynamic>;
      bool hasData = (reception['vui'] != null &&
              reception['vui'].toString().isNotEmpty) ||
          (reception['serialNumber'] != null &&
              reception['serialNumber'].toString().isNotEmpty) ||
          (reception['itemNumber'] != null &&
              reception['itemNumber'].toString().isNotEmpty);

      if (reception['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    // Preparação: 20%
    if (data['preparation'] != null) {
      final preparation = data['preparation'] as Map<String, dynamic>;
      if (preparation['isCompleted'] == true ||
          preparation['dataInicio'] != null ||
          preparation['dataFim'] != null) {
        progress += 20;
      }
    }

    // Pre-Assembly: 20%
    if (data['preAssembly'] != null) {
      final preAssembly = data['preAssembly'] as Map<String, dynamic>;
      if (preAssembly['isCompleted'] == true ||
          preAssembly['dataInicio'] != null ||
          preAssembly['dataFim'] != null) {
        progress += 20;
      }
    }

    // Assembly: 20%
    if (data['assembly'] != null) {
      final assembly = data['assembly'] as Map<String, dynamic>;
      if (assembly['isCompleted'] == true ||
          assembly['dataInicio'] != null ||
          assembly['dataFim'] != null) {
        progress += 20;
      }
    }

    // Fases Finais: 20%
    if (data['finalPhases'] != null) {
      final finalPhases = data['finalPhases'] as Map<String, dynamic>;
      int completedFinalPhases = 0;
      int totalFinalPhases = 0;

      finalPhases.forEach((key, value) {
        if (value is Map && value['isCompleted'] == true) {
          completedFinalPhases++;
        }
        totalFinalPhases++;
      });

      if (totalFinalPhases > 0) {
        progress += (completedFinalPhases / totalFinalPhases) * 20;
      }
    }

    return progress.clamp(0.0, 100.0);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 VARIAÇÕES DO CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFilledCard(Map<String, dynamic> component, double progresso,
      String? vui, TranslationHelper t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final Color statusColor = progresso >= 100
        ? AppColors.successGreen
        : progresso > 0
            ? AppColors.warningOrange
            : AppColors.mediumGray;
    final cardColor = AppColors.adaptiveCardSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);

    final displayName =
        component['displayName'] ?? t.translate(component['nameKey'] as String);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: InkWell(
        onTap: () => _openComponentDetails(component),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(component['icon'] as IconData, size: 28, color: statusColor),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isDark ? primaryText : AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (vui != null && vui.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  vui,
                  style: TextStyle(
                    fontSize: 8,
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${progresso.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? primaryText : statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(Map<String, dynamic> component, TranslationHelper t) {
    final cardColor = AppColors.adaptiveCardSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    final mutedText = AppColors.adaptiveMutedText(context);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final displayName =
        component['displayName'] ?? t.translate(component['nameKey'] as String);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: InkWell(
        onTap: () => _openComponentDetails(component),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(component['icon'] as IconData, size: 28, color: mutedText),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '0%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSkeleton(
      Map<String, dynamic> component, TranslationHelper t) {
    final cardColor = AppColors.adaptiveCardSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(Map<String, dynamic> component, TranslationHelper t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outlineColor = AppColors.adaptiveOutline(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF3A2326) : Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: InkWell(
        onTap: () => _openComponentDetails(component),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 28, color: Colors.red[300]),
              const SizedBox(height: 4),
              Text(
                'Erro',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 ABRIR DIALOG DE DETALHES (COM DEBUG COMPLETO)
  // ══════════════════════════════════════════════════════════════════════════

  void _openComponentDetails(Map<String, dynamic> component) async {
    final projectId = ref.read(selectedProjectIdProvider);
    final permissions = ref.read(permissionProvider(projectId));
    final componentHardcodedId = component['id'] as String;
    final fullComponentId = ComponentMapping.buildFullComponentId(
      componentHardcodedId,
      widget.turbinaId,
    );

    debugPrint(
        '\n╔════════════════════════════════════════════════════════════╗');
    debugPrint('║  🔍 ABRINDO DETALHES DO COMPONENTE                        ║');
    debugPrint(
        '╚════════════════════════════════════════════════════════════╝');
    debugPrint('   hardcodedId: $componentHardcodedId');
    debugPrint('   fullComponentId: $fullComponentId');
    debugPrint('   turbinaId: ${widget.turbinaId}');
    debugPrint('───────────────────────────────────────────────────────────');

    try {
      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 1: Busca Direta por ID
      // ════════════════════════════════════════════════════════════════════
      debugPrint('🔄 Tentando busca direta por ID: $fullComponentId');

      final snapshot = await FirebaseFirestore.instance
          .collection('componentes')
          .doc(fullComponentId)
          .get();

      if (snapshot.exists) {
        debugPrint('✅ ENCONTRADO via busca direta!');
        final data = snapshot.data()!;

        // Debug: Mostrar TODOS os campos
        debugPrint('📋 Campos do componente:');
        data.forEach((key, value) {
          debugPrint('   • $key: $value');
        });
        debugPrint(
            '───────────────────────────────────────────────────────────');

        final componente = Componente.fromFirestore(snapshot);
        debugPrint('✅ Componente parseado com sucesso: ${componente.nome}');

        if (mounted) {
          showLiquidDialog(
            context: context,
            builder: (context) => EditComponenteDialog(
              componente: componente,
              canEdit: permissions.canManageEquipmentAndDocs,
            ),
          );
        }
        return;
      }

      debugPrint('❌ NÃO encontrado via busca direta');

      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 2: Busca por Query (Fallback)
      // ════════════════════════════════════════════════════════════════════
      debugPrint('🔄 Tentando busca por query...');
      debugPrint('   turbinaId: ${widget.turbinaId}');
      debugPrint('   hardcodedId: $componentHardcodedId');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .where('hardcodedId', isEqualTo: componentHardcodedId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('✅ ENCONTRADO via query!');
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        // Debug: Mostrar TODOS os campos
        debugPrint('📋 Campos do componente:');
        data.forEach((key, value) {
          debugPrint('   • $key: $value');
        });
        debugPrint(
            '───────────────────────────────────────────────────────────');

        final componente = Componente.fromFirestore(doc);
        debugPrint('✅ Componente parseado com sucesso: ${componente.nome}');

        if (mounted) {
          showLiquidDialog(
            context: context,
            builder: (context) => EditComponenteDialog(
              componente: componente,
              canEdit: permissions.canManageEquipmentAndDocs,
            ),
          );
        }
        return;
      }

      debugPrint('❌ NÃO encontrado via query');

      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 3: Listar TODOS os componentes da turbina (DEBUG)
      // ════════════════════════════════════════════════════════════════════
      debugPrint('🔍 Listando TODOS os componentes desta turbina:');

      final allComponents = await FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .get();

      debugPrint('📊 Total encontrados: ${allComponents.docs.length}');

      for (var doc in allComponents.docs) {
        final data = doc.data();
        debugPrint('   • ID: ${doc.id}');
        debugPrint('     nome: ${data['nome']}');
        debugPrint('     hardcodedId: ${data['hardcodedId'] ?? "[NÃO TEM]"}');
        debugPrint('     categoria: ${data['categoria']}');
      }
      debugPrint('───────────────────────────────────────────────────────────');

      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 4: Buscar por NOME (último recurso)
      // ════════════════════════════════════════════════════════════════════
      final componentName =
          ComponentMapping.hardcodedToName[componentHardcodedId];
      if (componentName != null) {
        debugPrint('🔄 Tentando buscar por nome: $componentName');

        final nameQuerySnapshot = await FirebaseFirestore.instance
            .collection('componentes')
            .where('turbinaId', isEqualTo: widget.turbinaId)
            .where('nome', isEqualTo: componentName)
            .limit(1)
            .get();

        if (nameQuerySnapshot.docs.isNotEmpty) {
          debugPrint('✅ ENCONTRADO por nome!');
          final doc = nameQuerySnapshot.docs.first;

          debugPrint(
              '⚠️  PROBLEMA: Componente existe mas não tem hardcodedId correto!');
          debugPrint(
              '   Executar script de correção: fixComponentsHardcodedId()');

          final componente = Componente.fromFirestore(doc);

          if (mounted) {
            showLiquidDialog(
              context: context,
              builder: (context) => EditComponenteDialog(
                componente: componente,
                canEdit: permissions.canManageEquipmentAndDocs,
              ),
            );
          }
          return;
        }
      }

      // ════════════════════════════════════════════════════════════════════
      // Nenhuma estratégia funcionou
      // ════════════════════════════════════════════════════════════════════
      debugPrint('❌ COMPONENTE NÃO ENCONTRADO em nenhuma estratégia!');
      debugPrint(
          '═══════════════════════════════════════════════════════════\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Component not found: $componentName'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('❌ ERRO ao buscar componente: $error');
      debugPrint('StackTrace: $stackTrace');
      debugPrint(
          '═══════════════════════════════════════════════════════════\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Civil Works':
        return const Color(0xFF94A3B8);
      case 'Main Components':
        return const Color(0xFF1E3A8A);
      case 'Electrical Systems':
        return const Color(0xFFEA580C);
      case 'Mechanical Systems':
        return const Color(0xFF059669);
      case 'Auxiliary Systems':
        return const Color(0xFF0891B2);
      default:
        return AppColors.mediumGray;
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Civil Works':
        return Icons.foundation;
      case 'Main Components':
        return Icons.wind_power;
      case 'Electrical Systems':
        return Icons.electrical_services;
      case 'Mechanical Systems':
        return Icons.precision_manufacturing;
      case 'Auxiliary Systems':
        return Icons.elevator;
      default:
        return Icons.widgets;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 MÉTODO DE CORREÇÃO DE COMPONENTES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _fixAllComponents() async {
    final firestore = FirebaseFirestore.instance;

    debugPrint(
        '\n╔════════════════════════════════════════════════════════════╗');
    debugPrint('║  🔧 CORREÇÃO COMPLETA DE COMPONENTES                      ║');
    debugPrint(
        '╚════════════════════════════════════════════════════════════╝\n');

    final componentFixes = {
      'Trafo': {
        'newName': 'Transformador',
        'hardcodedId': 'transformador',
        'categoria': 'Electrical Systems',
      },
      'Nacelle Top Cooler': {
        'newName': 'Top Cooler',
        'hardcodedId': 'top_cooler',
        'categoria': 'Main Components',
      },
      'Ground Controller': {
        'newName': 'Ground Control',
        'hardcodedId': 'ground_control',
        'categoria': 'Electrical Systems',
      },
      'Anchor bolts': {
        'newName': 'Anchor Bolts',
        'hardcodedId': 'anchor_bolts',
        'categoria': 'Civil Works',
      },
      'Blade 1 / a': {
        'newName': 'Blade 1',
        'hardcodedId': 'blade_1',
        'categoria': 'Main Components',
      },
      'Blade 2 / b': {
        'newName': 'Blade 2',
        'hardcodedId': 'blade_2',
        'categoria': 'Main Components',
      },
      'Blade 3 / c': {
        'newName': 'Blade 3',
        'hardcodedId': 'blade_3',
        'categoria': 'Main Components',
      },
    };

    try {
      final snapshot = await firestore
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .get();

      debugPrint('✅ Encontrados ${snapshot.docs.length} componentes\n');

      int fixed = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nome = data['nome'] as String;

        if (componentFixes.containsKey(nome)) {
          final fix = componentFixes[nome]!;
          final newName = fix['newName']!;
          final hardcodedId = fix['hardcodedId']!;
          final newId = '${hardcodedId}_${widget.turbinaId}';

          debugPrint('🔧 Corrigindo: $nome → $newName');

          await firestore.collection('componentes').doc(newId).set({
            ...data,
            'nome': newName,
            'hardcodedId': hardcodedId,
            'categoria': fix['categoria']!,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          await doc.reference.delete();

          debugPrint('   ✅ CORRIGIDO: $newId');
          fixed++;
        }
      }

      // Criar componentes novos
      final newComponents = [
        {
          'hardcodedId': 'gerador',
          'nome': 'Gerador',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'light_control',
          'nome': 'Light Control',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'light_battery',
          'nome': 'Light Battery',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'ups',
          'nome': 'UPS',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'gearbox',
          'nome': 'Gearbox',
          'categoria': 'Mechanical Systems'
        },
        {
          'hardcodedId': 'coupling',
          'nome': 'Coupling',
          'categoria': 'Mechanical Systems'
        },
        {
          'hardcodedId': 'lift_cables',
          'nome': 'Lift Cables',
          'categoria': 'Mechanical Systems'
        },
        {
          'hardcodedId': 'aviation_light_1',
          'nome': 'Aviation Light 1',
          'categoria': 'Auxiliary Systems'
        },
        {
          'hardcodedId': 'aviation_light_2',
          'nome': 'Aviation Light 2',
          'categoria': 'Auxiliary Systems'
        },
        {
          'hardcodedId': 'grua_interna',
          'nome': 'Grua Interna',
          'categoria': 'Auxiliary Systems'
        },
        {'hardcodedId': 'cms', 'nome': 'CMS', 'categoria': 'Auxiliary Systems'},
      ];

      int created = 0;

      for (var comp in newComponents) {
        final hardcodedId = comp['hardcodedId']!;
        final newId = '${hardcodedId}_${widget.turbinaId}';

        final exists =
            await firestore.collection('componentes').doc(newId).get();

        if (!exists.exists) {
          debugPrint('🆕 Criando: ${comp['nome']}');

          final turbinaDoc = await firestore
              .collection('turbinas')
              .doc(widget.turbinaId)
              .get();
          final projectId = turbinaDoc.data()?['projectId'] ?? '';

          await firestore.collection('componentes').doc(newId).set({
            'nome': comp['nome']!,
            'hardcodedId': hardcodedId,
            'categoria': comp['categoria']!,
            'turbinaId': widget.turbinaId,
            'projectId': projectId,
            'progresso': 0.0,
            'status': 'Pendente',
            'aplicavel': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          debugPrint('   ✅ CRIADO: $newId');
          created++;
        }
      }

      debugPrint(
          '\n═══════════════════════════════════════════════════════════');
      debugPrint('📊 RESUMO: $fixed corrigidos, $created criados');
      debugPrint(
          '═══════════════════════════════════════════════════════════\n');
    } catch (e, stackTrace) {
      debugPrint('❌ ERRO: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }
  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO 1: GRID COM COMPONENTES DINÂMICOS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildComponentsGridWithDynamic(
    List<Map<String, dynamic>> staticComponents,
    String categoria,
    TranslationHelper t,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .where('isDynamic', isEqualTo: true)
          .where('categoria', isEqualTo: categoria)
          .snapshots(),
      builder: (context, dynamicSnapshot) {
        final allComponents = <Map<String, dynamic>>[...staticComponents];

        if (dynamicSnapshot.hasData && dynamicSnapshot.data != null) {
          for (var doc in dynamicSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            allComponents.add({
              'id': data['hardcodedId'] ?? doc.id,
              'nameKey': data['nome'],
              'displayName': data['nome'],
              'icon': Icons.inventory_2,
              'isDynamic': true,
            });
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 8 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: allComponents.length,
          itemBuilder: (context, index) {
            return _buildComponentCard(allComponents[index], t);
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO 2: DIALOG PARA CRIAR COMPONENTE
  // ══════════════════════════════════════════════════════════════════════════

  void _showAddDynamicComponentDialog(
    BuildContext context,
    String categoria,
    Color categoryColor,
    TranslationHelper t,
  ) {
    final nameController = TextEditingController();
    final selectedPhases = <String>{};
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final panelColor = AppColors.adaptivePanelSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);

    final availablePhases = [
      {'id': 'reception', 'name': 'Reception', 'icon': '📦'},
      {'id': 'preparation', 'name': 'Preparation', 'icon': '📋'},
      {'id': 'preAssembly', 'name': 'Pre-Assembly', 'icon': '🔧'},
      {'id': 'assembly', 'name': 'Assembly', 'icon': '🏗️'},
    ];

    showLiquidDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_circle, color: categoryColor),
                const SizedBox(width: 12),
                Text(
                  t.translate('add_component_dialog_title'),
                  style: TextStyle(color: primaryText),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.translate('component_name'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: primaryText),
                      decoration: InputDecoration(
                        hintText: t.translate('component_name_hint'),
                        hintStyle: TextStyle(color: secondaryText),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: outlineColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: categoryColor),
                        ),
                        filled: true,
                        fillColor: AppColors.adaptiveCardSurface(context),
                        prefixIcon: Icon(Icons.label, color: categoryColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Fases de Integração',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: panelColor,
                        border: Border.all(color: outlineColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: availablePhases.map((phase) {
                          final phaseId = phase['id'] as String;
                          final phaseName = phase['name'] as String;
                          final phaseIcon = phase['icon'] as String;
                          final isSelected = selectedPhases.contains(phaseId);

                          return CheckboxListTile(
                            title: Row(
                              children: [
                                Text(phaseIcon),
                                const SizedBox(width: 8),
                                Text(
                                  phaseName,
                                  style: TextStyle(color: primaryText),
                                ),
                              ],
                            ),
                            value: isSelected,
                            activeColor: categoryColor,
                            checkColor: Colors.white,
                            side: BorderSide(color: outlineColor),
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedPhases.add(phaseId);
                                } else {
                                  selectedPhases.remove(phaseId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    if (selectedPhases.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Selecione pelo menos uma fase',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.adaptivePrimaryText(context)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.translate('cancel')),
              ),
              ElevatedButton.icon(
                onPressed: nameController.text.trim().isEmpty ||
                        selectedPhases.isEmpty
                    ? null
                    : () async {
                        final componentName = nameController.text.trim();
                        Navigator.pop(context);
                        await _createDynamicComponent(
                            componentName, categoria, selectedPhases.toList());
                      },
                icon: const Icon(Icons.add),
                label: Text(t.translate('create')),
                style: ElevatedButton.styleFrom(backgroundColor: categoryColor),
              ),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO 3: CRIAR COMPONENTE NO FIREBASE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _createDynamicComponent(
    String componentName,
    String categoria,
    List<String> selectedPhases,
  ) async {
    try {
      debugPrint('🆕 Criando: $componentName');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Criando componente...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final firestore = FirebaseFirestore.instance;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = componentName
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final hardcodedId = '${sanitizedName}_$timestamp';
      final fullComponentId = '${hardcodedId}_${widget.turbinaId}';

      final turbinaDoc =
          await firestore.collection('turbinas').doc(widget.turbinaId).get();
      final projectId = turbinaDoc.data()?['projectId'] ?? '';

      await firestore.collection('componentes').doc(fullComponentId).set({
        'nome': componentName,
        'hardcodedId': hardcodedId,
        'categoria': categoria,
        'turbinaId': widget.turbinaId,
        'projectId': projectId,
        'progresso': 0.0,
        'status': 'Pendente',
        'aplicavel': true,
        'isDynamic': true,
        'selectedPhases': selectedPhases,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final installationRef = firestore
          .collection('installation_data')
          .doc(widget.turbinaId)
          .collection('components')
          .doc(fullComponentId);

      final installationData = <String, dynamic>{};
      for (var phase in selectedPhases) {
        installationData[phase] = {
          'isCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
      }
      await installationRef.set(installationData);

      final phaseMapping = {
        'reception': 'recepcao',
        'preparation': 'preparacao',
        'preAssembly': 'preInstalacao',
        'assembly': 'instalacao',
      };

      for (var phase in selectedPhases) {
        final tipoFase = phaseMapping[phase];
        if (tipoFase == null) continue;

        final faseId = '${fullComponentId}_$tipoFase';
        await firestore.collection('fases_componente').doc(faseId).set({
          'componenteId': fullComponentId,
          'turbinaId': widget.turbinaId,
          'tipo': tipoFase,
          'progresso': 0.0,
          'isFaseNA': false,
          'fotos': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "$componentName" criado!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Erro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class EditComponenteDialog extends ConsumerStatefulWidget {
  final Componente componente;
  final bool canEdit;

  const EditComponenteDialog({
    super.key,
    required this.componente,
    required this.canEdit,
  });

  @override
  ConsumerState<EditComponenteDialog> createState() =>
      _EditComponenteDialogState();
}

class _EditComponenteDialogState extends ConsumerState<EditComponenteDialog> {
  late double _progresso;
  late String _status;
  late bool _aplicavel;
  late String turbinaId;
  late String _componenteId;

  final _itemNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _vuiController = TextEditingController();
  final _observacoesController = TextEditingController();

  bool _isLoading = false;
  bool _isBlocked = false;
  String? _blockReason;
  String? _blockedBy;
  bool get _canInteract => widget.canEdit && !_isBlocked;

  List<String> _photos = [];
  List<Map<String, dynamic>> _aggregatedNotes = [];

  StreamSubscription<DocumentSnapshot>? _installationListener;
  bool _isSyncingFromInstallation = false;

  @override
  void initState() {
    super.initState();

    turbinaId = widget.componente.turbinaId; // ← linha nova
    _componenteId = widget.componente.id; // ← linha nova

    _progresso = widget.componente.progresso;
    _status = widget.componente.status;

    if (!['Pendente', 'Em Progresso', 'Concluído', 'Bloqueado', 'N/A']
        .contains(_status)) {
      _status = 'Pendente';
    }

    _aplicavel = widget.componente.aplicavel;
    _itemNumberController.text = widget.componente.itemNumber ?? '';
    _serialNumberController.text = widget.componente.serialNumber ?? '';
    _vuiController.text = widget.componente.vui ?? '';
    _observacoesController.text = widget.componente.observacoes ?? '';

    if (_status == 'N/A') {
      _aplicavel = false;
    }

    if (_status == 'Bloqueado') {
      _isBlocked = true;
    }

    _startInstallationListener();
  }

  void _startInstallationListener() {
    debugPrint(
        '🔄 Iniciando listener para: ${widget.componente.turbinaId} / ${widget.componente.id}');
    debugPrint('📋 hardcodedId: ${widget.componente.hardcodedId}');

    String installationDocId;

    if (widget.componente.hardcodedId != null) {
      installationDocId = ComponentMapping.buildFullComponentId(
        widget.componente.hardcodedId!,
        widget.componente.turbinaId,
      );
      debugPrint('✅ Usando hardcodedId: $installationDocId');
    } else {
      installationDocId = widget.componente.id;
      debugPrint(
          '⚠️ Sem hardcodedId, usando ID do componente: $installationDocId');
    }

    _installationListener = FirebaseFirestore.instance
        .collection('installation_data')
        .doc(widget.componente.turbinaId)
        .collection('components')
        .doc(installationDocId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!snapshot.exists) {
          debugPrint(
              'ℹ️ Documento de instalação ainda não existe: $installationDocId');
          return;
        }

        debugPrint('✅ Dados da instalação recebidos para: $installationDocId');
        _syncFromInstallation(snapshot.data() as Map<String, dynamic>);
      },
      onError: (error) {
        debugPrint('❌ Erro no listener: $error');
      },
    );
  }

  void _syncFromInstallation(Map<String, dynamic> data) {
    if (_isSyncingFromInstallation) return;

    setState(() {
      _isSyncingFromInstallation = true;

      if (data['reception'] != null) {
        final reception = data['reception'] as Map<String, dynamic>;

        _vuiController.text = reception['vui'] ?? '';
        _serialNumberController.text = reception['serialNumber'] ?? '';
        _itemNumberController.text = reception['itemNumber'] ?? '';

        debugPrint('📦 Campos auto-preenchidos da Receção');
      }

      _progresso = _calculateProgressFromPhases(data);
      debugPrint('📊 Progresso calculado: $_progresso%');

      if (!_isBlocked && _status != 'N/A') {
        _status = _getAutoStatus();
        debugPrint('📊 Status atualizado: $_status');
      }

      _aggregatedNotes = _aggregateNotes(data);
      debugPrint('📝 ${_aggregatedNotes.length} notas agregadas');

      _photos = _aggregatePhotos(data);
      debugPrint('📸 ${_photos.length} fotos agregadas');

      _isSyncingFromInstallation = false;
    });

    _updateComponenteInAsBuilt();
  }

  double _calculateProgressFromPhases(Map<String, dynamic> data) {
    double progress = 0;

    if (data['reception'] != null) {
      final reception = data['reception'] as Map<String, dynamic>;
      bool hasData = (reception['vui'] != null &&
              reception['vui'].toString().isNotEmpty) ||
          (reception['serialNumber'] != null &&
              reception['serialNumber'].toString().isNotEmpty) ||
          (reception['itemNumber'] != null &&
              reception['itemNumber'].toString().isNotEmpty);

      if (reception['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    if (data['preparation'] != null) {
      final preparation = data['preparation'] as Map<String, dynamic>;
      bool hasData =
          preparation['dataInicio'] != null || preparation['dataFim'] != null;

      if (preparation['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    if (data['preAssembly'] != null) {
      final preAssembly = data['preAssembly'] as Map<String, dynamic>;
      bool hasData =
          preAssembly['dataInicio'] != null || preAssembly['dataFim'] != null;

      if (preAssembly['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    if (data['assembly'] != null) {
      final assembly = data['assembly'] as Map<String, dynamic>;
      bool hasData =
          assembly['dataInicio'] != null || assembly['dataFim'] != null;

      if (assembly['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    final finalPhases = data['finalPhases'] as Map<String, dynamic>?;
    if (finalPhases != null) {
      int completedFinalPhases = 0;
      int totalFinalPhases = 0;

      finalPhases.forEach((key, value) {
        if (value is Map && value['isCompleted'] == true) {
          completedFinalPhases++;
        }
        totalFinalPhases++;
      });

      if (totalFinalPhases > 0) {
        progress += (completedFinalPhases / totalFinalPhases) * 20;
      }
    }

    return progress.clamp(0.0, 100.0);
  }

  String _getAutoStatus() {
    if (_progresso == 0) return 'Pendente';
    if (_progresso >= 100) return 'Concluído';
    return 'Em Progresso';
  }

  List<Map<String, dynamic>> _aggregateNotes(Map<String, dynamic> data) {
    List<Map<String, dynamic>> notes = [];

    final phaseConfig = {
      'reception': {'icon': '📦', 'name': 'reception'},
      'preparation': {'icon': '📋', 'name': 'preparation'},
      'preAssembly': {'icon': '🔧', 'name': 'pre_assembly'},
      'assembly': {'icon': '🏗️', 'name': 'assembly'},
      'electricalWorks': {'icon': '⚡', 'name': 'electricalWorks'},
      'mechanicalWorks': {'icon': '🔩', 'name': 'mechanicalWorks'},
    };

    phaseConfig.forEach((phaseKey, config) {
      if (data[phaseKey] != null) {
        final phaseData = data[phaseKey] as Map<String, dynamic>;

        if (phaseData['observacoes'] != null &&
            phaseData['observacoes'].toString().trim().isNotEmpty) {
          DateTime? date;
          if (phaseData['dataFim'] != null) {
            date = (phaseData['dataFim'] as Timestamp).toDate();
          } else if (phaseData['dataInicio'] != null) {
            date = (phaseData['dataInicio'] as Timestamp).toDate();
          } else {
            date = DateTime.now();
          }

          notes.add({
            'phase': config['name'],
            'phaseIcon': config['icon'],
            'date': date,
            'text': phaseData['observacoes'],
          });
        }
      }
    });

    notes.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return notes;
  }

  List<String> _aggregatePhotos(Map<String, dynamic> data) {
    List<String> photos = [];

    final phases = [
      'reception',
      'preparation',
      'preAssembly',
      'assembly',
      'electricalWorks',
      'mechanicalWorks',
    ];

    for (var phase in phases) {
      if (data[phase] != null) {
        final phaseData = data[phase] as Map<String, dynamic>;

        if (phaseData['fotos'] != null && phaseData['fotos'] is List) {
          photos.addAll(List<String>.from(phaseData['fotos']));
        }
      }
    }

    return photos;
  }

  Future<void> _updateComponenteInAsBuilt() async {
    try {
      final componenteService = ref.read(componenteServiceProvider);

      await componenteService.updateComponente(widget.componente.id, {
        'progresso': _progresso,
        'status': _status,
        'vui': _vuiController.text.trim().isEmpty
            ? null
            : _vuiController.text.trim(),
        'itemNumber': _itemNumberController.text.trim().isEmpty
            ? null
            : _itemNumberController.text.trim(),
        'serialNumber': _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
      });

      final turbinaService = ref.read(turbinaServiceProvider);
      await turbinaService
          .atualizarProgressoTurbina(widget.componente.turbinaId);

      debugPrint('✅ Componente atualizado no As-Built');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar componente: $e');
    }
  }

  @override
  void dispose() {
    _installationListener?.cancel();
    _itemNumberController.dispose();
    _serialNumberController.dispose();
    _vuiController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final isNA = _status == 'N/A';
    final theme = Theme.of(context);
    final dialogBackground =
        theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface;
    final outlineColor = AppColors.adaptiveOutline(context);

    return Dialog(
      backgroundColor: dialogBackground,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            _buildHeader(t),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.canEdit)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.warningOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                AppColors.warningOrange.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.visibility,
                              color: AppColors.warningOrange,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Modo leitura — sem permissão para editar',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warningOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_isSyncingFromInstallation)
                      Builder(
                        builder: (context) {
                          final outlineColor =
                              AppColors.adaptiveOutline(context);
                          final panelColor =
                              AppColors.adaptivePanelSurface(context);
                          final primaryText =
                              AppColors.adaptivePrimaryText(context);

                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: panelColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: outlineColor),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t.translate('syncing_from_installation'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    _buildNAToggle(t, isNA),
                    if (!isNA) ...[
                      const SizedBox(height: 16),
                      _buildProgressSection(t),
                      const SizedBox(height: 16),
                      _buildStatusDropdown(t),
                      const SizedBox(height: 16),
                      _buildAutoFilledFields(t),
                      const SizedBox(height: 16),
                      _buildAggregatedNotes(t),
                      const SizedBox(height: 16),
                      _buildPhotosGallery(t),
                      const SizedBox(height: 16),
                      _buildObservationsField(t),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(t, isNA),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TODOS OS WIDGETS DO DIALOG (CÓDIGO ORIGINAL MANTIDO)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(TranslationHelper t) {
    final outlineColor = AppColors.adaptiveOutline(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        border: Border(bottom: BorderSide(color: outlineColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.componente.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.componente.categoria,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_canBlock() && widget.canEdit)
            IconButton(
              icon: Icon(_isBlocked ? Icons.lock : Icons.lock_open,
                  color: Colors.white),
              onPressed: () => _showBlockDialog(t),
              tooltip:
                  _isBlocked ? t.translate('unblock') : t.translate('block'),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNAToggle(TranslationHelper t, bool isNA) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    final mutedText = AppColors.adaptiveMutedText(context);
    return Card(
      elevation: 0,
      color: isNA
          ? (isDark
              ? AppColors.glassSurfaceDark
              : AppColors.mediumGray.withValues(alpha: 0.1))
          : (isDark
              ? AppColors.glassSurfaceDark
              : AppColors.accentTeal.withValues(alpha: 0.1)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outlineColor, width: 1),
      ),
      child: SwitchListTile(
        title: Text(
          t.translate('not_applicable'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        subtitle: Text(
          isNA
              ? t.translate('component_not_used')
              : t.translate('mark_if_not_installed'),
          style: TextStyle(fontSize: 12, color: secondaryText),
        ),
        value: isNA,
        onChanged: !_canInteract
            ? null
            : (value) {
                setState(() {
                  if (value) {
                    _status = 'N/A';
                    _aplicavel = false;
                    _progresso = 0;
                  } else {
                    _status = 'Pendente';
                    _aplicavel = true;
                  }
                });
              },
        activeThumbColor: mutedText,
      ),
    );
  }

  Widget _buildProgressSection(TranslationHelper t) {
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final trackColor = AppColors.adaptiveProgressTrack(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.translate('progress'),
              style: TextStyle(
                fontSize: 14,
                color: secondaryText,
              ),
            ),
            Text(
              '${_progresso.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(20, (index) {
            final isFilled = index < (_progresso / 5).round();
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isFilled ? AppColors.primaryBlue : trackColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _progresso,
          min: 0,
          max: 100,
          divisions: 20,
          label: '${_progresso.toStringAsFixed(0)}%',
          onChanged: !_canInteract
              ? null
              : (value) {
                  setState(() {
                    _progresso = value;
                    if (value >= 100) {
                      _status = 'Concluído';
                    } else if (value > 0) {
                      _status = 'Em Progresso';
                    } else {
                      _status = 'Pendente';
                    }
                  });
                },
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(TranslationHelper t) {
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    final statuses = [
      {'value': 'Pendente', 'color': AppColors.mediumGray},
      {'value': 'Em Progresso', 'color': AppColors.warningOrange},
      {'value': 'Concluído', 'color': AppColors.successGreen},
      {'value': 'Bloqueado', 'color': Colors.red},
      {'value': 'N/A', 'color': AppColors.mediumGray},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('status'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.adaptiveCardSurface(context),
            border: Border.all(color: outlineColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: statuses.any((s) => s['value'] == _status)
                  ? _status
                  : 'Pendente',
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: secondaryText),
              dropdownColor: AppColors.adaptiveCardSurface(context),
              style: TextStyle(color: primaryText),
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status['value'] as String,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: status['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        t.translate('component_status_${status['value']}'),
                        style: TextStyle(color: primaryText),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: !_canInteract
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
            ),
          ),
        ),
        if (_isBlocked) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF5A2529).withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF8F8F)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: Color(0xFFFF8F8F), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.translate('blocked_by')}: $_blockedBy',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFB4B4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _blockReason ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFFFFD7D7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoFilledFields(TranslationHelper t) {
    return Column(
      children: [
        _buildReadOnlyField(
          label: 'VUI / Unit ID',
          controller: _vuiController,
          icon: Icons.qr_code,
          t: t,
        ),
        const SizedBox(height: 12),
        _buildReadOnlyField(
          label: t.translate('item_number'),
          controller: _itemNumberController,
          icon: Icons.numbers,
          t: t,
        ),
        const SizedBox(height: 12),
        _buildReadOnlyField(
          label: t.translate('serial_number'),
          controller: _serialNumberController,
          icon: Icons.tag,
          t: t,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required TranslationHelper t,
  }) {
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          style: TextStyle(color: primaryText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            suffixIcon: const Icon(Icons.sync, color: AppColors.successGreen),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: outlineColor),
            ),
            filled: true,
            fillColor: AppColors.adaptiveCardSurface(context),
            hintStyle: TextStyle(color: secondaryText),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAggregatedNotes(TranslationHelper t) {
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final cardColor = AppColors.adaptiveCardSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('notes'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 12),
        if (_aggregatedNotes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: outlineColor),
            ),
            child: Center(
              child: Text(
                t.translate('no_notes'),
                style: TextStyle(color: secondaryText),
              ),
            ),
          )
        else
          ..._aggregatedNotes.map((note) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border.all(color: outlineColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        note['phaseIcon'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.translate(note['phase']),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(note['date']),
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note['text'],
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPhotosGallery(TranslationHelper t) {
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final cardColor = AppColors.adaptiveCardSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📸 ${t.translate('photos')} (${_photos.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            TextButton.icon(
              onPressed: _canInteract ? _addPhoto : null,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(t.translate('add')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_photos.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: outlineColor),
            ),
            child: Center(
              child: Text(
                t.translate('no_photos'),
                style: TextStyle(color: secondaryText),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showPhotoFullscreen(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: outlineColor),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Icon(Icons.image, size: 40, color: secondaryText),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '📦',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildObservationsField(TranslationHelper t) {
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    return TextField(
      controller: _observacoesController,
      style: TextStyle(color: primaryText),
      decoration: InputDecoration(
        labelText: t.translate('observations'),
        labelStyle: TextStyle(color: secondaryText),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
        prefixIcon: Icon(Icons.notes, color: secondaryText),
        hintText: t.translate('add_notes_optional'),
        hintStyle: TextStyle(color: secondaryText),
        filled: true,
        fillColor: AppColors.adaptiveCardSurface(context),
      ),
      maxLines: 3,
      enabled: _canInteract,
    );
  }

  Widget _buildFooter(TranslationHelper t, bool isNA) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.glassSurfaceStrongDark
            : AppColors.glassSurfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.adaptiveOutline(context)),
        ),
      ),
      child: Row(
        children: [
          if (!isNA &&
              widget.componente.status != 'Substituído' &&
              _canInteract)
            TextButton.icon(
              onPressed: _isLoading || _isBlocked
                  ? null
                  : () => _showReplaceDialog(context, t),
              icon:
                  const Icon(Icons.swap_horiz, color: AppColors.warningOrange),
              label: Text(
                t.translate('replace'),
                style: const TextStyle(color: AppColors.warningOrange),
              ),
            ),
          const Spacer(),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          if (widget.canEdit) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading || _isBlocked ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t.translate('save')),
            ),
          ],
        ],
      ),
    );
  }

  final PhotoService _photoService = PhotoService();

  void _addPhoto() async {
    if (!_canInteract) return;

    try {
      debugPrint('🔵 _addPhoto START');

      final String? turbinaId = ref.read(selectedTurbinaIdProvider);
      if (turbinaId == null) {
        debugPrint('❌ turbinaId null em _addPhoto');
        return;
      }

      debugPrint(
          '🔵 _addPhoto -> turbinaId=$turbinaId componenteId=$_componenteId');

      final url = await _photoService.pickAndUploadPhotoForFase(
        turbinaId: turbinaId,
        componenteId: _componenteId,
        tipoFase: 'as_built',
      );

      debugPrint('🔵 _addPhoto -> url retornada: $url');

      if (url == null) {
        debugPrint('⚠️ _addPhoto: url null, não vou atualizar Firestore/UI');
        return;
      }

      setState(() {
        _photos.add(url);
      });

      final installationRef = FirebaseFirestore.instance
          .collection('installation_data')
          .doc(turbinaId)
          .collection('components')
          .doc(_componenteId);
      await installationRef.update({
        'asBuiltPhotos': FieldValue.arrayUnion([url]),
      });
    } catch (e, st) {
      debugPrint('❌ ERRO em _addPhoto: $e');
      debugPrint(st.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao adicionar foto: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showPhotoFullscreen(int index) {
    showLiquidDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 100, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Photo ${index + 1}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog(TranslationHelper t) {
    final reasonController = TextEditingController();
    final primaryText = AppColors.adaptivePrimaryText(context);

    showLiquidDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            _isBlocked
                ? t.translate('unblock_component')
                : t.translate('block_component'),
            style: TextStyle(color: primaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isBlocked) ...[
              Text(
                t.translate('block_reason_required'),
                style: TextStyle(color: primaryText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: t.translate('enter_block_reason'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ] else ...[
              Text(
                t.translate('confirm_unblock'),
                style: TextStyle(color: primaryText),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_isBlocked && reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.translate('reason_required'))),
                );
                return;
              }

              setState(() {
                _isBlocked = !_isBlocked;
                if (_isBlocked) {
                  _blockReason = reasonController.text;
                  _blockedBy = 'João Silva';
                  _status = 'Bloqueado';
                } else {
                  _blockReason = null;
                  _blockedBy = null;
                  _status = 'Pendente';
                }
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBlocked ? AppColors.successGreen : Colors.red,
            ),
            child: Text(
                _isBlocked ? t.translate('unblock') : t.translate('block')),
          ),
        ],
      ),
    );
  }

  bool _canBlock() {
    return true;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _handleSave() async {
    final t = TranslationHelper.of(context);
    setState(() => _isLoading = true);

    try {
      final componenteService = ref.read(componenteServiceProvider);
      final turbinaService = ref.read(turbinaServiceProvider);

      await componenteService.updateComponente(widget.componente.id, {
        'progresso': _progresso,
        'status': _status,
        'aplicavel': _aplicavel,
        'itemNumber': _itemNumberController.text.trim().isEmpty
            ? null
            : _itemNumberController.text.trim(),
        'serialNumber': _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
        'vui': _vuiController.text.trim().isEmpty
            ? null
            : _vuiController.text.trim(),
        'observacoes': _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      });

      await turbinaService.atualizarProgressoTurbina(
        widget.componente.turbinaId,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('component_updated_success')),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.translate('error')}: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showReplaceDialog(BuildContext context, TranslationHelper t) {
    final reasonController = TextEditingController();
    final notesController = TextEditingController();
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final surfaceColor = AppColors.adaptiveCardSurface(context);
    final outlineColor = AppColors.adaptiveOutline(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    showLiquidDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final dialogNavigator = Navigator.of(dialogContext);
            final pageNavigator = Navigator.of(context);

            Future<void> submitReplacement() async {
              if (isSubmitting) {
                return;
              }

              final reason = reasonController.text.trim();
              final notes = notesController.text.trim();

              if (reason.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(t.translate('reason_for_replacement')),
                    backgroundColor: AppColors.warningOrange,
                  ),
                );
                return;
              }

              setDialogState(() => isSubmitting = true);

              try {
                final userId = ref.read(currentUserIdProvider);
                if (userId == null || userId.isEmpty) {
                  throw Exception(t.translate('error'));
                }

                final componenteService = ref.read(componenteServiceProvider);
                final turbinaService = ref.read(turbinaServiceProvider);

                final newComponentId =
                    await componenteService.substituirComponente(
                  componenteAntigoId: widget.componente.id,
                  razao: reason,
                  observacoes: notes,
                  userId: userId,
                );

                await turbinaService.atualizarProgressoTurbina(
                  widget.componente.turbinaId,
                );

                final newComponentDoc = await FirebaseFirestore.instance
                    .collection('componentes')
                    .doc(newComponentId)
                    .get();

                if (!newComponentDoc.exists) {
                  throw Exception(t.translate('component_replace_error'));
                }

                final newComponent = Componente.fromFirestore(newComponentDoc);

                if (!mounted) {
                  return;
                }

                dialogNavigator.pop();
                pageNavigator.pop();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!rootNavigator.context.mounted) {
                    return;
                  }

                  showLiquidDialog(
                    context: rootNavigator.context,
                    builder: (context) => EditComponenteDialog(
                      componente: newComponent,
                      canEdit: widget.canEdit,
                    ),
                  );

                  final messenger =
                      ScaffoldMessenger.maybeOf(rootNavigator.context);
                  messenger?.showSnackBar(
                    SnackBar(
                      content: Text(t.translate('component_replaced_success')),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                });
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${t.translate('component_replace_error')}: $e',
                      ),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              } finally {
                if (dialogContext.mounted) {
                  setDialogState(() => isSubmitting = false);
                }
              }
            }

            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: outlineColor),
              ),
              title: Text(
                t.translate('replace_dialog_title'),
                style: TextStyle(color: primaryText),
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.translate('component_to_replace'),
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: outlineColor),
                        ),
                        child: Text(
                          widget.componente.nome,
                          style: TextStyle(
                            color: primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: reasonController,
                        enabled: !isSubmitting,
                        style: TextStyle(color: primaryText),
                        decoration: InputDecoration(
                          labelText: t.translate('reason_for_replacement'),
                          hintText: t.translate('explain_replacement'),
                          labelStyle: TextStyle(color: secondaryText),
                          hintStyle: TextStyle(color: secondaryText),
                          filled: true,
                          fillColor: surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: outlineColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesController,
                        enabled: !isSubmitting,
                        style: TextStyle(color: primaryText),
                        decoration: InputDecoration(
                          labelText: t.translate('replacement_notes'),
                          hintText: t.translate('add_notes_optional'),
                          labelStyle: TextStyle(color: secondaryText),
                          hintStyle: TextStyle(color: secondaryText),
                          filled: true,
                          fillColor: surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: outlineColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AppColors.warningOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AppColors.warningOrange.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          t.translate('replacement_warning'),
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(t.translate('cancel')),
                ),
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : submitReplacement,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.swap_horiz),
                  label: Text(t.translate('replace')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
