// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commissioning_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedCommissioningPhase)
final selectedCommissioningPhaseProvider =
    SelectedCommissioningPhaseProvider._();

final class SelectedCommissioningPhaseProvider
    extends $NotifierProvider<SelectedCommissioningPhase, String> {
  SelectedCommissioningPhaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCommissioningPhaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCommissioningPhaseHash();

  @$internal
  @override
  SelectedCommissioningPhase create() => SelectedCommissioningPhase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedCommissioningPhaseHash() =>
    r'f3e932408e64a699644774c026d5010b845b29c9';

abstract class _$SelectedCommissioningPhase extends $Notifier<String> {
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
