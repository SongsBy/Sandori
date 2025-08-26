import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBellPressed;
  final VoidCallback onUserPressed;
  final String? headerText;
  const TopBar({
    required this.onBellPressed,
    required this.onUserPressed,
    this.headerText,
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
                    headerText?? '',
                    style: TextTheme.of(
                      context,
                    ).displayLarge?.copyWith(fontSize: 25),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
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
