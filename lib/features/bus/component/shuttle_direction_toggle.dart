import 'package:flutter/material.dart';

// ─── Color tokens ──────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF00C4F9);
const Color _kBgBase = Colors.white;
const Color _kBorderSoft = Color(0xFFF0F0F8);
const Color _kTextMuted = Color(0xFF8A8F98);

/// 정왕역 방면(0) / 학교 방면(1) 토글.
///
/// 버스 상세 화면과 전체 시간표 화면에서 공통으로 사용한다.
class ShuttleDirectionToggle extends StatelessWidget {
  /// 0: 정왕역 방면, 1: 학교 방면.
  final int selected;
  final ValueChanged<int> onChanged;

  const ShuttleDirectionToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorderSoft),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleItem('정왕역 방면', 0),
          _toggleItem('학교 방면', 1),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, int index) {
    final bool isSelected = selected == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected ? _kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? Colors.white : _kTextMuted,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
