import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/auth/domain/model/auth_session.dart';
import 'package:handori/features/auth/presentation/provider/auth_provider.dart';
import 'package:handori/shared/widget/sandol_loading_indicator.dart';

/// 로그인 화면.
///
/// 두 버튼 모두 Keycloak(OIDC Authorization Code + PKCE) 브라우저 플로우를
/// 타고, 딥링크로 돌아와 토큰을 받는다.
/// - 카카오: `kc_idp_hint=kakao` 로 카카오 로그인 직행
/// - 아이디: Keycloak 로그인 페이지(아이디/비밀번호 폼)
class Loginscreen extends ConsumerWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 로그인 실패(취소 제외)는 스낵바로 알린다.
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했어요. 잠시 후 다시 시도해주세요.')),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final session = authState.valueOrNull;
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // 로고·문구·버튼을 한 덩어리로 화면 정중앙에 배치.
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Top(),
                const SizedBox(height: 48),
                session != null
                    ? _LoggedIn(
                        session: session,
                        onLogoutPressed: () =>
                            ref.read(authNotifierProvider.notifier).logout(),
                      )
                    : _LoginButtons(
                        isLoading: isLoading,
                        onKakaoPressed: () => _login(context, ref, kakao: true),
                        onIdPressed: () => _login(context, ref, kakao: false),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(
    BuildContext context,
    WidgetRef ref, {
    required bool kakao,
  }) async {
    final success =
        await ref.read(authNotifierProvider.notifier).login(useKakao: kakao);
    if (success && context.mounted) context.go(RoutePaths.home);
  }
}

class _Top extends StatelessWidget {
  const _Top();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Image.asset('assets/img/sandol_logo.png', width: 140),
        const SizedBox(height: 24),
        Text(
          '로그인하고 더 똑똑한\n학교생활을 시작해요',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(fontSize: 24, height: 1.35),
        ),
        const SizedBox(height: 10),
        Text(
          '오늘의 학식부터 셔틀, 빈 강의실까지 한 번에',
          style: textTheme.displayMedium?.copyWith(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _LoginButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onKakaoPressed;
  final VoidCallback onIdPressed;

  const _LoginButtons({
    required this.isLoading,
    required this.onKakaoPressed,
    required this.onIdPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    final extraThinText = Theme.of(context).textTheme.bodySmall;

    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0XFFFEE500),
            fixedSize: const Size(350, 50),
            elevation: 0,
          ),
          onPressed: isLoading ? null : onKakaoPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/img/kakao.png'),
              ),
              Center(child: Text('카카오톡 으로 시작하기', style: mediumText)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(fixedSize: const Size(350, 50)),
            onPressed: isLoading ? null : onIdPressed,
            child: Text('아이디로 로그인', style: mediumText),
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: SandolLoadingIndicator(),
          )
        else
          /// 로그인은 선택 — 비로그인으로도 모든 탭을 쓸 수 있다.
          TextButton(
            onPressed: () => context.go(RoutePaths.home),
            child: Text(
              '로그인 없이 둘러보기',
              style: extraThinText?.copyWith(
                fontSize: 15,
                color: const Color(0XFF00C4F9),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0XFF95E0F4),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoggedIn extends StatelessWidget {
  final AuthSession session;
  final VoidCallback onLogoutPressed;

  const _LoggedIn({required this.session, required this.onLogoutPressed});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Column(
      children: [
        Text(
          '${session.username ?? '사용자'}님, 이미 로그인되어 있어요',
          style: mediumText?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0XFF95E0F4),
            fixedSize: const Size(350, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => context.go(RoutePaths.home),
          child: Text(
            '홈으로 가기',
            style: mediumText?.copyWith(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: onLogoutPressed,
          child: Text(
            '로그아웃',
            style: mediumText?.copyWith(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
