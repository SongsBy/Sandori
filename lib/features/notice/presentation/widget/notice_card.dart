import 'package:flutter/material.dart';
import 'package:handori/core/utils/date_formatter.dart';
import 'package:handori/features/notice/domain/model/notice.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback? onTap;

  const NoticeCard({required this.notice, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(notice.author, style: textTheme.bodySmall),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.format(notice.createdAt),
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
