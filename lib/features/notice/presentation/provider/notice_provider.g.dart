// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noticeApiHash() => r'b5b74a74f10a846674c00e936d15777c77c6b53c';

/// See also [noticeApi].
@ProviderFor(noticeApi)
final noticeApiProvider = AutoDisposeProvider<NoticeApi>.internal(
  noticeApi,
  name: r'noticeApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$noticeApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NoticeApiRef = AutoDisposeProviderRef<NoticeApi>;
String _$noticeRepositoryHash() => r'ef9a750fadf7fbf2fb7b9aa5d4a06b65e405dee2';

/// See also [noticeRepository].
@ProviderFor(noticeRepository)
final noticeRepositoryProvider = AutoDisposeProvider<NoticeRepository>.internal(
  noticeRepository,
  name: r'noticeRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$noticeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NoticeRepositoryRef = AutoDisposeProviderRef<NoticeRepository>;
String _$recentShuttleHash() => r'4b4f5c4c588fba6c11a92abda920e95d5a062794';

/// See also [recentShuttle].
@ProviderFor(recentShuttle)
final recentShuttleProvider = AutoDisposeFutureProvider<ShuttleRecent>.internal(
  recentShuttle,
  name: r'recentShuttleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentShuttleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentShuttleRef = AutoDisposeFutureProviderRef<ShuttleRecent>;
String _$noticeListNotifierHash() =>
    r'cb12eb705440ec9416d3e64465a3ab15687274a5';

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

abstract class _$NoticeListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<PaginationState<Notice>> {
  late final bool isDormitory;

  FutureOr<PaginationState<Notice>> build({required bool isDormitory});
}

/// See also [NoticeListNotifier].
@ProviderFor(NoticeListNotifier)
const noticeListNotifierProvider = NoticeListNotifierFamily();

/// See also [NoticeListNotifier].
class NoticeListNotifierFamily
    extends Family<AsyncValue<PaginationState<Notice>>> {
  /// See also [NoticeListNotifier].
  const NoticeListNotifierFamily();

  /// See also [NoticeListNotifier].
  NoticeListNotifierProvider call({required bool isDormitory}) {
    return NoticeListNotifierProvider(isDormitory: isDormitory);
  }

  @override
  NoticeListNotifierProvider getProviderOverride(
    covariant NoticeListNotifierProvider provider,
  ) {
    return call(isDormitory: provider.isDormitory);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noticeListNotifierProvider';
}

/// See also [NoticeListNotifier].
class NoticeListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          NoticeListNotifier,
          PaginationState<Notice>
        > {
  /// See also [NoticeListNotifier].
  NoticeListNotifierProvider({required bool isDormitory})
    : this._internal(
        () => NoticeListNotifier()..isDormitory = isDormitory,
        from: noticeListNotifierProvider,
        name: r'noticeListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$noticeListNotifierHash,
        dependencies: NoticeListNotifierFamily._dependencies,
        allTransitiveDependencies:
            NoticeListNotifierFamily._allTransitiveDependencies,
        isDormitory: isDormitory,
      );

  NoticeListNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isDormitory,
  }) : super.internal();

  final bool isDormitory;

  @override
  FutureOr<PaginationState<Notice>> runNotifierBuild(
    covariant NoticeListNotifier notifier,
  ) {
    return notifier.build(isDormitory: isDormitory);
  }

  @override
  Override overrideWith(NoticeListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: NoticeListNotifierProvider._internal(
        () => create()..isDormitory = isDormitory,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isDormitory: isDormitory,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    NoticeListNotifier,
    PaginationState<Notice>
  >
  createElement() {
    return _NoticeListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoticeListNotifierProvider &&
        other.isDormitory == isDormitory;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isDormitory.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoticeListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<PaginationState<Notice>> {
  /// The parameter `isDormitory` of this provider.
  bool get isDormitory;
}

class _NoticeListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          NoticeListNotifier,
          PaginationState<Notice>
        >
    with NoticeListNotifierRef {
  _NoticeListNotifierProviderElement(super.provider);

  @override
  bool get isDormitory => (origin as NoticeListNotifierProvider).isDormitory;
}

String _$shuttleListNotifierHash() =>
    r'3a8b9a8aaa381a91b3f3e8f089c496985b985807';

/// See also [ShuttleListNotifier].
@ProviderFor(ShuttleListNotifier)
final shuttleListNotifierProvider = AutoDisposeAsyncNotifierProvider<
  ShuttleListNotifier,
  PaginationState<Shuttle>
>.internal(
  ShuttleListNotifier.new,
  name: r'shuttleListNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shuttleListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShuttleListNotifier =
    AutoDisposeAsyncNotifier<PaginationState<Shuttle>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
