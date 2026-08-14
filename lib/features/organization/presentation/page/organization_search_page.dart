import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/features/organization/presentation/provider/organization_provider.dart';
import 'package:handori/features/organization/presentation/widget/organization_node_card.dart';

class OrganizationSearchPage extends ConsumerWidget {
  final String query;

  const OrganizationSearchPage({required this.query, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(
      organizationSearchNotifierProvider(query),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Text(
          '"$query" 검색 결과',
          style: AppTextStyles.title03,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: searchAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('검색 실패: $e')),
        data: (results) {
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 48,
                    color: Color(0xFFBDBDBD),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '검색 결과가 없습니다.',
                    style: AppTextStyles.body.copyWith(
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: results.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.cardBorder),
            itemBuilder: (_, i) => OrganizationNodeCard(node: results[i]),
          );
        },
      ),
    );
  }
}
