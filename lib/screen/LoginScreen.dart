import 'package:flutter/material.dart';
import 'package:handori/screen/SignInGateScreen.dart';
import 'package:handori/screen/SigninScreen.dart';
import 'package:handori/screen/home_screen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final Map<String, TextEditingController> controllers = {
    'username': TextEditingController(),
    'password': TextEditingController(),
  };
  @override
  dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 60),

                  /// 상단 이미지와 텍스트
                  _Top(),

                  ///소셜 로그인
                  _Middle(
                    onGooglePressed: googleLogin,
                    onApplePressed: appleLogin,
                    onKakaoPressed: kakaoLogin,
                  ),

                  ///회원 아이디로 로그인
                  _Bottom(
                    controllers: controllers,
                    onLoginPressed: login,
                    onSigninPressed: signin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
///카카오 로그인 구동 함수
  void kakaoLogin() {
    print('카카오로그인');
  }
///구글 로그인 구동 함수
  void googleLogin() {
    print('구글로그인');
  }
///애플 로그인 구동 함수
  void appleLogin() {
    print('애플로그인');
  }
///회원 로그인 구동 함수
  void login() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }
///회원 가입 로그인 구동 함수
  void signin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => Signinscreen()));
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final largeText = Theme.of(context).textTheme.displayLarge;
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    final padding = SizedBox(height: 10);
    return Column(
      children: [
        Align(
          alignment: Alignment(-0.1, 0),
          child: Image.asset('assets/img/logo.png', width: 90, height: 140),
        ),
        padding,
        Text('쉽게 로그인하고', style: mediumText?.copyWith(fontSize: 22)),
        padding,
        Text('다양한 서비스를 이용해봐요', style: titleLarge?.copyWith(fontSize: 26)),
        SizedBox(height: 30),
      ],
    );
  }
}

class _Middle extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final VoidCallback onKakaoPressed;
  const _Middle({
    required this.onGooglePressed,
    required this.onApplePressed,
    required this.onKakaoPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> outlinebutton = [
      {
        'Image': 'assets/img/google.png',
        'Text': 'Google 로 시작하기',
        'OnPressed': onGooglePressed,
      },
      {
        'Image': 'assets/img/apple.png',
        'Text': 'Apple 로 시작하기',
        'OnPressed': onApplePressed,
      },
    ];
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0XFFFEE500),
            fixedSize: Size(350, 50),
            elevation: 0,
          ),
          onPressed: onKakaoPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/img/kakao.png'),
              ),
              Center(child: Text('카카오톡 으로 시작하기', style: mediumText)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children:
                outlinebutton
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            fixedSize: Size(350, 50),
                          ),
                          onPressed: item['OnPressed'] as VoidCallback,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(item['Image']),
                              ),
                              Center(
                                child: Text(item['Text'], style: mediumText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}

class _Bottom extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final VoidCallback onSigninPressed;
  final VoidCallback onLoginPressed;

  const _Bottom({
    required this.controllers,
    required this.onLoginPressed,
    required this.onSigninPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final extraThinText = Theme.of(context).textTheme.bodySmall;
    final baseButtonStyle = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );

    final List<Map<String, dynamic>> fields = [
      {
        'label': '아이디',
       // 'hint': '아이디를 입력하세요',
        'key': 'username',
        'obscure': false,
      },
      {
        'label': '비밀번호',
       // 'hint': '비밀번호를 입력하세요',
        'key': 'password',
        'obscure': true,
      },
    ];
    return Column(
      children: [
        Image.asset('assets/img/gridother.png'),
        ...fields
            .map(
              (item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 350,
                  height: 50,
                  child: TextField(
                    controller: controllers[item['key']],
                    cursorColor: Colors.black,
                    cursorRadius: Radius.circular(5.0),
                    cursorHeight: 24,
                    textAlign: TextAlign.center,
                    obscureText: item['obscure'],
                    decoration: InputDecoration(
                      labelText: item['label'],
                    //  hintText: item['hint'],
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color(0XFF4EA6AA),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0XFF4EA6AA),
            shape: baseButtonStyle,
            padding: EdgeInsets.symmetric(horizontal: 154, vertical: 17),
          ),
          onPressed: onLoginPressed,
          child: Text(
            '로그인',
            style: (mediumText ?? const TextStyle(fontSize: 20)).copyWith(
              color: Colors.white,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('계정이 없으시다면', style: extraThinText),
            TextButton(
              onPressed: onSigninPressed,
              child: Column(
                children: [
                  Text(
                    '회원가입하기',
                    style: extraThinText?.copyWith(color: Color(0XFF4EA6AA)),
                  ),
                  Container(
                    width: 84,
                    height: 1,
                    color: Color(0XFF4EA6AA),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
