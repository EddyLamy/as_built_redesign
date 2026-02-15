// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedProjectId)
final selectedProjectIdProvider = SelectedProjectIdProvider._();

final class SelectedProjectIdProvider
    extends $NotifierProvider<SelectedProjectId, String?> {
  SelectedProjectIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedProjectIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedProjectIdHash();

  @$internal
  @override
  SelectedProjectId create() => SelectedProjectId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedProjectIdHash() => r'1c7dd840bc81e6faf67846ffc51112ee451cab5f';

abstract class _$SelectedProjectId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedTurbinaId)
final selectedTurbinaIdProvider = SelectedTurbinaIdProvider._();

final class SelectedTurbinaIdProvider
    extends $NotifierProvider<SelectedTurbinaId, String?> {
  SelectedTurbinaIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedTurbinaIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedTurbinaIdHash();

  @$internal
  @override
  SelectedTurbinaId create() => SelectedTurbinaId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedTurbinaIdHash() => r'33dd837ae6421cde3ba133c0b3cb861eb53bc8d8';

abstract class _$SelectedTurbinaId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
