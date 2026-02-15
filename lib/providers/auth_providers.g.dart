// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Guarda apenas o userId vindo do REST (String) – porque não existe class UserSession no projeto

@ProviderFor(UserSession)
final userSessionProvider = UserSessionProvider._();

/// Guarda apenas o userId vindo do REST (String) – porque não existe class UserSession no projeto
final class UserSessionProvider
    extends $NotifierProvider<UserSession, String?> {
  /// Guarda apenas o userId vindo do REST (String) – porque não existe class UserSession no projeto
  UserSessionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSessionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSessionHash();

  @$internal
  @override
  UserSession create() => UserSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$userSessionHash() => r'35a1f953f575f48d3a7833d32a01e6c93b99dd3a';

/// Guarda apenas o userId vindo do REST (String) – porque não existe class UserSession no projeto

abstract class _$UserSession extends $Notifier<String?> {
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
