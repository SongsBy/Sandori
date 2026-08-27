/// 로그인된 사용자의 토큰 묶음.
///
/// Keycloak(OIDC Authorization Code + PKCE)이 발급한 토큰을 보관한다.
/// [username] 은 ID 토큰의 `preferred_username` 클레임에서 추출한 표시용 값.
class AuthSession {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime? accessTokenExpiresAt;
  final String? username;

  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.accessTokenExpiresAt,
    this.username,
  });

  /// 액세스 토큰이 아직 유효한지. 만료 정보가 없으면 유효한 것으로 본다.
  /// [leeway] 만큼 여유를 두어 경계 시점의 401을 예방한다.
  bool isAccessTokenValid({Duration leeway = const Duration(seconds: 30)}) {
    final expiresAt = accessTokenExpiresAt;
    if (expiresAt == null) return true;
    return DateTime.now().add(leeway).isBefore(expiresAt);
  }
}
