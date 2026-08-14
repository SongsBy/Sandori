import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
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

TextStyle _getDepthTextStyle(int depth) {
  if (depth == 0) {
    return AppTextStyles.caption01.copyWith(color: Colors.black87);
  } else {
    return AppTextStyles.caption02.copyWith(
      fontWeight: FontWeight.w500,
      color: Colors.grey[600],
    );
  }
}

class _GroupTile extends StatelessWidget {
  final OrganizationGroupNode node;
  final int depth;

  const _GroupTile({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: depth > 0
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
            )
          : null,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(
            left: depth > 0 ? 8 : 0,
            right: 8,
            top: 0,
            bottom: 0,
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.primary,
          leading: Icon(
            Icons.folder_outlined,
            color: depth == 0 ? AppColors.primary : Colors.grey[500],
            size: 20,
          ),
          title: Text(
            node.name,
            style: _getDepthTextStyle(depth),
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
    return Container(
      decoration: depth > 0
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
            )
          : null,
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: depth > 0 ? 8 : 8,
          right: 8,
          top: 2,
          bottom: 2,
        ),
        leading: Icon(
          Icons.person_outline,
          color: depth == 0 ? AppColors.primary : Colors.grey[500],
          size: 20,
        ),
        title: Text(
          node.name,
          style: _getDepthTextStyle(depth),
        ),
        subtitle: node.phone != null || node.url != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (node.phone != null)
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            node.phone!,
                            style: AppTextStyles.caption04.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (node.url != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              node.url!,
                              style: AppTextStyles.caption04.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
