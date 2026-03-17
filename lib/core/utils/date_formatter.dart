abstract class DateFormatter {
  /// ISO 8601 문자열 → "yyyy.MM.dd" (예: "2026.03.17")
  /// 파싱 실패 시 원본 문자열 반환
  static String format(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final y = dt.year.toString();
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y.$m.$d';
    } catch (_) {
      return raw;
    }
  }
}
