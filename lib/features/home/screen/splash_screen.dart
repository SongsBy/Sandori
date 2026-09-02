import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/auth/presentation/provider/auth_provider.dart';

class Splashscreen extends ConsumerStatefulWidget {
  const Splashscreen({super.key});

  @override
  ConsumerState<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends ConsumerState<Splashscreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    // 배경 이미지가 화면을 덮은 채 살짝 줌아웃되는 효과 (가장자리 노출 없음)
    _scale = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(seconds: 2), _navigateNext);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 페이지 전환: 이미 로그인돼 있으면 홈, 아니면 로그인 화면으로.
  /// (로그인 화면에서 "로그인 없이 둘러보기"로 건너뛸 수 있다.)
  Future<void> _navigateNext() async {
    final session = await ref.read(authNotifierProvider.future);
    if (!mounted) return;
    context.go(session != null ? RoutePaths.home : RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///배경 색
      backgroundColor: const Color(0xFF4A90E2),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 전체 화면 스플래시: 상하 여백 없이 꽉 채움 (화면이 이미지보다
          // 길쭉한 기기에서는 좌우가 약간 잘린다). 페이드인 + 줌아웃.
          FadeTransition(
            opacity: _fadeIn,
            child: ScaleTransition(
              scale: _scale,
              child: Image.asset(
                'assets/img/splash.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 하단 텍스트 로고
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Image.asset('assets/img/sandol_text.png', width: 80),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

