import 'package:flutter/material.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    final largeText = Theme.of(context).textTheme.displayLarge;
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final extraThinText = Theme.of(context).textTheme.bodySmall;
    final padding = SizedBox(height: 10);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment(-0.1, 0),
          child: Column(
            children: [
              SizedBox(height: 40),
              Image.asset('assets/img/logo.png'),
              padding,
              Text('쉽게 로그인하고', style: mediumText?.copyWith(fontSize: 22)),
              padding,
              Text('다양한 서비스를 이용해봐요', style: largeText?.copyWith(fontSize: 22)),

              ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: Color(0XFFFEE500),),
                onPressed: () {},
                child: Row(
                    children: [
                      Image.asset('assets/img/kakao.png'),
                      Text('카카오톡으로 시작하기', style: TextStyle(color: Colors.black),)
                    ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
