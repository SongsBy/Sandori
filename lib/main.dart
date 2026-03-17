import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:handori/core/router/app_router.dart';
import 'package:handori/repository/empty_class_repository.dart';
import 'package:handori/repository/static_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<StaticDataRepository>(() => StaticDataRepository());
  getIt.registerLazySingleton<EmptyClassRepository>(() => FakeEmptyClassRepository());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          displayMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          bodySmall: TextStyle(fontWeight: FontWeight.w300, color: Colors.black, fontSize: 16),
          titleLarge: TextStyle(fontFamily: 'Krub', fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}