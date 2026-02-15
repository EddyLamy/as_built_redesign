// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider que controla o tema atual - Riverpod 3.x annotation-based

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

/// Provider que controla o tema atual - Riverpod 3.x annotation-based
final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, String> {
  /// Provider que controla o tema atual - Riverpod 3.x annotation-based
  ThemeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$themeNotifierHash() => r'addfc162eb52d97ae175a43fb5d2f4b0226c75f1';

/// Provider que controla o tema atual - Riverpod 3.x annotation-based

abstract class _$ThemeNotifier extends $Notifier<String> {
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
