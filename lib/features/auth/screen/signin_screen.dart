import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  String passwordCheckText = '';

  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pwCtrl.addListener(_checkPasswordMatch);
    _pwConfirmCtrl.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    final pw = _pwCtrl.text;
    final res = _pwConfirmCtrl.text;

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
    const padding = SizedBox(height: 30);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: const Alignment(0, 1),
                child: Column(w
                  children: [
                    /// 상단
                    const _Top(),
                    /// 텍스트 필드
                    _SigninTextFields(
                      nameCtrl: _nameCtrl,
                      idCtrl: _idCtrl,
                      pwCtrl: _pwCtrl,
                      pwConfirmCtrl: _pwConfirmCtrl,
                      passwordCheckText: passwordCheckText,
                    ),
                    /// 구분선
                    line,
                    /// 체크 박스
                    const _AgreeCheckBoxes(),
                    padding,
                    /// 하단
                    _Bottom(onSigninPressed: _onSigninPressed),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSigninPressed() => context.go(RoutePaths.login);
}

/// 상단 위젯
class _Top extends StatelessWidget {
  const _Top();

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 36.0),
      child: Text('회원가입', style: titleLarge?.copyWith(fontSize: 25)),
    );
  }
}

/// 텍스트 입력 필드 위젯 — obscure 토글을 자체 관리
class _SigninTextFields extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController idCtrl;
  final TextEditingController pwCtrl;
  final TextEditingController pwConfirmCtrl;
  final String passwordCheckText;

  const _SigninTextFields({
    required this.nameCtrl,
    required this.idCtrl,
    required this.pwCtrl,
    required this.pwConfirmCtrl,
    required this.passwordCheckText,
  });

  @override
  State<_SigninTextFields> createState() => _SigninTextFieldsState();
}

class _SigninTextFieldsState extends State<_SigninTextFields> {
  bool _obscurePw = true;
  bool _obscurePwConfirm = true;

  @override
  Widget build(BuildContext context) {
    final fields = [
      _FieldConfig('이름', widget.nameCtrl, false, false),
      _FieldConfig('아이디', widget.idCtrl, false, false),
      _FieldConfig('비밀번호', widget.pwCtrl, _obscurePw, true),
      _FieldConfig('비밀번호 확인', widget.pwConfirmCtrl, _obscurePwConfirm, true),
    ];

    return Column(
      children: fields.asMap().entries.map((entry) {
        final index = entry.key;
        final field = entry.value;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 300,
                height: 60,
                child: TextField(
                  controller: field.controller,
                  obscureText: field.obscure,
                  decoration: InputDecoration(
                    labelText: field.label,
                    suffixIcon: field.showIcon
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                if (index == 2) {
                                  _obscurePw = !_obscurePw;
                                } else {
                                  _obscurePwConfirm = !_obscurePwConfirm;
                                }
                              });
                            },
                            icon: SizedBox(
                              width: 20,
                              height: 20,
                              child: Image.asset('assets/img/pwicon.png'),
                            ),
                          )
                        : null,
                    labelStyle: const TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Color(0XFF00C4F9)),
                    ),
                  ),
                ),
              ),
            ),
            if (index == 3)
              Text(
                widget.passwordCheckText,
                style: TextStyle(
                  color: widget.passwordCheckText.contains('일치')
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

class _FieldConfig {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final bool showIcon;

  _FieldConfig(this.label, this.controller, this.obscure, this.showIcon);
}

/// 체크박스 위젯 — 체크 상태를 자체 관리
class _AgreeCheckBoxes extends StatefulWidget {
  const _AgreeCheckBoxes();

  @override
  State<_AgreeCheckBoxes> createState() => _AgreeCheckBoxesState();
}

class _AgreeCheckBoxesState extends State<_AgreeCheckBoxes> {
  final List<_AgreeItem> _items = [
    _AgreeItem('이용 약관 동의(필수)'),
    _AgreeItem('개인정보 수집 동의(필수)'),
    _AgreeItem('개인정보 수집 동의(선택)'),
    _AgreeItem('혜택/알림 정보 수신 동의(선택)'),
  ];

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(item.title, style: mediumText),
                Checkbox(
                  value: item.checked,
                  onChanged: (bool? value) {
                    setState(() => _items[index].checked = value!);
                  },
                  activeColor: const Color(0XFF00C4F9),
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

class _AgreeItem {
  final String title;
  bool checked = false;

  _AgreeItem(this.title);
}

/// 하단 위젯
class _Bottom extends StatelessWidget {
  final VoidCallback onSigninPressed;
  const _Bottom({required this.onSigninPressed});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final baseButtonStyle = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0XFF95E0F4),
        shape: baseButtonStyle,
        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 17),
      ),
      onPressed: onSigninPressed,
      child: Text(
        '회원가입하기',
        style: mediumText?.copyWith(color: Colors.black),
      ),
    );
  }
}
