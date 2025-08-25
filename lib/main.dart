import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:handori/repository/static_repository.dart';
import 'package:handori/screen/home_screen.dart';
import 'package:handori/screen/splashScreen.dart';

void main() {
  GetIt.I.registerSingleton<StaticDataRepository>(StaticDataRepository());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splashscreen(),
      theme: ThemeData(
        fontFamily: 'Pretendard',
            textTheme: TextTheme(
              displayLarge: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 30,
              ),
              displayMedium: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              bodySmall: TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.black,
                fontSize: 16,
              ),

              titleLarge: TextStyle(
                fontFamily: 'Krub',
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w700
              )
      ),
      ),
    );
  }
}


