/// 셔틀버스 시간표 도메인 모델.
///
/// 순수 도메인 계층. 시간 계산/표시 로직(Provider, UI)은 이 모델만 참조한다.
library;

/// 노선 구분.
/// - [route1] 정왕역 ↔ 본교 (평일 전용)
/// - [route2] 제2캠퍼스 ↔ 본교·정왕역 (평일·토요일)
enum ShuttleRoute { route1, route2 }

/// 운행 방향.
enum ShuttleDirection {
  /// 정왕역 → 학교 (등교) — 화면 토글 `학교 방면`
  jeongwangToSchool,

  /// 학교 → 정왕역 (하교) — 화면 토글 `정왕역 방면`
  schoolToJeongwang,

  /// 본교 → 제2캠퍼스
  schoolToCampus2,

  /// 제2캠퍼스 → 본교
  campus2ToSchool,
}

/// 요일 구분. 공휴일은 [holiday]로 취급(운행 없음).
enum ShuttleDayType { weekday, saturday, holiday }

/// 시간표 한 항목의 종류.
enum ShuttleEntryType {
  /// 정해진 출발 시각.
  fixed,

  /// 수시운행 — 정해진 시각 없이 구간 내 수시 운행.
  flexible,

  /// 도착버스 탑승 — 정시 출발표 없이, 도착한 버스를 그대로 탑승.
  arrivalBoarding,
}

/// 하루 기준 시:분. 자정부터의 분(minute-of-day)으로 환산해 비교에 사용한다.
class ShuttleTime {
  final int hour;
  final int minute;

  const ShuttleTime(this.hour, this.minute);

  /// HHMM 정수(예: 1015 → 10:15)로부터 생성. 시간표 데이터 작성용.
  factory ShuttleTime.fromHhmm(int hhmm) =>
      ShuttleTime(hhmm ~/ 100, hhmm % 100);

  /// 자정 기준 경과 분.
  int get minutesOfDay => hour * 60 + minute;

  /// "10:05" 형태 라벨.
  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// 시간표 한 항목. [type]에 따라 [time]/[endTime]/[boardingNote]의 의미가 달라진다.
class ShuttleEntry {
  final ShuttleEntryType type;

  /// fixed: 출발 시각 / flexible·arrivalBoarding: 구간 시작 시각.
  final ShuttleTime time;

  /// 구간 종료 시각(flexible·arrivalBoarding 전용). fixed는 null.
  final ShuttleTime? endTime;

  /// 승차 위치 등 부가 안내(arrivalBoarding 전용).
  final String? boardingNote;

  const ShuttleEntry._({
    required this.type,
    required this.time,
    this.endTime,
    this.boardingNote,
  });

  /// 정시 출발 항목.
  const ShuttleEntry.fixed(ShuttleTime time)
      : this._(type: ShuttleEntryType.fixed, time: time);

  /// 수시운행 구간 [start]~[end].
  const ShuttleEntry.flexible(ShuttleTime start, ShuttleTime end)
      : this._(type: ShuttleEntryType.flexible, time: start, endTime: end);

  /// 도착버스 탑승 구간 [start]~[end], 승차 위치 [boardingNote].
  const ShuttleEntry.arrivalBoarding(
    ShuttleTime start,
    ShuttleTime end, {
    required String boardingNote,
  }) : this._(
          type: ShuttleEntryType.arrivalBoarding,
          time: start,
          endTime: end,
          boardingNote: boardingNote,
        );

  /// 구간 항목 여부(flexible·arrivalBoarding).
  bool get isSegment => type != ShuttleEntryType.fixed;

  /// [nowMinutes]가 이 구간 항목 내부인지 여부. 구간이 아니면 false.
  bool covers(int nowMinutes) {
    final end = endTime;
    if (end == null) return false;
    return nowMinutes >= time.minutesOfDay && nowMinutes <= end.minutesOfDay;
  }
}

/// (노선·방향·요일) 단위 시간표. [entries]는 시작 시각 오름차순 정렬을 전제로 한다.
class ShuttleTimetable {
  final ShuttleRoute route;
  final ShuttleDirection direction;
  final ShuttleDayType dayType;
  final List<ShuttleEntry> entries;

  const ShuttleTimetable({
    required this.route,
    required this.direction,
    required this.dayType,
    required this.entries,
  });
}

/// 다음 셔틀 계산 결과 상태.
enum ShuttleStatus {
  /// 다음 정시 출발이 있음. [NextShuttle.remainMinutes] 유효.
  upcoming,

  /// 수시운행 구간.
  flexible,

  /// 도착버스 탑승 구간.
  arrivalBoarding,

  /// 당일 운행 종료(막차 이후).
  closed,

  /// 해당 요일 미운행.
  notOperating,
}

/// 현재 시각 기준 다음 셔틀 계산 결과. UI는 이 값만으로 렌더링한다.
class NextShuttle {
  final ShuttleStatus status;

  /// 다음 출발까지 남은 분([ShuttleStatus.upcoming]에서만 유효).
  final int? remainMinutes;

  /// 다음 출발 시각([ShuttleStatus.upcoming]에서만 유효).
  final ShuttleTime? departureTime;

  /// 분 숫자 대신 노출할 상태 라벨(수시운행/도착버스 탑승/운행 종료/운행 안함 등).
  final String? statusLabel;

  /// 보조 안내 문구(구간 시간대, 승차 위치 등).
  final String? subText;

  const NextShuttle({
    required this.status,
    this.remainMinutes,
    this.departureTime,
    this.statusLabel,
    this.subText,
  });

  /// 카운트다운을 시작하는 상한(분).
  ///
  /// 이보다 먼 출발은 도로 사정에 따라 오차가 커서 분 숫자를 신뢰하기 어렵다.
  /// 15분 이내로 좁혀졌을 때만 숫자를 보여주고, 그 전에는 '도착정보없음'으로
  /// 안내한다.
  static const int countdownLimitMinutes = 15;

  /// 분 숫자(굵은 강조)로 표기할 수 있는 상태인지.
  bool get showsMinutes =>
      status == ShuttleStatus.upcoming &&
      remainMinutes != null &&
      remainMinutes! <= countdownLimitMinutes;

  /// 다음 출발은 있지만 아직 [countdownLimitMinutes]보다 멀어 분 표기를
  /// 하지 않는 상태. UI는 '도착정보없음'으로 표시한다.
  bool get isBeyondCountdown =>
      status == ShuttleStatus.upcoming &&
      remainMinutes != null &&
      remainMinutes! > countdownLimitMinutes;
}
