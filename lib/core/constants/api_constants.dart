abstract class ApiConstants {
  static const String baseUrl = 'https://sandori.kr';
  static const String staticInfoBaseUrl = 'https://sandori.kr';

  /// 학식(Meal) 서비스. host:port만 지정하고 경로에 `/meal` 접두사를 포함한다.
  /// (static-info와 동일 규칙 — baseUrl에 path를 넣으면 Dio가 leading `/`를
  ///  절대경로로 처리해 경로가 소실됨)
  static const String mealBaseUrl = 'https://sandori.kr';

  static const int defaultPageSize = 10;
}
