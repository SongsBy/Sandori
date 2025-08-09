import 'package:flutter/material.dart';
import 'package:handori/screen/LoginScreen.dart';
import 'package:handori/screen/SigninScreen.dart';
import 'package:handori/screen/home_screen.dart';

class SignInGateScreen extends StatelessWidget {
  const SignInGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                paddingY(80.0),

                ///중단
                _Middle(textTheme: textTheme),
                paddingY(4),

                ///상단
                Padding(padding: const EdgeInsets.all(16.0), child: _Top()),
                paddingY(50.0),

                ///하단 버튼
                _Bottom(
                  textTheme: textTheme,
                  onPressed: () => _navigateToLogin(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 벼튼 클릭시 동작 함수
  void _navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (BuildContext context) => Loginscreen()));
  }

  /// 패딩 함수
  Widget paddingY(double value) => SizedBox(height: value);
}

/// 상단 이미지
class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(1, 1),
      child: Image.asset('assets/img/gatelogo4.png'),
    );
  }
}

///증간 텍스트
class _Middle extends StatelessWidget {
  final TextTheme textTheme;
  const _Middle({required this.textTheme, super.key});

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    final Large = Theme.of(context).textTheme.displayLarge;

    return Column(
      children: [
        Text(
          '새롭게 돌아온 산돌이',
          textAlign: TextAlign.center,
          style: Large?.copyWith(fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            ' 여러분의 학교 생활을 \n편하게 만들어드릴게요',
            style: textTheme.displayMedium?.copyWith(
              fontSize: 19,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

///하단 버튼
class _Bottom extends StatelessWidget {
  final TextTheme textTheme;
  final VoidCallback onPressed;
  const _Bottom({
    required this.textTheme,
    required this.onPressed,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final baseButtonStyle = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0XFF95E0F4),
            shape: baseButtonStyle,
            padding: EdgeInsets.symmetric(horizontal: 120, vertical: 17),
          ),
          onPressed: onPressed,
          child: Text(
            '시작하기',
            style: (textTheme.displayMedium ?? const TextStyle(fontSize: 20))
                .copyWith(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
