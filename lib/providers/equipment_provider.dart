// ══════════════════════════════════════════════════════════════
// EQUIPMENT PROVIDER
// lib/providers/equipment_provider.dart
// ══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment.dart';
import '../services/equipment_service.dart';
import 'app_providers.dart';

// ════════════════════════════════════════════════════════════
// SERVICE PROVIDER
// ════════════════════════════════════════════════════════════

final equipmentServiceProvider = Provider<EquipmentService>((ref) {
  return EquipmentService();
});

// ════════════════════════════════════════════════════════════
// STREAM PROVIDER - Todos os equipamentos
// ════════════════════════════════════════════════════════════

final equipmentStreamProvider = StreamProvider<List<Equipment>>((ref) {
  final service = ref.watch(equipmentServiceProvider);
  final projectId = ref.watch(accessibleSelectedProjectIdProvider);

  if (projectId == null || projectId.isEmpty) {
    return Stream.value(const <Equipment>[]);
  }

  return service.getEquipmentStream(projectId);
});

// ════════════════════════════════════════════════════════════
// STREAM PROVIDER - Equipamento por tipo
// ════════════════════════════════════════════════════════════

final equipmentByTypeProvider =
    StreamProvider.family<List<Equipment>, EquipmentType>(
  (ref, type) {
    final service = ref.watch(equipmentServiceProvider);
    final projectId = ref.watch(accessibleSelectedProjectIdProvider);

    if (projectId == null || projectId.isEmpty) {
      return Stream.value(const <Equipment>[]);
    }

    return service.getEquipmentByTypeStream(projectId, type);
  },
);

// ════════════════════════════════════════════════════════════
// FUTURE PROVIDER - Alertas de calibração
// ════════════════════════════════════════════════════════════

final calibrationAlertsProvider =
    FutureProvider<List<CalibrationAlert>>((ref) async {
  final service = ref.watch(equipmentServiceProvider);
  final projectId = ref.watch(accessibleSelectedProjectIdProvider);

  if (projectId == null || projectId.isEmpty) {
    return const <CalibrationAlert>[];
  }

  return await service.getCalibrationAlerts(projectId);
});

// ════════════════════════════════════════════════════════════
// STATE NOTIFIER - Filtros de equipamento
// ════════════════════════════════════════════════════════════

class EquipmentFilters {
  final String searchQuery;
  final EquipmentType? typeFilter;
  final EquipmentStatus? statusFilter;
  final CalibrationFilterType calibrationFilter;

  EquipmentFilters({
    this.searchQuery = '',
    this.typeFilter,
    this.statusFilter,
    this.calibrationFilter = CalibrationFilterType.all,
  });

  EquipmentFilters copyWith({
    String? searchQuery,
    EquipmentType? typeFilter,
    EquipmentStatus? statusFilter,
    CalibrationFilterType? calibrationFilter,
  }) {
    return EquipmentFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      calibrationFilter: calibrationFilter ?? this.calibrationFilter,
    );
  }
}

enum CalibrationFilterType {
  all,
  expiring,
  expired,
}

// ════════════════════════════════════════════════════════════
// NOTIFIER - Filtros (Riverpod 3.x)
// ════════════════════════════════════════════════════════════

class EquipmentFiltersNotifier extends Notifier<EquipmentFilters> {
  @override
  EquipmentFilters build() => EquipmentFilters();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTypeFilter(EquipmentType? type) {
    state = state.copyWith(typeFilter: type);
  }

  void setStatusFilter(EquipmentStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  void setCalibrationFilter(CalibrationFilterType filter) {
    state = state.copyWith(calibrationFilter: filter);
  }

  void clearFilters() {
    state = EquipmentFilters();
  }
}

final equipmentFiltersProvider =
    NotifierProvider<EquipmentFiltersNotifier, EquipmentFilters>(() {
  return EquipmentFiltersNotifier();
});

// ════════════════════════════════════════════════════════════
// COMPUTED PROVIDER - Equipamento filtrado
// ════════════════════════════════════════════════════════════

final filteredEquipmentProvider = Provider<AsyncValue<List<Equipment>>>((ref) {
  final equipmentAsync = ref.watch(equipmentStreamProvider);
  final filters = ref.watch(equipmentFiltersProvider);
  final alertsAsync = ref.watch(calibrationAlertsProvider);

  return equipmentAsync.whenData((equipment) {
    var filtered = equipment;

    // Filtro de pesquisa
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      filtered = filtered.where((eq) {
        return eq.model.toLowerCase().contains(query) ||
            eq.manufacturer.toLowerCase().contains(query) ||
            eq.serialNumber.toLowerCase().contains(query);
      }).toList();
    }

    // Filtro de tipo
    if (filters.typeFilter != null) {
      filtered = filtered.where((eq) => eq.type == filters.typeFilter).toList();
    }

    // Filtro de status
    if (filters.statusFilter != null) {
      filtered =
          filtered.where((eq) => eq.status == filters.statusFilter).toList();
    }

    // Filtro de calibração
    if (filters.calibrationFilter != CalibrationFilterType.all) {
      alertsAsync.whenData((alerts) {
        if (filters.calibrationFilter == CalibrationFilterType.expiring) {
          final expiringIds = alerts
              .where((a) => a.type != CalibrationAlertType.expirado)
              .map((a) => a.equipment.equipmentId)
              .toSet();
          filtered = filtered
              .where((eq) => expiringIds.contains(eq.equipmentId))
              .toList();
        } else if (filters.calibrationFilter == CalibrationFilterType.expired) {
          final expiredIds = alerts
              .where((a) => a.type == CalibrationAlertType.expirado)
              .map((a) => a.equipment.equipmentId)
              .toSet();
          filtered = filtered
              .where((eq) => expiredIds.contains(eq.equipmentId))
              .toList();
        }
      });
    }

    return filtered;
  });
});

// ════════════════════════════════════════════════════════════
// GROUPED PROVIDER - Equipamento agrupado por tipo
// ════════════════════════════════════════════════════════════

final groupedEquipmentProvider =
    Provider<AsyncValue<Map<EquipmentType, List<Equipment>>>>((ref) {
  final filteredAsync = ref.watch(filteredEquipmentProvider);

  return filteredAsync.whenData((equipment) {
    final Map<EquipmentType, List<Equipment>> grouped = {};

    for (final eq in equipment) {
      if (!grouped.containsKey(eq.type)) {
        grouped[eq.type] = [];
      }
      grouped[eq.type]!.add(eq);
    }

    return grouped;
  });
});

// ════════════════════════════════════════════════════════════
// ACTIONS PROVIDER - Ações de equipamento
// ════════════════════════════════════════════════════════════

final equipmentActionsProvider = Provider<EquipmentActions>((ref) {
  final service = ref.watch(equipmentServiceProvider);
  return EquipmentActions(ref, service);
});

class EquipmentActions {
  final Ref _ref;
  final EquipmentService _service;

  EquipmentActions(this._ref, this._service);

  String _getSelectedProjectId() {
    final projectId = _ref.read(accessibleSelectedProjectIdProvider);
    if (projectId == null || projectId.isEmpty) {
      throw Exception('Projeto não selecionado para equipamentos.');
    }
    return projectId;
  }

  Future<bool> addEquipment(Equipment equipment) async {
    final selectedProjectId = _getSelectedProjectId();
    if (equipment.projectId != selectedProjectId) {
      throw Exception('O equipamento deve pertencer ao projeto selecionado.');
    }
    return await _service.addEquipment(equipment);
  }

  Future<bool> updateEquipment(Equipment equipment) async {
    final selectedProjectId = _getSelectedProjectId();
    if (equipment.projectId != selectedProjectId) {
      throw Exception('Só pode atualizar equipamento do projeto selecionado.');
    }
    return await _service.updateEquipment(equipment);
  }

  Future<bool> deleteEquipment(String equipmentId) async {
    final selectedProjectId = _getSelectedProjectId();
    return await _service.deleteEquipment(equipmentId, selectedProjectId);
  }

  Future<bool> addUsageRecord(
    String equipmentId,
    EquipmentUsageRecord record,
  ) async {
    return await _service.addUsageRecord(equipmentId, record);
  }

  Future<bool> updateStatus(
    String equipmentId,
    EquipmentStatus status, {
    String? projectId,
    String? projectName,
  }) async {
    final selectedProjectId = _getSelectedProjectId();
    return await _service.updateEquipmentStatus(
      equipmentId,
      selectedProjectId,
      status,
      usageProjectId: projectId,
      projectName: projectName,
    );
  }
}
