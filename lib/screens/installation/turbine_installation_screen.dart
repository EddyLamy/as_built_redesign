import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/installation/componente_tab.dart';
import '../../widgets/installation/timeline_tab.dart';

class TurbineInstallationScreen extends ConsumerStatefulWidget {
  final String turbinaId;
  final String turbinaNome;
  final String projectId;
  final int numberOfMiddleSections;

  const TurbineInstallationScreen({
    super.key,
    required this.turbinaId,
    required this.turbinaNome,
    required this.projectId,
    required this.numberOfMiddleSections,
  });

  @override
  ConsumerState<TurbineInstallationScreen> createState() =>
      _TurbineInstallationScreenState();
}

class _TurbineInstallationScreenState
    extends ConsumerState<TurbineInstallationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turbinaNome),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Componentes'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ ComponentesTab só recebe turbinaId
          ComponentesTab(
            turbinaId: widget.turbinaId,
          ),
          TimelineTab(turbinaId: widget.turbinaId),
        ],
      ),
    );
  }
}
