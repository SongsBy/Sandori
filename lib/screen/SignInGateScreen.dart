import 'package:flutter/material.dart';
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
              paddingY(170.0),
                ///상단
                _Top(),
                paddingY(70.0),

                ///중단
                _Middle(textTheme: textTheme),
                paddingY(60),

                ///하단 버튼
                _Bottom(
                  textTheme:textTheme,
                  onPressed: ()  => _navigateToLogin(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



/// 벼튼 클릭시 동작 함수
  void _navigateToLogin(BuildContext context){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(),
      ),
    );
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
      alignment: Alignment(-0.1, 1),
      child: Image.asset('assets/img/logo.png'),
    );
  }
}

///증간 텍스트
class _Middle extends StatelessWidget {
  final TextTheme textTheme;
  const _Middle({required this.textTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '챗봇에서 새로 리뉴얼 된\n산돌이',
          textAlign: TextAlign.center,
          style: textTheme.displayLarge,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 35.0),
          child: Text(
            ' 여러분의 학교 생활을 돕습니다!',
            style: textTheme.displayMedium!.copyWith(fontSize: 18,color: Colors.grey),
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
  const _Bottom({required this.textTheme, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final baseButtonStyle = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0XFF4EA6AA),
            shape: baseButtonStyle,
            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 17),
          ),
          onPressed: onPressed,
          child: Text(
            '로그인',
            style: (textTheme.displayMedium ?? const TextStyle(fontSize: 20))
                .copyWith(color: Colors.white),
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: baseButtonStyle,
            side: BorderSide(color: Colors.black),
            padding: EdgeInsets.symmetric(horizontal: 46, vertical: 17),
          ),
          onPressed: () {},
          child: Text('회원가입', style: textTheme.displayMedium),
        ),
      ],
    );
  }
}
