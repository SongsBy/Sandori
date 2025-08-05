import 'package:flutter/material.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  String passwordCheckText ='';
  bool isChecked = false;

  final List<Map<String, dynamic>> signintext = [
    {'header': '이름', 'obscure' : false, 'showicon': false, 'controller': TextEditingController()},
    {'header': '아이디','obscure' : false, 'showicon': false, 'controller': TextEditingController()},
    {'header': '비밀번호','obscure' : true, 'showicon': true, 'controller': TextEditingController()},
    {'header': '비밀번호 확인','obscure' : true, 'showicon': true, 'controller': TextEditingController()},
  ];

  final List<Map<String, dynamic>> agreeText = [
    {'title': '이용 약관 동의(필수)','checked': false},
    {'title': '개인정보 수집 동의(필수)','checked': false},
    {'title': '개인정보 수집 동의(선택)','checked': false},
    {'title': '혜택/알림 정보 수신 동의(선택)','checked': false},
  ];

  @override
  initState(){
    super.initState();
    signintext[2]['controller'].addListener(_checkPasswordMatch);
    signintext[3]['controller'].addListener(_checkPasswordMatch);
  }

  void _checkPasswordMatch(){
    final pw = signintext[2]['controller'].text;
    final res = signintext[3]['controller'].text;

    setState(() {
      if(res.isEmpty)
      {
        passwordCheckText = '비밀번호가 다릅니다';
      }else if (pw == res)
      {
        passwordCheckText = '비밀번호가 일치합니다!';
      }else
      {
        passwordCheckText = '비밀번호가 다릅니다';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final largeText = Theme.of(context).textTheme.displayLarge;
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    final baseButtonStyle = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );


    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: (){
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36.0,
                        vertical: 36.0,
                      ),
                      child: Text(
                        '회원가입',
                        style: titleLarge?.copyWith(fontSize: 25),
                      ),
                    ),

                    Column(
                      children: signintext
                          .asMap()
                          .entries
                          .map(
                            (entry) {
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
                                      suffixIcon: item['showicon']
                                          ? IconButton(
                                        onPressed: () {
                                          setState(() {
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
                                        borderSide: BorderSide(
                                          color: Color(0XFF4EA6AA),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (index == 3)
                                Text(
                                  passwordCheckText,
                                  style: TextStyle(
                                      color: passwordCheckText.contains('일치') ? Colors.green : Colors.red
                                  ),
                                )
                            ],
                          );
                        },
                      ).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 27.0),
                      child: Image.asset('assets/img/headertext.png'),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 27.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: agreeText
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical:1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(item['title'], style: mediumText),
                                Checkbox(
                                  value: item['checked'],
                                  onChanged: (bool? value) {
                                    setState(() {
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
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFF4EA6AA),
                        shape: baseButtonStyle,
                        padding: EdgeInsets.symmetric(horizontal: 120, vertical: 17),
                      ),
                      onPressed: (){},
                      child: Text(
                          '회원가입하기',
                          style: mediumText?.copyWith(color: Colors.white)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
