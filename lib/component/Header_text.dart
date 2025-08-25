import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  final String title;
  final VoidCallback? onTextButtonPressed;
  final bool showIconButton;
  const HeaderText({
    required this.title,
    required this.onTextButtonPressed,
    required this.showIconButton,
    super.key,
});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: mediumText?.copyWith(
              fontSize: 25,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showIconButton)
          TextButton(
            onPressed: onTextButtonPressed,
            child: Text('더보기', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}
