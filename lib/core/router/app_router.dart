import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/notice/domain/model/notice.dart';
import 'package:handori/features/notice/presentation/page/notice_detail_page.dart';
import 'package:handori/screen/LoginScreen.dart';
import 'package:handori/screen/SignInGateScreen.dart';
import 'package:handori/screen/SigninScreen.dart';
import 'package:handori/screen/maain_shell.dart';
import 'package:handori/screen/splashScreen.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (_, __) => const Splashscreen(),
    ),
    GoRoute(
      path: RoutePaths.gate,
      builder: (_, __) => const SignInGateScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      builder: (_, __) => const Loginscreen(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (_, __) => const Signinscreen(),
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.main,
      builder: (_, __) => const MainShell(),
    ),
    GoRoute(
      path: RoutePaths.noticeDetail,
      builder: (context, state) {
        final notice = state.extra as Notice;
        return NoticeDetailPage(notice: notice);
      },
    ),
  ],
);
