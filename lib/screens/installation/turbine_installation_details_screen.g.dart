// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turbine_installation_details_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedInstallationPhase)
final selectedInstallationPhaseProvider = SelectedInstallationPhaseProvider._();

final class SelectedInstallationPhaseProvider
    extends $NotifierProvider<SelectedInstallationPhase, String> {
  SelectedInstallationPhaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedInstallationPhaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedInstallationPhaseHash();

  @$internal
  @override
  SelectedInstallationPhase create() => SelectedInstallationPhase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedInstallationPhaseHash() =>
    r'88107f74f4a7c9460d83d89339c7caeaf9302b9b';

abstract class _$SelectedInstallationPhase extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
