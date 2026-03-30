import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/notice/domain/model/notice.dart';
import 'package:handori/features/notice/presentation/page/notice_detail_page.dart';
import 'package:handori/features/auth/screen/login_screen.dart';
import 'package:handori/features/auth/screen/sign_in_gate_screen.dart';
import 'package:handori/features/auth/screen/signin_screen.dart';
import 'package:handori/common/layout/root_tab.dart';
import 'package:handori/features/home/screen/splash_screen.dart';
import 'package:handori/features/organization/presentation/page/organization_tree_page.dart';
import 'package:handori/features/organization/presentation/page/organization_search_page.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (_, _) => const Splashscreen(),
    ),
    GoRoute(
      path: RoutePaths.gate,
      builder: (_, _) => const SignInGateScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      builder: (_, _) => const Loginscreen(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (_, _) => const Signinscreen(),
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.main,
      builder: (_, _) => const RootTab(),
    ),
    GoRoute(
      path: RoutePaths.noticeDetail,
      builder: (context, state) {
        final notice = state.extra as Notice;
        return NoticeDetailPage(notice: notice);
      },
    ),
    GoRoute(
      path: RoutePaths.organization,
      builder: (_, _) => const OrganizationTreePage(),
    ),
    GoRoute(
      path: RoutePaths.organizationSearch,
      builder: (_, state) {
        final query = state.extra as String? ?? '';
        return OrganizationSearchPage(query: query);
      },
    ),
  ],
);
