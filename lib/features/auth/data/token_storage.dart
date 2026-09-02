import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:handori/features/auth/domain/model/auth_session.dart';

/// 토큰을 기기 보안 저장소(Keychain/Keystore)에 보관한다.
/// 매 API 요청마다 저장소를 읽지 않도록 마지막 세션을 메모리에 캐시한다.
class TokenStorage {
  static const _kAccessToken = 'auth_access_token';
  static const _kRefreshToken = 'auth_refresh_token';
  static const _kIdToken = 'auth_id_token';
  static const _kExpiresAt = 'auth_access_expires_at';
  static const _kUsername = 'auth_username';
  static const _kEmail = 'auth_email';

  final FlutterSecureStorage _storage;
  AuthSession? _cached;
  bool _loaded = false;

  TokenStorage(this._storage);

  Future<AuthSession?> read() async {
    if (_loaded) return _cached;
    final accessToken = await _storage.read(key: _kAccessToken);
    if (accessToken == null) {
      _loaded = true;
      return null;
    }
    final expiresAtRaw = await _storage.read(key: _kExpiresAt);
    _cached = AuthSession(
      accessToken: accessToken,
      refreshToken: await _storage.read(key: _kRefreshToken),
      idToken: await _storage.read(key: _kIdToken),
      accessTokenExpiresAt:
          expiresAtRaw == null ? null : DateTime.tryParse(expiresAtRaw),
      username: await _storage.read(key: _kUsername),
      email: await _storage.read(key: _kEmail),
    );
    _loaded = true;
    return _cached;
  }

  Future<void> save(AuthSession session) async {
    await _storage.write(key: _kAccessToken, value: session.accessToken);
    await _writeOrDelete(_kRefreshToken, session.refreshToken);
    await _writeOrDelete(_kIdToken, session.idToken);
    await _writeOrDelete(
      _kExpiresAt,
      session.accessTokenExpiresAt?.toIso8601String(),
    );
    await _writeOrDelete(_kUsername, session.username);
    await _writeOrDelete(_kEmail, session.email);
    _cached = session;
    _loaded = true;
  }

  Future<void> clear() async {
    for (final key in const [
      _kAccessToken,
      _kRefreshToken,
      _kIdToken,
      _kExpiresAt,
      _kUsername,
      _kEmail,
    ]) {
      await _storage.delete(key: key);
    }
    _cached = null;
    _loaded = true;
  }

  Future<void> _writeOrDelete(String key, String? value) => value == null
      ? _storage.delete(key: key)
      : _storage.write(key: key, value: value);
}
