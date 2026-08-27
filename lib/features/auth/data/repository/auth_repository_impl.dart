import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:handori/features/auth/data/token_storage.dart';
import 'package:handori/features/auth/domain/model/auth_session.dart';
import 'package:handori/features/auth/domain/repository/auth_repository.dart';

/// Keycloak OIDC(Authorization Code + PKCE) 기반 인증.
///
/// 브라우저로 `{issuer}/protocol/openid-connect/auth` 에 보내고,
/// 딥링크(redirectUri 커스텀 스킴)로 돌아온 code 를 flutter_appauth 가
/// 토큰으로 교환한다. discovery 문서 대신 엔드포인트를 직접 구성해
/// 로컬(Keycloak frontend URL 불일치) 환경에서도 동작한다.
class AuthRepositoryImpl implements AuthRepository {
  final FlutterAppAuth _appAuth;
  final TokenStorage _storage;
  final String _issuer;
  final String _clientId;
  final String _redirectUri;

  static const _scopes = ['openid', 'profile', 'email'];

  AuthRepositoryImpl({
    required TokenStorage storage,
    required String issuer,
    required String clientId,
    required String redirectUri,
    FlutterAppAuth appAuth = const FlutterAppAuth(),
  })  : _storage = storage,
        _issuer = issuer,
        _clientId = clientId,
        _redirectUri = redirectUri,
        _appAuth = appAuth;

  AuthorizationServiceConfiguration get _serviceConfiguration =>
      AuthorizationServiceConfiguration(
        authorizationEndpoint: '$_issuer/protocol/openid-connect/auth',
        tokenEndpoint: '$_issuer/protocol/openid-connect/token',
        endSessionEndpoint: '$_issuer/protocol/openid-connect/logout',
      );

  @override
  Future<AuthSession> login({bool useKakao = false}) async {
    final response = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        _clientId,
        _redirectUri,
        serviceConfiguration: _serviceConfiguration,
        scopes: _scopes,
        // Keycloak 전용: 카카오 IdP 로 직행해 Keycloak 로그인 화면을 건너뛴다.
        additionalParameters:
            useKakao ? const {'kc_idp_hint': 'kakao'} : null,
      ),
    );
    final session = _toSession(response);
    await _storage.save(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final saved = await _storage.read();
    if (saved == null) return null;
    if (saved.isAccessTokenValid()) return saved;
    return _refresh(saved);
  }

  @override
  Future<String?> getValidAccessToken() async =>
      (await restoreSession())?.accessToken;

  @override
  Future<void> logout() async {
    final saved = await _storage.read();
    // 서버 세션 종료는 베스트 에포트: 실패해도 로컬 로그아웃은 진행한다.
    if (saved?.refreshToken != null) {
      try {
        await Dio().post(
          '$_issuer/protocol/openid-connect/logout',
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: {
            'client_id': _clientId,
            'refresh_token': saved!.refreshToken,
          },
        );
      } catch (e) {
        debugPrint('Keycloak 서버 로그아웃 실패(로컬 로그아웃은 진행): $e');
      }
    }
    await _storage.clear();
  }

  Future<AuthSession?> _refresh(AuthSession old) async {
    final refreshToken = old.refreshToken;
    if (refreshToken == null) {
      await _storage.clear();
      return null;
    }
    try {
      final response = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUri,
          serviceConfiguration: _serviceConfiguration,
          refreshToken: refreshToken,
          scopes: _scopes,
        ),
      );
      final session = AuthSession(
        accessToken: response.accessToken!,
        // Keycloak 은 리프레시 토큰을 회전시킬 수 있다. 새 값이 없으면 기존 유지.
        refreshToken: response.refreshToken ?? refreshToken,
        idToken: response.idToken ?? old.idToken,
        accessTokenExpiresAt: response.accessTokenExpirationDateTime,
        username: old.username ?? _usernameFromJwt(response.idToken),
      );
      await _storage.save(session);
      return session;
    } catch (e) {
      // 리프레시 토큰 만료/폐기 → 로그아웃 상태로 전환
      debugPrint('토큰 리프레시 실패, 세션 제거: $e');
      await _storage.clear();
      return null;
    }
  }

  AuthSession _toSession(AuthorizationTokenResponse response) => AuthSession(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken,
        idToken: response.idToken,
        accessTokenExpiresAt: response.accessTokenExpirationDateTime,
        username: _usernameFromJwt(response.idToken) ??
            _usernameFromJwt(response.accessToken),
      );

  /// JWT payload 에서 표시용 사용자명을 추출한다. (서명 검증은 하지 않는다 —
  /// 검증 책임은 토큰을 소비하는 리소스 서버에 있다.)
  static String? _usernameFromJwt(String? jwt) {
    if (jwt == null) return null;
    final parts = jwt.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      return (payload['preferred_username'] ??
          payload['name'] ??
          payload['email']) as String?;
    } catch (_) {
      return null;
    }
  }
}
