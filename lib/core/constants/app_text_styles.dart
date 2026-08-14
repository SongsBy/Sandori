import 'package:flutter/material.dart';

/// 디자인 시스템 타이포그래피 토큰.
///
/// 시안의 역할명(Title01 / Number01 / Caption01 …)을 그대로 옮겼다.
/// 화면에서 `fontSize`·`fontWeight`를 직접 쓰지 말고 여기서 가져다 쓴다.
///
/// 굵기는 [pubspec.yaml]에 등록된 Pretendard 6종에 정확히 대응한다.
/// Light 300 / Regular 400 / Medium 500 / SemiBold 600 / Bold 700 / Black 900.
/// 등록되지 않은 굵기(w800 등)를 쓰면 가장 가까운 굵기로 대체되므로 쓰지 않는다.
class AppTextStyles {
  AppTextStyles._();

  /// 숫자가 세로로 정렬돼야 하는 곳(가격·시간·카운트)에서 자릿수 흔들림을 막는다.
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // ── Display ──────────────────────────────────────────────────
  // 시안에는 없는 확장. 시안 최대가 24px라 히어로 카드(다음 셔틀까지 남은
  // 시간)를 표현할 단계가 없다. 화면당 하나만 쓴다.

  /// 히어로 숫자 — 남은 시간처럼 멀리서도 읽혀야 하는 값
  static const display01 = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    fontFeatures: _tabular,
  );

  /// 히어로 텍스트 — 숫자를 대신하는 상태 문구("곧 도착")
  static const display02 = TextStyle(fontSize: 30, fontWeight: FontWeight.w700);

  // ── Title ────────────────────────────────────────────────────
  // 제목 굵기는 시안(Semibold)보다 한 단계씩 올렸다. 시안대로 두면 본문
  // (Medium 500)과 차이가 작아 화면에서 제목이 제목으로 읽히지 않는다.

  /// 화면 대표 제목
  static const title01 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);

  /// 섹션 헤더 · 앱바 타이틀
  static const title02 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);

  /// 카드 제목
  static const title03 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  /// 제목 아래 보조 문장
  static const subtitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

  /// 본문. 시안에는 없는 확장 — Sub-title이 Medium이라 순수 본문용 Regular이
  /// 없어서 메뉴 항목·설명문이 필요 이상으로 강조되는 문제가 있었다.
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);

  // ── Number ───────────────────────────────────────────────────
  /// 강조 수치 (남은 시간, 개수)
  static const number01 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );

  /// 일반 수치 (가격, 시각)
  static const number02 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  // ── Button ───────────────────────────────────────────────────
  static const button = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  // ── Caption ──────────────────────────────────────────────────
  /// 칩 · 뱃지
  static const caption01 = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

  /// 하단 네비 라벨
  static const caption02 = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  /// 날짜 · 부가 설명
  static const caption03 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);

  /// 뱃지 · 상태 pill · 조밀한 메타데이터. 시안에는 없는 확장 —
  /// 시안 최소 크기가 14px인데 실제 화면에는 11~13px가 40곳 있었다.
  /// 14px로 올리면 칩과 뱃지가 레이아웃을 밀어내므로 12px 단계를 둔다.
  /// 접근성 하한이므로 이보다 작은 값은 쓰지 않는다.
  static const caption04 = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}
