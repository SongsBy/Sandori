import 'package:handori/features/auth/domain/model/auth_session.dart';

abstract class AuthRepository {
  /// 브라우저(Keycloak 로그인 페이지)를 띄워 로그인한다.
  /// [useKakao] 가 true 면 Keycloak 화면을 건너뛰고 카카오 로그인으로 직행한다
  /// (`kc_idp_hint=kakao`). 사용자가 취소하면
  /// [FlutterAppAuthUserCancelledException] 이 던져진다.
  Future<AuthSession> login({bool useKakao = false});

  /// 저장된 세션을 복원한다. 액세스 토큰이 만료됐으면 리프레시를 시도하고,
  /// 리프레시도 실패하면 세션을 지우고 null 을 반환한다.
  Future<AuthSession?> restoreSession();

  /// API 호출에 쓸 유효한 액세스 토큰. 비로그인 상태면 null.
  Future<String?> getValidAccessToken();

  /// 서버 세션을 끊고(베스트 에포트) 로컬 토큰을 지운다.
  Future<void> logout();
}
