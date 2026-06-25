import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';

/// 셔틀버스 시간표 원본(하드코딩) 데이터 소스.
///
/// 출발 시각은 가독성을 위해 HHMM 정수(예: 1015 → 10:15) 리스트로 정의하고,
/// [_fixed] 헬퍼로 도메인 [ShuttleEntry]로 변환한다.
///
/// 운행 정책 요약:
/// - 노선1(정왕역↔본교): 평일 전용. 토/일/공휴일 미운행.
/// - 노선2(제2캠퍼스↔본교·정왕역): 평일·토요일 운행. 일/공휴일 미운행.
class ShuttleScheduleData {
  const ShuttleScheduleData._();

  /// 도착버스 탑승 시간대(17:00 이후) 승차 위치 안내.
  /// 정해진 시간표 없이 정왕역에 도착한 버스를 그대로 탑승한다.
  static const String _arrivalBoardingNote =
      '파리바게뜨 건너편 정류장에서 도착 버스 탑승 (막차 약 53분경)';

  // ── 노선1: 정왕역 → 학교 (등교) · 평일 ───────────────────────────────────
  // 정해진 시간 운행: 08:41 ~ 16:50. 17:00 이후는 별도 시간표 없이 도착버스 탑승.
  static final List<ShuttleEntry> _route1UpWeekday = [
    ..._fixed([
      841, 859, //
      905, 915, 920, 935, 950, //
      1000, 1020, 1035, 1055, //
      1110, 1130, 1150, //
      1210, 1230, 1250, //
      1310, 1320, 1335, 1350, //
      1410, 1430, 1450, //
      1510, 1530, 1550, //
      1610, 1630, 1650,
    ]),
    ShuttleEntry.arrivalBoarding(
      const ShuttleTime(17, 0),
      const ShuttleTime(20, 53), // 막차 약 53분경
      boardingNote: _arrivalBoardingNote,
    ),
  ];

  // ── 노선1: 학교 → 정왕역 (하교) · 평일 ───────────────────────────────────
  // 운행 시간대: 09:10 ~ 20:10. 전 시간대 정시 출발.
  static final List<ShuttleEntry> _route1DownWeekday = _fixed([
    910, 925, 950, //
    1010, 1025, 1045, //
    1100, 1120, 1140, //
    1200, 1220, 1240, //
    1300, 1310, 1325, 1340, //
    1400, 1420, 1440, //
    1500, 1520, 1540, //
    1600, 1620, 1640, 1650, //
    1700, 1720, 1740, 1750, //
    1800, 1820, 1840, 1850, //
    1905, 1925, 1945, //
    2010,
  ]);

  // ── 노선2: 본교 → 제2캠퍼스 ─────────────────────────────────────────────
  // 평일 첫 2회(08:55, 09:00)는 정왕역 출발.
  static final List<ShuttleEntry> _route2ToCampusWeekday = _fixed([
    855, 900, 1000, 1100, 1200, 1300, //
    1400, 1500, 1600, 1700, 1800, 1900,
  ]);

  // 토요일: 정왕역 → 본교 → 제2캠퍼스.
  static final List<ShuttleEntry> _route2ToCampusSaturday = _fixed([
    845, 850, 900, 905, 910, 915,
  ]);

  // ── 노선2: 제2캠퍼스 → 본교 ─────────────────────────────────────────────
  // 평일 17:40 편은 오이도역 경유.
  static final List<ShuttleEntry> _route2FromCampusWeekday = _fixed([
    940, 1030, 1130, 1230, 1330, 1430, //
    1530, 1630, 1740, 1830, 1930,
  ]);

  // 토요일: 제2캠퍼스 → 본교 → 정왕역.
  static final List<ShuttleEntry> _route2FromCampusSaturday = _fixed([
    1630, 1645, 1925, 1928, 1930, 1935, 1945,
  ]);

  /// HHMM 정수 리스트를 정시 출발 [ShuttleEntry] 리스트로 변환.
  static List<ShuttleEntry> _fixed(List<int> hhmmList) => hhmmList
      .map((hhmm) => ShuttleEntry.fixed(ShuttleTime.fromHhmm(hhmm)))
      .toList(growable: false);

  /// 날짜 → 요일 구분. 토요일은 [ShuttleDayType.saturday],
  /// 일요일은 [ShuttleDayType.holiday]로 본다(공휴일 별도 판정은 미지원).
  static ShuttleDayType dayTypeOf(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return ShuttleDayType.saturday;
      case DateTime.sunday:
        return ShuttleDayType.holiday;
      default:
        return ShuttleDayType.weekday;
    }
  }

  /// (노선·방향·요일)에 해당하는 시간표. 미운행이면 null.
  static ShuttleTimetable? timetableFor({
    required ShuttleRoute route,
    required ShuttleDirection direction,
    required ShuttleDayType dayType,
  }) {
    final entries = _entriesFor(route, direction, dayType);
    if (entries == null) return null;
    return ShuttleTimetable(
      route: route,
      direction: direction,
      dayType: dayType,
      entries: entries,
    );
  }

  static List<ShuttleEntry>? _entriesFor(
    ShuttleRoute route,
    ShuttleDirection direction,
    ShuttleDayType dayType,
  ) {
    if (route == ShuttleRoute.route1) {
      // 노선1은 평일 전용.
      if (dayType != ShuttleDayType.weekday) return null;
      switch (direction) {
        case ShuttleDirection.jeongwangToSchool:
          return _route1UpWeekday;
        case ShuttleDirection.schoolToJeongwang:
          return _route1DownWeekday;
        default:
          return null;
      }
    }

    // 노선2는 평일·토요일 운행.
    if (dayType == ShuttleDayType.holiday) return null;
    switch (direction) {
      case ShuttleDirection.schoolToCampus2:
        return dayType == ShuttleDayType.saturday
            ? _route2ToCampusSaturday
            : _route2ToCampusWeekday;
      case ShuttleDirection.campus2ToSchool:
        return dayType == ShuttleDayType.saturday
            ? _route2FromCampusSaturday
            : _route2FromCampusWeekday;
      default:
        return null;
    }
  }
}
