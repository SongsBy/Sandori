import 'package:flutter/material.dart';

/// 앱 전체 색상 토큰.
///
/// 화면에서 `Color(0xFF...)`를 직접 쓰지 말고 여기서 가져다 쓴다.
/// 이전에는 화면마다 primary가 제각각이었다(#0088CC / #00C4F9 / #5C6BC0 /
/// #3CB7BE / #26C6DA). 홈 화면 팔레트를 기준으로 [primary] 하나로 통일했다.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────
  /// 강조색. 링크 · 선택 상태 · 가격 · 활성 탭.
  /// 한 화면에서 넓은 면적을 채우는 용도로는 쓰지 않는다.
  static const primary = Color(0xFF0088CC);

  /// 아이콘 칩 · 뱃지의 옅은 배경
  static const primaryLight = Color(0xFFE6F9FF);

  /// primaryLight 위에 얹는 테두리
  static const primaryBorder = Color(0xFFBDE8F6);

  // ── Surface ──────────────────────────────────────────────────
  /// 화면 배경. 카드(흰색)보다 한 톤 어두워 카드가 떠 보인다.
  static const background = Color(0xFFFAFAFA);

  /// 카드 · 시트 배경
  static const surface = Colors.white;

  /// 카드 안에서 한 단계 들어간 영역(메뉴 박스 등)
  static const subtleBg = Color(0xFFF7FBFD);

  /// 카드 테두리
  static const cardBorder = Color(0xFFE2EEF3);

  /// 구분선 · 옅은 경계
  static const divider = Color(0xFFF0F0F8);

  // ── Text ─────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7A89);

  /// 보조 설명 · 비활성 라벨
  static const textMuted = Color(0xFF8A8F98);

  // ── Semantic ─────────────────────────────────────────────────
  // 상태 표시 전용. 강조색([primary])과 역할이 다르므로 섞어 쓰지 않는다.

  /// 운영중 · 정상
  static const success = Color(0xFF2F8C3B);

  /// 준비중 · 주의
  static const warning = Color(0xFFFFB74D);

  /// 지연 · 오류. "운영종료"처럼 정상적인 종료 상태에는 쓰지 않는다.
  static const danger = Color(0xFFD63B3B);
}
