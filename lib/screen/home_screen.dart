import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Image.asset(
                      'assets/img/logo.png',
                      width: 36,
                      height: 56,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2025년 7월 26일',
                        style: TextTheme.of(
                          context,
                        ).displayLarge!.copyWith(fontSize: 21),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '오늘 하루도 맛있는 하루 되세요!',
                        style: TextTheme.of(
                          context,
                        ).displayMedium!.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(width: 42),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/img/bell.png'),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/img/user.png'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
