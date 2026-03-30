import 'package:handori/features/organization/data/data_source/organization_api.dart';
import 'package:handori/features/organization/domain/model/organization_node.dart';
import 'package:handori/features/organization/domain/repository/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationApi _api;

  const OrganizationRepositoryImpl(this._api);

  @override
  Future<OrganizationGroupNode> getTree() async {
    final response = await _api.getTree();
    return response.toDomain();
  }

  @override
  Future<List<OrganizationNode>> searchByName(String name) async {
    final raw = await _api.searchByName(name);
    return raw.map((e) => e.toDomain()).toList();
  }

  @override
  Future<OrganizationNode> getByPath(String path) async {
    final raw = await _api.getByPath(path);
    return raw.toDomain();
  }

  @override
  Future<List<OrganizationNode>> getChildren(String path) async {
    final raw = await _api.getChildren(path);
    return raw.map((e) => e.toDomain()).toList();
  }
}
