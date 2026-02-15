// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_drawer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentModule)
final currentModuleProvider = CurrentModuleProvider._();

final class CurrentModuleProvider
    extends $NotifierProvider<CurrentModule, AppModule> {
  CurrentModuleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentModuleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentModuleHash();

  @$internal
  @override
  CurrentModule create() => CurrentModule();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppModule value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppModule>(value),
    );
  }
}

String _$currentModuleHash() => r'1793b4506bbb6e02204bc73ebc1a22612b5a714c';

abstract class _$CurrentModule extends $Notifier<AppModule> {
  AppModule build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppModule, AppModule>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AppModule, AppModule>, AppModule, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
