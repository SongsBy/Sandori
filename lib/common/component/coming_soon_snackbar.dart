import 'package:flutter/material.dart';

/// 아직 구현되지 않은 기능(알림 · 유저 등)을 눌렀을 때
/// "준비중입니다" 안내 스낵바를 띄운다.
void showComingSoonSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('준비중입니다'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
