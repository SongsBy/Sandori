import 'package:flutter/material.dart';

class SelectableIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSelected;
  final String imagePath;
  const SelectableIconButton({
    required this.onPressed,
    required this.isSelected,
    required this.imagePath,
  super.key
  });

  @override
  Widget build(BuildContext context) {
    final Color isBackgroundColor = isSelected ? Color(0XFF95E0F4) : Colors.grey;
    return GestureDetector(
      onTap: onPressed,
      child:Container(
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBackgroundColor,
        ),
        child: Image.asset(imagePath),
      ) ,
    );
  }
}
