import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBellPressed;
  final VoidCallback onUserPressed;
  const TopBar({
    required this.onBellPressed,
    required this.onUserPressed,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2025년 7월 26일',
                    style: TextTheme.of(
                      context,
                    ).displayLarge?.copyWith(fontSize: 21),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘 하루도 맛있는 하루 되세요!',
                    style: TextTheme.of(
                      context,
                    ).displayMedium?.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onBellPressed,
              icon: Image.asset('assets/img/bell.png'),
            ),
            IconButton(
              onPressed: onUserPressed,
              icon: Icon(Icons.account_circle),
            ),
          ],
        ),
      ),
    );
  }
}
