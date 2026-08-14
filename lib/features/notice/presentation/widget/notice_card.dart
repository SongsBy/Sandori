import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/core/utils/date_formatter.dart';
import 'package:handori/features/notice/domain/model/notice.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback? onTap;
  final bool showDivider;

  const NoticeCard({
    required this.notice,
    this.onTap,
    this.showDivider = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE9ECEF)),
                ),
              )
            : null,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.author,
              style: AppTextStyles.caption04.copyWith(
                height: 16 / 12,
                color: const Color(0xFF767676),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              notice.title,
              style: AppTextStyles.subtitle.copyWith(
                height: 24 / 16,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              DateFormatter.format(notice.createdAt),
              style: AppTextStyles.caption04.copyWith(
                height: 16 / 12,
                color: const Color(0xFF767676),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
