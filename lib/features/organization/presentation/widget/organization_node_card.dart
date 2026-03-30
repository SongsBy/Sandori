import 'package:flutter/material.dart';
import 'package:handori/features/organization/domain/model/organization_node.dart';

class OrganizationNodeCard extends StatelessWidget {
  final OrganizationNode node;
  final int depth;

  const OrganizationNodeCard({
    required this.node,
    this.depth = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return switch (node) {
      OrganizationGroupNode() => _GroupTile(
          node: node as OrganizationGroupNode,
          depth: depth,
        ),
      OrganizationUnitNode() => _UnitTile(
          node: node as OrganizationUnitNode,
          depth: depth,
        ),
    };
  }
}

class _GroupTile extends StatelessWidget {
  final OrganizationGroupNode node;
  final int depth;

  const _GroupTile({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final indent = depth * 16.0;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          leading: Icon(
            Icons.folder_outlined,
            color: const Color(0xFF0088CC),
            size: 20,
          ),
          title: Text(
            node.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          children: node.children
              .map((child) => OrganizationNodeCard(
                    node: child,
                    depth: depth + 1,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  final OrganizationUnitNode node;
  final int depth;

  const _UnitTile({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final indent = depth * 16.0;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: const Icon(
          Icons.person_outline,
          color: Color(0xFF6B7A89),
          size: 20,
        ),
        title: Text(
          node.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: node.phone != null || node.url != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (node.phone != null)
                    Text(
                      node.phone!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF0088CC)),
                    ),
                  if (node.url != null)
                    Text(
                      node.url!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF0088CC)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
