import 'package:handori/features/organization/domain/model/organization_node.dart';

abstract class OrganizationRepository {
  Future<OrganizationGroupNode> getTree();
  Future<List<OrganizationNode>> searchByName(String name);
  Future<OrganizationNode> getByPath(String path);
  Future<List<OrganizationNode>> getChildren(String path);
}
