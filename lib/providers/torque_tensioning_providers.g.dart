// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torque_tensioning_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected category filter - TODO: Migrate to local widget state

@ProviderFor(SelectedCategoria)
final selectedCategoriaProvider = SelectedCategoriaProvider._();

/// Selected category filter - TODO: Migrate to local widget state
final class SelectedCategoriaProvider
    extends $NotifierProvider<SelectedCategoria, String?> {
  /// Selected category filter - TODO: Migrate to local widget state
  SelectedCategoriaProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCategoriaProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoriaHash();

  @$internal
  @override
  SelectedCategoria create() => SelectedCategoria();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedCategoriaHash() => r'75dc849272daf180a36085ab6ac773e93c477a14';

/// Selected category filter - TODO: Migrate to local widget state

abstract class _$SelectedCategoria extends $Notifier<String?> {
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

/// Selected connection for editing - TODO: Migrate to local widget state

@ProviderFor(SelectedConexao)
final selectedConexaoProvider = SelectedConexaoProvider._();

/// Selected connection for editing - TODO: Migrate to local widget state
final class SelectedConexaoProvider
    extends $NotifierProvider<SelectedConexao, TorqueTensioning?> {
  /// Selected connection for editing - TODO: Migrate to local widget state
  SelectedConexaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedConexaoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedConexaoHash();

  @$internal
  @override
  SelectedConexao create() => SelectedConexao();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TorqueTensioning? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TorqueTensioning?>(value),
    );
  }
}

String _$selectedConexaoHash() => r'ea80168e071f1204bd887c9e4cddf0b2ba4077ce';

/// Selected connection for editing - TODO: Migrate to local widget state

abstract class _$SelectedConexao extends $Notifier<TorqueTensioning?> {
  TorqueTensioning? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TorqueTensioning?, TorqueTensioning?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TorqueTensioning?, TorqueTensioning?>,
        TorqueTensioning?,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Loading state for operations - TODO: Migrate to local widget state

@ProviderFor(IsLoadingConexao)
final isLoadingConexaoProvider = IsLoadingConexaoProvider._();

/// Loading state for operations - TODO: Migrate to local widget state
final class IsLoadingConexaoProvider
    extends $NotifierProvider<IsLoadingConexao, bool> {
  /// Loading state for operations - TODO: Migrate to local widget state
  IsLoadingConexaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isLoadingConexaoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isLoadingConexaoHash();

  @$internal
  @override
  IsLoadingConexao create() => IsLoadingConexao();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isLoadingConexaoHash() => r'5367d0a35fd16d132a99bf12199a2727793e9df0';

/// Loading state for operations - TODO: Migrate to local widget state

abstract class _$IsLoadingConexao extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
