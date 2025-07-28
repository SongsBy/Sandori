import 'package:flutter/material.dart';
import 'package:handori/screen/home_screen.dart';
import 'package:handori/screen/splashScreen.dart';

void main() {
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
        fontFamily: 'Krub',
            textTheme: TextTheme(

              displayLarge: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 30,
              ),

              displayMedium: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 20,
              ),

      ),

      ),
    );
  }
}


