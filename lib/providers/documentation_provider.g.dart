// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documentation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentationService)
final documentationServiceProvider = DocumentationServiceProvider._();

final class DocumentationServiceProvider extends $FunctionalProvider<
    DocumentationService,
    DocumentationService,
    DocumentationService> with $Provider<DocumentationService> {
  DocumentationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'documentationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$documentationServiceHash();

  @$internal
  @override
  $ProviderElement<DocumentationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DocumentationService create(Ref ref) {
    return documentationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentationService>(value),
    );
  }
}

String _$documentationServiceHash() =>
    r'3cec57f9660e97bba75bed1dc810bb0fc0ca17e5';

@ProviderFor(documentationStream)
final documentationStreamProvider = DocumentationStreamProvider._();

final class DocumentationStreamProvider extends $FunctionalProvider<
        AsyncValue<List<Documentation>>,
        List<Documentation>,
        Stream<List<Documentation>>>
    with
        $FutureModifier<List<Documentation>>,
        $StreamProvider<List<Documentation>> {
  DocumentationStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'documentationStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$documentationStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Documentation>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Documentation>> create(Ref ref) {
    return documentationStream(ref);
  }
}

String _$documentationStreamHash() =>
    r'b9d2d45b55c18e85ea49c000a27887b862a84a31';

@ProviderFor(DocFilterNotifier)
final docFilterProvider = DocFilterNotifierProvider._();

final class DocFilterNotifierProvider
    extends $NotifierProvider<DocFilterNotifier, DocFilter> {
  DocFilterNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'docFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$docFilterNotifierHash();

  @$internal
  @override
  DocFilterNotifier create() => DocFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocFilter>(value),
    );
  }
}

String _$docFilterNotifierHash() => r'a0cd9a5e6bcab310985897ca8d5c04b050aa58c2';

abstract class _$DocFilterNotifier extends $Notifier<DocFilter> {
  DocFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DocFilter, DocFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DocFilter, DocFilter>, DocFilter, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredDocuments)
final filteredDocumentsProvider = FilteredDocumentsProvider._();

final class FilteredDocumentsProvider extends $FunctionalProvider<
        AsyncValue<List<Documentation>>,
        AsyncValue<List<Documentation>>,
        AsyncValue<List<Documentation>>>
    with $Provider<AsyncValue<List<Documentation>>> {
  FilteredDocumentsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredDocumentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredDocumentsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Documentation>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<List<Documentation>> create(Ref ref) {
    return filteredDocuments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Documentation>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<Documentation>>>(value),
    );
  }
}

String _$filteredDocumentsHash() => r'a7adae5e541290fb14606e96e8488286a5ca9427';

@ProviderFor(groupedDocuments)
final groupedDocumentsProvider = GroupedDocumentsProvider._();

final class GroupedDocumentsProvider extends $FunctionalProvider<
        AsyncValue<Map<DocumentCategory, List<Documentation>>>,
        AsyncValue<Map<DocumentCategory, List<Documentation>>>,
        AsyncValue<Map<DocumentCategory, List<Documentation>>>>
    with $Provider<AsyncValue<Map<DocumentCategory, List<Documentation>>>> {
  GroupedDocumentsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'groupedDocumentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$groupedDocumentsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<Map<DocumentCategory, List<Documentation>>>>
      $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AsyncValue<Map<DocumentCategory, List<Documentation>>> create(Ref ref) {
    return groupedDocuments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
      AsyncValue<Map<DocumentCategory, List<Documentation>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<
          AsyncValue<Map<DocumentCategory, List<Documentation>>>>(value),
    );
  }
}

String _$groupedDocumentsHash() => r'bf20c06cfdc6c9e2ae0eb21ed162c95611adb996';

@ProviderFor(allTags)
final allTagsProvider = AllTagsProvider._();

final class AllTagsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  AllTagsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allTagsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allTagsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return allTags(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$allTagsHash() => r'1346af69b93bd45d75c5929bcb78296757d1fe77';
