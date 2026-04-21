import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/turbina.dart';
import '../../providers/permission_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/enhanced_drawer.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import './turbine_installation_details_screen.dart';

// ============================================================================
// 🏗️ MÓDULO DE INSTALAÇÃO - CONECTADO AO FIREBASE
// ============================================================================

// Provider que filtra turbinas pelo projecto seleccionado
final turbinasInstallationProvider =
    StreamProvider.family<List<Turbina>, String>((ref, projectId) {
  return FirebaseFirestore.instance
      .collection('turbinas')
      .where('projectId', isEqualTo: projectId)
      .orderBy('nome', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Turbina.fromFirestore(doc)).toList();
  });
});

class InstallationScreen extends ConsumerStatefulWidget {
  const InstallationScreen({super.key});

  @override
  ConsumerState<InstallationScreen> createState() => _InstallationScreenState();
}

class _InstallationScreenState extends ConsumerState<InstallationScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final currentModule = ref.watch(currentModuleProvider);
    if (currentModule != AppModule.installation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(currentModuleProvider.notifier)
            .setModule(AppModule.installation);
      });
    }

    // Verificar permissões para o projeto selecionado
    final projectId = ref.watch(accessibleSelectedProjectIdProvider);
    final permissions = ref.watch(permissionProvider(projectId));
    final appUserAsync = ref.watch(currentAppUserProvider); // DEBUG

    // DEBUG — remover depois
    debugPrint('🔐 INSTALLATION GUARD DEBUG:');
    debugPrint('   projectId: $projectId');
    debugPrint('   appUserAsync.isLoading: ${appUserAsync.isLoading}');
    debugPrint('   appUserAsync.hasValue: ${appUserAsync.hasValue}');
    debugPrint('   appUser: ${appUserAsync.asData?.value?.name}');
    debugPrint(
        '   appUser globalRole: ${appUserAsync.asData?.value?.globalRole}');
    debugPrint('   permissions.isLoading: ${permissions.isLoading}');
    debugPrint('   permissions.isGlobalAdmin: ${permissions.isGlobalAdmin}');
    debugPrint(
        '   permissions.hasSomeProjectAccess: ${permissions.hasSomeProjectAccess}');

    // Visitor e acima podem ver a instalação, mas só SS+ pode editar
    // Aguardar carregamento antes de bloquear
    if (permissions.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!permissions.hasSomeProjectAccess && projectId != null) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: DashboardShortcutTitle(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(Icons.construction, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(t.translate('installation_module')),
              ],
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 72,
                color: AppColors.lightGray,
              ),
              const SizedBox(height: 16),
              Text(
                'Não tens acesso a este projeto.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.mediumGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contacta o teu Project Manager.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mediumGray,
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Icon(Icons.construction, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(t.translate('installation_module')),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ══════════════════════════════════════════════════════════════
          // 🔍 BARRA DE PESQUISA
          // ══════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.translate('search_turbines'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // ══════════════════════════════════════════════════════════════
          // 🏗️ CARDS DAS TURBINAS
          // ══════════════════════════════════════════════════════════════
          Expanded(
            child: _buildTurbinesList(
                permissions.canManageInstallation, projectId ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildTurbinesList(bool canEdit, String projectId) {
    final t = TranslationHelper.of(context);
    final turbinasAsync = ref.watch(turbinasInstallationProvider(projectId));

    return turbinasAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              t.translate('loading_turbines'),
              style: const TextStyle(color: AppColors.mediumGray),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.errorRed),
            const SizedBox(height: 16),
            Text(
              t.translate('error_loading_turbines'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: AppColors.mediumGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(turbinasInstallationProvider);
              },
              icon: const Icon(Icons.refresh),
              label: Text(t.translate('retry')),
            ),
          ],
        ),
      ),
      data: (turbinas) {
        final filteredTurbines = turbinas.where((turbina) {
          final turbineName = turbina.nome.toLowerCase();
          return turbineName.contains(_searchQuery);
        }).toList();

        if (filteredTurbines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty
                      ? Icons.wind_power_outlined
                      : Icons.search_off,
                  size: 64,
                  color: AppColors.mediumGray,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? t.translate('no_turbines_created')
                      : t.translate('no_turbines_found'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? t.translate('create_turbines_in_asbuilt')
                      : t.translate('try_adjusting_search'),
                  style: const TextStyle(color: AppColors.mediumGray),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              const minCardWidth = 150.0;
              final crossAxisCount =
                  ((constraints.maxWidth + spacing) / (minCardWidth + spacing))
                      .floor()
                      .clamp(2, 6);

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  mainAxisExtent: 132,
                ),
                itemCount: filteredTurbines.length,
                itemBuilder: (context, index) {
                  final turbina = filteredTurbines[index];
                  return _buildTurbineCard(turbina, canEdit);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTurbineCard(dynamic turbina, bool canEdit) {
    final progress = (turbina.progresso ?? 0.0) / 100.0;
    final progressPercent = (progress * 100).toInt();

    Color progressColor;
    if (progress >= 0.8) {
      progressColor = AppColors.successGreen;
    } else if (progress >= 0.3) {
      progressColor = AppColors.warningOrange;
    } else {
      progressColor = AppColors.mediumGray;
    }

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _openTurbineDetails(turbina, canEdit),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.wind_power,
                      color: progressColor,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: const SizedBox.shrink(),
                  ),
                  if (!canEdit)
                    Tooltip(
                      message: 'Modo leitura',
                      child: const Icon(
                        Icons.visibility,
                        size: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                ],
              ),
              const Spacer(flex: 2),
              Text(
                turbina.nome,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _getTurbinaModelo(turbina),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: progressColor.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$progressPercent%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _getTurbinaModelo(dynamic turbina) {
    try {
      if (turbina.modelo != null) return turbina.modelo;
    } catch (_) {
      // fallback para shape alternativo
    }
    try {
      final model = (turbina as dynamic).model;
      if (model != null) return model;
    } catch (_) {
      // fallback para valor default
    }
    return 'V150';
  }

  void _openTurbineDetails(dynamic turbina, bool canEdit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TurbineInstallationDetailsScreen(
          turbineId: turbina.id,
          turbineName: turbina.nome,
          turbineModel: _getTurbinaModelo(turbina),
          turbineSequence: 1,
          numberOfMiddleSections: turbina.numberOfMiddleSections ?? 3,
        ),
      ),
    );
  }
}
