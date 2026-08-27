import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/auth/presentation/provider/auth_provider.dart';
import 'package:handori/shared/widget/sandol_loading_indicator.dart';

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
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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
      body: SafeArea(
        child: Stack(
          children: [
            // 중앙 로딩 인디케이터 (페이드인 + 스케일 애니메이션)
            FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scale,
                child: const Center(
                  child: SandolLoadingIndicator(size: 140),
                ),
              ),
            ),

            // 하단 텍스트 로고
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Image.asset('assets/img/sandol_text.png', width: 80),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

