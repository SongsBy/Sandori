import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/empty_class/model/class_model.dart';

({Color fg, Color bg, Color border, String label}) _trafficStyle(String path) {
  if (path.contains('green')) {
    return (
      fg: AppColors.success,
      bg: const Color(0xFFEFF9F0),
      border: const Color(0xFFCFEAD2),
      label: '여유',
    );
  }
  if (path.contains('orange')) {
    return (
      fg: const Color(0xFFBB6800),
      bg: const Color(0xFFFFF4E0),
      border: const Color(0xFFFFD9A0),
      label: '보통',
    );
  }
  return (
    fg: AppColors.danger,
    bg: const Color(0xFFFFF0F0),
    border: const Color(0xFFFFD1D1),
    label: '혼잡',
  );
}

class ClassStateCard extends StatelessWidget {
  final List<EmptyClass> items;
  final int maxItems;
  final VoidCallback? onTap;
  final bool showHeader;

  const ClassStateCard({
    super.key,
    required this.items,
    this.maxItems = 6,
    this.onTap,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final visible = items.take(maxItems).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Text(
                '빈 강의실 현황',
                style: AppTextStyles.title02,
              ),
              const SizedBox(height: 8),
            ],
            ...List.generate(visible.length, (i) {
              final c = visible[i];
              return Column(
                children: [
                  _ClassLine(
                    title: c.className,
                    classCount: c.classCount,
                    trafficIcon: c.trafficIcon,
                    onTap: onTap,
                  ),
                  if (i != visible.length - 1)
                    const Divider(height: 14, thickness: 0.8, color: AppColors.cardBorder),
                ],
              );
            }),
          ],
        ),
    );
  }
}

class _ClassLine extends StatelessWidget {
  final String title;
  final String classCount;
  final String trafficIcon;
  final VoidCallback? onTap;

  const _ClassLine({
    required this.title,
    required this.classCount,
    required this.trafficIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _trafficStyle(trafficIcon);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: AppTextStyles.caption01.copyWith(color: Colors.black87),
              ),
            ),
            const SizedBox(width: 10),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: style.bg,
                border: Border.all(color: style.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                style.label,
                style: AppTextStyles.caption04.copyWith(color: style.fg),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.subtleBg,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '총 $classCount개',
                style: AppTextStyles.caption04.copyWith(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
