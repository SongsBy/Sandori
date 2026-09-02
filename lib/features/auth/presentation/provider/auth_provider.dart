import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:handori/core/constants/api_constants.dart';
import 'package:handori/features/auth/data/repository/auth_repository_impl.dart';
import 'package:handori/features/auth/data/token_storage.dart';
import 'package:handori/features/auth/domain/model/auth_session.dart';
import 'package:handori/features/auth/domain/repository/auth_repository.dart';

part 'auth_provider.g.dart';

// ── Repository ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    storage: TokenStorage(const FlutterSecureStorage()),
    // .env 로 오버라이드 가능 (로컬 Keycloak 테스트용). 기본은 프로덕션.
    issuer: dotenv.maybeGet('AUTH_ISSUER') ?? ApiConstants.authIssuer,
    clientId: dotenv.maybeGet('AUTH_CLIENT_ID') ?? ApiConstants.authClientId,
    redirectUri: ApiConstants.authRedirectUri,
  );
}

// ── 세션 상태 ────────────────────────────────────────────────────────────────
// AsyncData(null) = 비로그인, AsyncData(session) = 로그인됨.

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthSession?> build() =>
      ref.watch(authRepositoryProvider).restoreSession();

  /// 로그인 성공 시 true. 사용자가 브라우저를 닫는 등 취소하면 이전 상태를
  /// 유지하고 false, 그 외 실패는 AsyncError 상태로 두고 false 를 반환한다.
  Future<bool> login({bool useKakao = false}) async {
    final previous = state;
    state = const AsyncLoading();
    try {
      final session =
          await ref.read(authRepositoryProvider).login(useKakao: useKakao);
      state = AsyncData(session);
      return true;
    } on FlutterAppAuthUserCancelledException {
      state = previous;
      return false;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  /// Keycloak 계정을 영구 삭제한다. 서버 삭제 실패 시 예외가 그대로 올라오며
  /// 세션 상태는 유지된다 — 호출부(UI)에서 안내한다.
  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    state = const AsyncData(null);
  }
}
