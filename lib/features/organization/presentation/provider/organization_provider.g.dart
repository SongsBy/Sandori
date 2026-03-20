// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$organizationApiHash() => r'4a0cb73b5538d1d4dd0d48a12b43bfb019c41af1';

/// See also [organizationApi].
@ProviderFor(organizationApi)
final organizationApiProvider = AutoDisposeProvider<OrganizationApi>.internal(
  organizationApi,
  name: r'organizationApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$organizationApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrganizationApiRef = AutoDisposeProviderRef<OrganizationApi>;
String _$organizationRepositoryHash() =>
    r'71c659f098ed75c33af62bfe2a143429ea173913';

/// See also [organizationRepository].
@ProviderFor(organizationRepository)
final organizationRepositoryProvider =
    AutoDisposeProvider<OrganizationRepository>.internal(
      organizationRepository,
      name: r'organizationRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$organizationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrganizationRepositoryRef =
    AutoDisposeProviderRef<OrganizationRepository>;
String _$organizationTreeNotifierHash() =>
    r'0b24a2aa1628237634c330b4dbd3e162e0a99950';

/// See also [OrganizationTreeNotifier].
@ProviderFor(OrganizationTreeNotifier)
final organizationTreeNotifierProvider = AutoDisposeAsyncNotifierProvider<
  OrganizationTreeNotifier,
  OrganizationGroupNode
>.internal(
  OrganizationTreeNotifier.new,
  name: r'organizationTreeNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$organizationTreeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrganizationTreeNotifier =
    AutoDisposeAsyncNotifier<OrganizationGroupNode>;
String _$organizationSearchNotifierHash() =>
    r'9064a99603c042f01b0fdeb737d140dc7cc41b16';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$OrganizationSearchNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<OrganizationNode>> {
  late final String query;

  FutureOr<List<OrganizationNode>> build(String query);
}

/// See also [OrganizationSearchNotifier].
@ProviderFor(OrganizationSearchNotifier)
const organizationSearchNotifierProvider = OrganizationSearchNotifierFamily();

/// See also [OrganizationSearchNotifier].
class OrganizationSearchNotifierFamily
    extends Family<AsyncValue<List<OrganizationNode>>> {
  /// See also [OrganizationSearchNotifier].
  const OrganizationSearchNotifierFamily();

  /// See also [OrganizationSearchNotifier].
  OrganizationSearchNotifierProvider call(String query) {
    return OrganizationSearchNotifierProvider(query);
  }

  @override
  OrganizationSearchNotifierProvider getProviderOverride(
    covariant OrganizationSearchNotifierProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'organizationSearchNotifierProvider';
}

/// See also [OrganizationSearchNotifier].
class OrganizationSearchNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          OrganizationSearchNotifier,
          List<OrganizationNode>
        > {
  /// See also [OrganizationSearchNotifier].
  OrganizationSearchNotifierProvider(String query)
    : this._internal(
        () => OrganizationSearchNotifier()..query = query,
        from: organizationSearchNotifierProvider,
        name: r'organizationSearchNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$organizationSearchNotifierHash,
        dependencies: OrganizationSearchNotifierFamily._dependencies,
        allTransitiveDependencies:
            OrganizationSearchNotifierFamily._allTransitiveDependencies,
        query: query,
      );

  OrganizationSearchNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<OrganizationNode>> runNotifierBuild(
    covariant OrganizationSearchNotifier notifier,
  ) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(OrganizationSearchNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrganizationSearchNotifierProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    OrganizationSearchNotifier,
    List<OrganizationNode>
  >
  createElement() {
    return _OrganizationSearchNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrganizationSearchNotifierProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrganizationSearchNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<OrganizationNode>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _OrganizationSearchNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          OrganizationSearchNotifier,
          List<OrganizationNode>
        >
    with OrganizationSearchNotifierRef {
  _OrganizationSearchNotifierProviderElement(super.provider);

  @override
  String get query => (origin as OrganizationSearchNotifierProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
