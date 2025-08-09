import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:handori/screen/SignInGateScreen.dart';
import 'package:handori/screen/home_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}
class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      _navigateToGate();
    });
  }
  ///페이지 전환 함수
  void _navigateToGate (){
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => SignInGateScreen())
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
            children: [
              ///배경 색
              const _ShowBackground(),
              ///로고 이미지
              _Logo()
            ],
          ),
    );
  }
}


///배경 색 지정
class _ShowBackground extends StatelessWidget {
  const _ShowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF95E0F4), Color(0xFFB2F0E8)]
      ),
      ),
    );
  }
}


///로고 이미지
class _Logo extends StatelessWidget {
  const _Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child:   Image.asset('assets/img/logo1.png', width: 140,height: 140,),
    );
  }
}
