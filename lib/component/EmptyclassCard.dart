import 'package:flutter/material.dart';
import 'package:handori/model/class_model.dart';

class ClassStateCard extends StatelessWidget {
  final List<EmptyClass> items;
  final int maxItems;
  final VoidCallback? onMore;

  const ClassStateCard({
    super.key,
    required this.items,
    this.maxItems = 6,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();


    final visible = items.take(maxItems).toList();
    final hasMore = items.length > visible.length;

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  '빈 강의실 현황',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (hasMore && onMore != null)
                  TextButton(
                    onPressed: onMore,
                    child: const Text('더보기'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(visible.length, (i) {
              final c = visible[i];
              return Column(
                children: [
                  _ClassLine(
                    title: c.className,
                    countText: '총 ${c.classCount}개',
                    leadingAsset: c.classIcons,
                  ),
                  if (i != visible.length - 1)
                    const Divider(height: 14, thickness: 0.8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ClassLine extends StatelessWidget {
  final String title;
  final String countText;
  final String? leadingAsset;

  const _ClassLine({
    required this.title,
    required this.countText,
    this.leadingAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leadingAsset != null && leadingAsset!.isNotEmpty)
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3F4FF),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(leadingAsset!, fit: BoxFit.contain),
          )
        else
          Icon(Icons.apartment_rounded, color: Colors.black54, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7FB)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            countText,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}