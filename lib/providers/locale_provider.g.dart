// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider que controla o locale atual - Riverpod 3.x annotation-based

@ProviderFor(LocaleNotifier)
final localeProvider = LocaleNotifierProvider._();

/// Provider que controla o locale atual - Riverpod 3.x annotation-based
final class LocaleNotifierProvider
    extends $NotifierProvider<LocaleNotifier, String> {
  /// Provider que controla o locale atual - Riverpod 3.x annotation-based
  LocaleNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localeNotifierHash();

  @$internal
  @override
  LocaleNotifier create() => LocaleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$localeNotifierHash() => r'8332cb018fad53a0d986bb769cf3f9fc8d51b416';

/// Provider que controla o locale atual - Riverpod 3.x annotation-based

abstract class _$LocaleNotifier extends $Notifier<String> {
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
