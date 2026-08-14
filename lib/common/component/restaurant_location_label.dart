import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_text_styles.dart';

/// 식당 위치 정보를 아이콘 + 텍스트로 표시하는 공통 위젯.
///
/// meal_card / restaurant_detail_page 등 여러 화면에 중복 구현돼 있던
/// 위치 표시 UI(`Icons.location_on_outlined` + 위치 텍스트)를 단일 컴포넌트로
/// 통합한 것이다. (§8 컴포넌트 분리 규칙)
///
/// 부모가 폭을 제한하는 컨텍스트(예: `Expanded`/`Row`)에서 사용하면 내부
/// [Text] 가 1줄 말줄임으로 처리된다.
class RestaurantLocationLabel extends StatelessWidget {
  final String location;
  final double iconSize;
  final double fontSize;
  final double gap;

  const RestaurantLocationLabel({
    required this.location,
    this.iconSize = _kIconSize,
    this.fontSize = _kFontSize,
    this.gap = _kGap,
    super.key,
  });

  static const _kIconSize = 13.0;
  static const _kFontSize = 12.0;
  static const _kGap = 3.0;
  static const _kIconColor = Colors.black38;
  static const _kTextColor = Colors.black45;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_outlined, size: iconSize, color: _kIconColor),
        SizedBox(width: gap),
        Flexible(
          child: Text(
            location,
            style: AppTextStyles.caption04.copyWith(
              fontSize: fontSize,
              color: _kTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
