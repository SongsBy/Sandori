import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_text_styles.dart';

class HeaderText extends StatelessWidget {
  final String title;
  final VoidCallback? onTextButtonPressed;
  final String? titleImagePath;
  const HeaderText({
    required this.title,
    this.onTextButtonPressed,
    this.titleImagePath,
    super.key,
});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if(titleImagePath != null)
        Image.asset(titleImagePath!, width: 30,height: 30,),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.title01.copyWith(color: Colors.black87),
          ),
        ),
          if(onTextButtonPressed != null)
          TextButton(
            onPressed: onTextButtonPressed,
            child: Text(
              '더보기',
              style: AppTextStyles.caption02.copyWith(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
