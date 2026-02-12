import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/turbina.dart';
import './turbine_installation_details_screen.dart';

// ============================================================================
// 🏗️ MÓDULO DE INSTALAÇÃO - CONECTADO AO FIREBASE
// ============================================================================

// ══════════════════════════════════════════════════════════════════════════
// 🌪️ PROVIDER TEMPORÁRIO: LISTA DE TURBINAS
// TODO: Mover para app_providers.dart depois
// ══════════════════════════════════════════════════════════════════════════
final turbinasProvider = StreamProvider<List<Turbina>>((ref) {
  return FirebaseFirestore.instance
      .collection('turbinas')
      .orderBy('nome', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Turbina.fromFirestore(doc);
    }).toList();
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.construction, color: Colors.white),
            const SizedBox(width: 12),
            Text(t.translate('installation_module')),
          ],
        ),
      ),
      body: Column(
        children: [
          // ════════════════════════════════════════════════════════════════
          // 🔍 BARRA DE PESQUISA
          // ════════════════════════════════════════════════════════════════
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

          // ════════════════════════════════════════════════════════════════
          // 🏗️ CARDS DAS TURBINAS (DADOS REAIS DO FIREBASE)
          // ════════════════════════════════════════════════════════════════
          Expanded(
            child: _buildTurbinesList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🏗️ WIDGET: LISTA DE TURBINAS (CONECTADO AO FIREBASE)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTurbinesList() {
    final t = TranslationHelper.of(context);

    // ════════════════════════════════════════════════════════════════════════
    // 📊 DADOS REAIS DO FIREBASE
    // ════════════════════════════════════════════════════════════════════════
    final turbinasAsync = ref.watch(turbinasProvider);

    return turbinasAsync.when(
      // ────────────────────────────────────────────────────────────────────
      // ⏳ LOADING
      // ────────────────────────────────────────────────────────────────────
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

      // ────────────────────────────────────────────────────────────────────
      // ❌ ERROR
      // ────────────────────────────────────────────────────────────────────
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
                ref.invalidate(turbinasProvider);
              },
              icon: const Icon(Icons.refresh),
              label: Text(t.translate('retry')),
            ),
          ],
        ),
      ),

      // ────────────────────────────────────────────────────────────────────
      // ✅ DATA
      // ────────────────────────────────────────────────────────────────────
      data: (turbinas) {
        // Filtrar por pesquisa
        final filteredTurbines = turbinas.where((turbina) {
          final turbineName = turbina.nome.toLowerCase();
          return turbineName.contains(_searchQuery);
        }).toList();

        // Caso vazio
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

        // Grid de turbinas
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: filteredTurbines.length,
            itemBuilder: (context, index) {
              final turbina = filteredTurbines[index];
              return _buildTurbineCard(turbina);
            },
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 WIDGET: CARD DE TURBINA (COM DADOS REAIS)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTurbineCard(dynamic turbina) {
    final t = TranslationHelper.of(context);

    // Progresso da instalação (pode vir do As-Built ou calcular das fases)
    final progress = (turbina.progresso ?? 0.0) / 100.0;
    final progressPercent = (progress * 100).toInt();

    // Cor baseada no progresso
    Color progressColor;
    if (progress >= 0.8) {
      progressColor = AppColors.successGreen;
    } else if (progress >= 0.3) {
      progressColor = AppColors.warningOrange;
    } else {
      progressColor = AppColors.mediumGray;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openTurbineDetails(turbina),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────────────────────────────────────────────────────────
              // HEADER: Ícone + Nome
              // ────────────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.wind_power,
                      color: progressColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turbina.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getTurbinaModelo(turbina),
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

              const Spacer(),

              // ────────────────────────────────────────────────────────────
              // PROGRESSO
              // ────────────────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.translate('progress'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.borderGray,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ────────────────────────────────────────────────────────────
              // STATUS
              // ────────────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: progressColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      turbina.status ?? t.translate('pending'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 HELPER: OBTER MODELO DA TURBINA (SAFE)
  // ══════════════════════════════════════════════════════════════════════════
  String _getTurbinaModelo(dynamic turbina) {
    // Tentar obter modelo de várias formas
    try {
      // Se tem getter 'modelo'
      if (turbina.modelo != null) return turbina.modelo;
    } catch (e) {
      // Ignorar se não tiver
    }

    try {
      // Se tem campo 'model'
      final model = (turbina as dynamic).model;
      if (model != null) return model;
    } catch (e) {
      // Ignorar
    }

    // Padrão
    return 'V150';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🚀 NAVEGAÇÃO: ABRIR DETALHES DA TURBINA (COM FASES)
  // ══════════════════════════════════════════════════════════════════════════
  void _openTurbineDetails(dynamic turbina) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TurbineInstallationDetailsScreen(
          turbineId: turbina.id,
          turbineName: turbina.nome,
          turbineModel: _getTurbinaModelo(turbina),
          turbineSequence: 1, // TODO: Adicionar campo sequence na Turbina
          numberOfMiddleSections: turbina.numberOfMiddleSections ?? 3,
        ),
      ),
    );
  }
}
