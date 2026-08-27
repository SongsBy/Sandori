import 'package:dio/dio.dart';

/// 로그인 상태면 모든 요청에 `Authorization: Bearer` 를 붙인다.
/// 토큰 조회 콜백이 만료 시 리프레시까지 처리하므로(QueuedInterceptor 로
/// 동시 요청의 중복 리프레시를 직렬화), 비로그인 상태면 헤더 없이 통과한다.
class AuthInterceptor extends QueuedInterceptor {
  final Future<String?> Function() _getAccessToken;

  AuthInterceptor(this._getAccessToken);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // 토큰 조회 실패가 공개 API 호출까지 막아서는 안 된다.
    }
    handler.next(options);
  }
}
