import 'package:flutter/material.dart';

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
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Row(
      children: [
        if(titleImagePath != null)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(titleImagePath!, width: 30,height: 30,),
        ),
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
          if(onTextButtonPressed != null)
          TextButton(
            onPressed: onTextButtonPressed,
            child: Text('더보기', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}
