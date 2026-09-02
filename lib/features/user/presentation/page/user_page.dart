import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/common/component/app_top_bar.dart';
import 'package:handori/common/component/coming_soon_snackbar.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/auth/presentation/provider/auth_provider.dart';
import 'package:handori/shared/widget/sandol_loading_indicator.dart';

/// 유저 상세(설정) 페이지.
///
/// 프로필 카드에는 로그인된 계정의 이메일 로컬파트를 아이디로 매핑해 보여주고
/// (AuthSession.displayId), 로그아웃·회원탈퇴가 실제 Keycloak 세션/계정에
/// 반영된다. 알림 토글은 서버 연동 전이라 화면 내 상태만 유지한다.
class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  bool _pushEnabled = true;
  bool _benefitEnabled = true;
  bool _marketingEnabled = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: '유저 상세',
        onBack: () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _ProfileCard(
            name: session?.displayId ?? '게스트',
            email: session?.email ?? session?.username ?? '로그인이 필요합니다',
          ),
          const SizedBox(height: 20),
          _Section(
            label: '알림 설정',
            children: [
              _ToggleRow(
                icon: Icons.notifications_none_rounded,
                label: '푸시 알림',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
              _ToggleRow(
                icon: Icons.card_giftcard_rounded,
                label: '혜택 · 이벤트 알림',
                value: _benefitEnabled,
                onChanged: (v) => setState(() => _benefitEnabled = v),
              ),
              _ToggleRow(
                icon: Icons.campaign_outlined,
                label: '마케팅 정보 수신',
                value: _marketingEnabled,
                onChanged: (v) => setState(() => _marketingEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            label: '고객 지원',
            children: [
              _LinkRow(
                icon: Icons.campaign_outlined,
                label: '공지사항',
                onTap: () => context.go(RoutePaths.notice),
              ),
              _LinkRow(
                icon: Icons.help_outline_rounded,
                label: '자주 묻는 질문',
                onTap: () => showComingSoonSnackBar(context),
              ),
              _LinkRow(
                icon: Icons.chat_bubble_outline_rounded,
                label: '1:1 문의',
                onTap: () => showComingSoonSnackBar(context),
              ),
              _LinkRow(
                icon: Icons.info_outline_rounded,
                label: '서비스 안내',
                onTap: () => showComingSoonSnackBar(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            label: '기타',
            children: [
              _LinkRow(
                icon: Icons.description_outlined,
                label: '약관 및 정책',
                onTap: () => showComingSoonSnackBar(context),
              ),
              const _LinkRow(
                icon: Icons.info_outline_rounded,
                label: '앱 버전',
                // pubspec.yaml version 과 함께 갱신한다.
                trailingText: 'v1.0.0 · 최신',
              ),
              _LinkRow(
                icon: Icons.logout_rounded,
                label: '로그아웃',
                labelColor: AppColors.danger,
                onTap: _confirmLogout,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _confirmDeleteAccount,
              child: const Text(
                '회원 탈퇴',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 로그아웃 ──────────────────────────────────────────────────

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .5),
      builder: (context) => const _ConfirmDialog(
        icon: Icons.logout_rounded,
        title: '로그아웃',
        message: '정말 로그아웃하시겠어요?\n언제든 다시 로그인할 수 있어요.',
        confirmLabel: '로그아웃',
      ),
    );
    if (confirmed != true || !mounted) return;

    await _runBlocking(() => ref.read(authNotifierProvider.notifier).logout());
    if (!mounted) return;
    context.go(RoutePaths.login);
  }

  // ── 회원 탈퇴 ─────────────────────────────────────────────────

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .5),
      builder: (context) => const _ConfirmDialog(
        icon: Icons.person_off_outlined,
        title: '회원 탈퇴',
        message: '계정이 영구적으로 삭제되며\n되돌릴 수 없습니다. 정말 탈퇴하시겠어요?',
        confirmLabel: '탈퇴하기',
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _runBlocking(
        () => ref.read(authNotifierProvider.notifier).deleteAccount(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원 탈퇴가 완료되었습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(RoutePaths.login);
    } catch (_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: .5),
        builder: (context) => const _ConfirmDialog(
          icon: Icons.error_outline_rounded,
          title: '탈퇴 실패',
          message: '계정 삭제 요청이 실패했습니다.\n잠시 후 다시 시도하거나 관리자에게 문의해 주세요.',
          confirmLabel: '확인',
          showCancel: false,
        ),
      );
    }
  }

  /// 진행 중 다이얼로그를 띄운 채 [task] 를 수행한다. 예외는 그대로 올린다.
  Future<void> _runBlocking(Future<void> Function() task) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: .5),
      builder: (_) => const Center(child: SandolLoadingIndicator()),
    );
    try {
      await task();
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

// ── 확인 다이얼로그 ──────────────────────────────────────────────
//
// 기본 AlertDialog(밋밋한 흰 배경 + 텍스트 버튼) 대신 앱 톤에 맞춘
// 커스텀 다이얼로그. 상단에 옅은 붉은 원 안의 아이콘, 가운데 정렬 제목·설명,
// 하단에 [취소 · 확인] 버튼 쌍(파괴적 동작은 붉은 채움 버튼)을 둔다.

class _ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final bool showCancel;

  const _ConfirmDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withValues(alpha: .08),
              ),
              child: Icon(icon, size: 28, color: AppColors.danger),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (showCancel) ...[
                  Expanded(
                    child: _DialogButton(
                      label: '취소',
                      background: const Color(0xFFF2F3F5),
                      foreground: AppColors.textSecondary,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    background: AppColors.danger,
                    foreground: Colors.white,
                    onTap: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 프로필 카드 ─────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white.withValues(alpha: .4),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_rounded,
              size: 32,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: .85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 (라벨 + 흰 카드) ────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── 토글 행 ────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 21, color: AppColors.textPrimary),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _TogglePill(value: value),
          ],
        ),
      ),
    );
  }
}

/// 시안(48x28 필, 22px 흰 노브)에 맞춘 커스텀 토글.
class _TogglePill extends StatelessWidget {
  final bool value;

  const _TogglePill({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? AppColors.primary : const Color(0xFFD6D8DD),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .2),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 링크 행 ────────────────────────────────────────────────────

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color labelColor;
  final String? trailingText;
  final VoidCallback? onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    this.labelColor = AppColors.textPrimary,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 21, color: labelColor),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFFBDBDBD),
              ),
          ],
        ),
      ),
    );
  }
}
