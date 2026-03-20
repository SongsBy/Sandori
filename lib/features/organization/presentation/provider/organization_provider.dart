import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:handori/core/network/static_info_dio_provider.dart';
import 'package:handori/features/organization/data/data_source/organization_api.dart';
import 'package:handori/features/organization/data/repository/organization_repository_impl.dart';
import 'package:handori/features/organization/domain/model/organization_node.dart';
import 'package:handori/features/organization/domain/repository/organization_repository.dart';

part 'organization_provider.g.dart';

@riverpod
OrganizationApi organizationApi(Ref ref) {
  final dio = ref.watch(staticInfoDioProvider);
  return OrganizationApi(dio);
}

@riverpod
OrganizationRepository organizationRepository(Ref ref) {
  final api = ref.watch(organizationApiProvider);
  return OrganizationRepositoryImpl(api);
}

@riverpod
class OrganizationTreeNotifier extends _$OrganizationTreeNotifier {
  @override
  Future<OrganizationGroupNode> build() async {
    final repo = ref.watch(organizationRepositoryProvider);
    return repo.getTree();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(organizationRepositoryProvider).getTree(),
    );
  }
}

@riverpod
class OrganizationSearchNotifier extends _$OrganizationSearchNotifier {
  @override
  Future<List<OrganizationNode>> build(String query) async {
    if (query.trim().isEmpty) return [];
    final repo = ref.watch(organizationRepositoryProvider);
    return repo.searchByName(query);
  }
}
