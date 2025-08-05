import 'package:flutter/material.dart';
import 'package:handori/screen/LoginScreen.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  String passwordCheckText = '';
  bool isChecked = false;

  final List<Map<String, dynamic>> signintext = [
    {
      'header': '이름',
      'obscure': false,
      'showicon': false,
      'controller': TextEditingController(),
    },
    {
      'header': '아이디',
      'obscure': false,
      'showicon': false,
      'controller': TextEditingController(),
    },
    {
      'header': '비밀번호',
      'obscure': true,
      'showicon': true,
      'controller': TextEditingController(),
    },
    {
      'header': '비밀번호 확인',
      'obscure': true,
      'showicon': true,
      'controller': TextEditingController(),
    },
  ];

  final List<Map<String, dynamic>> agreeText = [
    {'title': '이용 약관 동의(필수)', 'checked': false},
    {'title': '개인정보 수집 동의(필수)', 'checked': false},
    {'title': '개인정보 수집 동의(선택)', 'checked': false},
    {'title': '혜택/알림 정보 수신 동의(선택)', 'checked': false},
  ];

  @override
  initState() {
    super.initState();
    signintext[2]['controller'].addListener(_checkPasswordMatch);
    signintext[3]['controller'].addListener(_checkPasswordMatch);
  }

  void _checkPasswordMatch() {
    final pw = signintext[2]['controller'].text;
    final res = signintext[3]['controller'].text;

    setState(() {
      if (res.isEmpty) {
        passwordCheckText = '비밀번호가 다릅니다';
      } else if (pw == res) {
        passwordCheckText = '비밀번호가 일치합니다!';
      } else {
        passwordCheckText = '비밀번호가 다릅니다';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final line = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.0),
      child: Image.asset('assets/img/headertext.png'),
    );
    final padding = SizedBox(height: 30);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment(-0, 1),
                child: Column(
                  children: [
                    ///상단
                    _Top(),
                    ///텍스트 필드
                    _TextField(
                      signintext: signintext,
                      setStateCallback: setState,
                      passwordCheckText: passwordCheckText,
                    ),
                    ///구분선
                    line,
                    ///체크 박스
                    _CheckBox(agreeText: agreeText, setStateCallback: setState),
                    padding,
                    ///하단
                    _Bottom(onSigninPressed: onSigninPressed)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  ///회원 가입 버튼 함수
  void onSigninPressed(){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => Loginscreen(),
      ),
    );
  }
}
///상단위젯
class _Top extends StatefulWidget {
  const _Top({super.key});

  @override
  State<_Top> createState() => _TopState();
}

class _TopState extends State<_Top> {
  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 36.0),
      child: Text('회원가입', style: titleLarge?.copyWith(fontSize: 25)),
    );
  }
}
///텍스트 입력 필드 위젯
class _TextField extends StatelessWidget {
  final List<Map<String, dynamic>> signintext;
  final String passwordCheckText;
  final void Function(void Function()) setStateCallback;
  const _TextField({
    required this.signintext,
    required this.setStateCallback,
    required this.passwordCheckText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          signintext.asMap().entries.map((entry) {
            int index = entry.key;
            final item = entry.value;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 300,
                    height: 60,
                    child: TextField(
                      controller: item['controller'],
                      obscureText: item['obscure'],
                      decoration: InputDecoration(
                        labelText: item['header'],
                        suffixIcon:
                            item['showicon']
                                ? IconButton(
                                  onPressed: () {
                                    setStateCallback(() {
                                      signintext[index]['obscure'] =
                                          !signintext[index]['obscure'];
                                    });
                                  },
                                  icon: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Image.asset('assets/img/pwicon.png'),
                                  ),
                                )
                                : null,
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0XFF4EA6AA)),
                        ),
                      ),
                    ),
                  ),
                ),
                if (index == 3)
                  Text(
                    passwordCheckText,
                    style: TextStyle(
                      color:
                          passwordCheckText.contains('일치')
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
              ],
            );
          }).toList(),
    );
  }
}
///체크박스 위젯
class _CheckBox extends StatelessWidget {
  final List<Map<String, dynamic>> agreeText;
  final void Function(void Function()) setStateCallback;
  const _CheckBox({
  required this.agreeText,
  required this.setStateCallback,
  super.key,
});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        agreeText.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 1.0,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(item['title'], style: mediumText),
                Checkbox(
                  value: item['checked'],
                  onChanged: (bool? value) {
                    setStateCallback(() {
                      agreeText[index]['checked'] = value!;
                    });
                  },
                  activeColor: Color(0XFF4EA6AA),
                  checkColor: Colors.white,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
/// 하단 위젯
class _Bottom extends StatelessWidget {
  final VoidCallback onSigninPressed;
  const _Bottom({
    required this.onSigninPressed,
    super.key,
});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final baseButtonStyle = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0XFF4EA6AA),
        shape: baseButtonStyle,
        padding: EdgeInsets.symmetric(
          horizontal: 120,
          vertical: 17,
        ),
      ),
      onPressed: onSigninPressed,
      child: Text(
        '회원가입하기',
        style: mediumText?.copyWith(color: Colors.white),
      ),
    );
  }
}


