// lib/screens/admin/migration_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';

/// Dashboard de Migração - Para Admin e Site Managers
///
/// Permite:
/// - Ver status de migração por projeto
/// - Migrar projetos completos com um clique
/// - Monitorizar progresso em tempo real
class MigrationDashboardScreen extends ConsumerStatefulWidget {
  const MigrationDashboardScreen({super.key});

  @override
  ConsumerState<MigrationDashboardScreen> createState() =>
      _MigrationDashboardScreenState();
}

class _MigrationDashboardScreenState
    extends ConsumerState<MigrationDashboardScreen> {
  Map<String, Map<String, dynamic>> _projectsStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjectsStatus();
  }

  Future<void> _loadProjectsStatus() async {
    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;

      // Buscar todos os projetos
      final projectsSnapshot = await firestore.collection('projects').get();

      final Map<String, Map<String, dynamic>> status = {};

      for (var projectDoc in projectsSnapshot.docs) {
        final projectId = projectDoc.id;
        final projectName = projectDoc.data()['nome'] ?? 'Projeto sem nome';

        // Contar componentes
        final componentsSnapshot = await firestore
            .collection('componentes')
            .where('projectId', isEqualTo: projectId)
            .get();

        final total = componentsSnapshot.docs.length;
        final migrated = componentsSnapshot.docs
            .where((doc) => doc.data()['hardcodedId'] != null)
            .length;

        status[projectId] = {
          'name': projectName,
          'total': total,
          'migrated': migrated,
          'pending': total - migrated,
          'percentage': total > 0 ? (migrated / total * 100) : 0,
        };
      }

      setState(() {
        _projectsStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar status: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Migration Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProjectsStatus,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_projectsStatus.isEmpty) {
      return Center(
        child: Text('No projects found'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _projectsStatus.length,
      itemBuilder: (context, index) {
        final projectId = _projectsStatus.keys.elementAt(index);
        final status = _projectsStatus[projectId]!;

        return _buildProjectCard(projectId, status);
      },
    );
  }

  Widget _buildProjectCard(String projectId, Map<String, dynamic> status) {
    final percentage = status['percentage'] as double;
    final isComplete = percentage >= 100;
    final isPending = status['pending'] > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${status['migrated']}/${status['total']} componentes migrados',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isComplete)
                  Icon(Icons.check_circle,
                      color: AppColors.successGreen, size: 32)
                else
                  Icon(Icons.pending, color: AppColors.warningOrange, size: 32),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation(
                isComplete ? AppColors.successGreen : AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isComplete
                        ? AppColors.successGreen
                        : AppColors.primaryBlue,
                  ),
                ),
                if (isPending)
                  ElevatedButton.icon(
                    onPressed: () => _migrateProject(projectId, status['name']),
                    icon: Icon(Icons.sync, size: 18),
                    label: Text('Migrate ${status['pending']} components'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _migrateProject(String projectId, String projectName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Migrate Project'),
        content: Text(
          'This will migrate all components in "$projectName".\n\nContinue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Migrate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar progresso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Migrating components...'),
          ],
        ),
      ),
    );

    try {
      final componenteService = ref.read(componenteServiceProvider);
      await componenteService.migrateComponentesForProject(projectId);

      Navigator.pop(context); // Fechar progresso

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Project migrated successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      _loadProjectsStatus(); // Recarregar
    } catch (e) {
      Navigator.pop(context); // Fechar progresso

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}
