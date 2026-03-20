sealed class OrganizationNode {
  String get name;
}

class OrganizationGroupNode extends OrganizationNode {
  @override
  final String name;
  final List<OrganizationNode> children;

  OrganizationGroupNode({required this.name, required this.children});
}

class OrganizationUnitNode extends OrganizationNode {
  @override
  final String name;
  final String? phone;
  final String? url;

  OrganizationUnitNode({required this.name, this.phone, this.url});
}
