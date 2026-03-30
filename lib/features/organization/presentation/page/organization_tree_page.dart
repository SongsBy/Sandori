import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/organization/presentation/provider/organization_provider.dart';
import 'package:handori/features/organization/presentation/widget/organization_node_card.dart';

class OrganizationTreePage extends ConsumerStatefulWidget {
  const OrganizationTreePage({super.key});

  @override
  ConsumerState<OrganizationTreePage> createState() =>
      _OrganizationTreePageState();
}

class _OrganizationTreePageState extends ConsumerState<OrganizationTreePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treeAsync = ref.watch(organizationTreeNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text(
          '학과/부서 조직도',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '학과 또는 부서 이름 검색',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0088CC)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2EEF3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2EEF3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0088CC)),
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v.trim()),
              onSubmitted: (v) {
                final q = v.trim();
                if (q.isNotEmpty) {
                  context.push(RoutePaths.organizationSearch, extra: q);
                }
              },
            ),
          ),

          // 트리 본문
          Expanded(
            child: treeAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF0088CC)),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text('불러오기 실패: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(organizationTreeNotifierProvider.notifier).refresh(),
                      child: const Text('재시도'),
                    ),
                  ],
                ),
              ),
              data: (root) => RefreshIndicator(
                color: const Color(0xFF0088CC),
                onRefresh: () =>
                    ref.read(organizationTreeNotifierProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  children: root.children
                      .map((node) => OrganizationNodeCard(node: node))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
