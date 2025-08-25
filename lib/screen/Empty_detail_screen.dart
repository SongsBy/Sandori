import 'package:flutter/material.dart';

class EmptyDetailScreen extends StatelessWidget {
  const EmptyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('빈 강의실 조회 페이지'),
      ),
    );
  }
}
