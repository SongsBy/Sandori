# Handori 프로젝트 규약

> 이 문서는 Claude가 Handori(한국공대 학식 앱) 코드를 작성할 때 반드시 따라야 하는 규칙입니다.
> 모든 응답에서 아래 규약을 준수하세요.

---

## 프로젝트 정보

- 앱 이름: Handori (한도리)
- 플랫폼: Flutter (Dart 3.4+, Flutter 3.22+)
- 목적: 한국공대 학식 메뉴 제공 애플리케이션

---

## 1. 아키텍처

Feature-First + 3-Layer 구조를 사용한다.

```
lib/
├── core/           # 전역 공통 (네트워크, 라우터, 테마, 상수, 유틸)
├── features/       # 기능별 모듈
│   └── {feature}/
│       ├── data/
│       │   ├── dto/              # @JsonSerializable DTO
│       │   ├── data_source/      # @RestApi Retrofit 인터페이스
│       │   └── repository/       # RepositoryImpl
│       ├── domain/
│       │   ├── model/            # 순수 도메인 모델
│       │   └── repository/       # abstract Repository
│       └── presentation/
│           ├── provider/         # @riverpod Notifier
│           ├── page/             # Page 위젯
│           └── widget/           # 재사용 위젯
└── shared/         # feature 간 공유 위젯, 프로바이더
```

### 레이어 의존성 규칙

- `presentation` → `domain` ✅
- `presentation` → `data` ❌ (DTO 직접 참조 금지)
- `data` → `domain` ✅
- `domain` → `data` ❌
- feature 간 직접 참조 ❌ → 필요 시 `shared/`로 추출

---

## 2. 코드 생성 필수 사용

아래 5가지는 반드시 코드 생성 방식으로 작성한다. 수동으로 동일 기능을 구현하지 않는다.

### 2.1 JsonSerializable (DTO)

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class MenuResponse {
  final int id;
  final String menuName;
  final DateTime servedAt;

  const MenuResponse({
    required this.id,
    required this.menuName,
    required this.servedAt,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuResponseToJson(this);

  // DTO → Domain 변환 메서드 필수
  Menu toDomain() => Menu(id: id, name: menuName, servedAt: servedAt);
}
```

- DTO는 `data/dto/`에만 위치
- 클래스명: `*Response`, `*Request` 접미사
- 서버가 snake_case면 `FieldRename.snake` 통일
- null 가능 필드는 반드시 `?` 표기
- `toDomain()` 변환 메서드 항상 구현

### 2.2 Retrofit (API)

```dart
@RestApi()
abstract class MenuApi {
  factory MenuApi(Dio dio, {String? baseUrl}) = _MenuApi;

  @GET('/api/v1/menus')
  Future<PaginatedResponse<MenuResponse>> getMenus(
    @Query('page') int page,
    @Query('size') int size,
  );

  @GET('/api/v1/menus/{id}')
  Future<MenuResponse> getMenuById(@Path('id') int id);
}
```

- `data/data_source/`에 위치
- 클래스명: `*Api` 접미사
- Dio 인스턴스는 `dioProvider`에서 주입
- baseUrl은 `ApiConstants`에서 중앙 관리

### 2.3 Riverpod (상태관리)

반드시 `@riverpod` 어노테이션 코드 생성 방식만 사용한다. `StateProvider`, `StateNotifierProvider` 등 수동 선언 금지.

```dart
// 읽기 전용 데이터 → 함수형
@riverpod
Future<Menu> menuDetail(Ref ref, {required int menuId}) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.getMenuById(menuId);
}

// 상태 변경 필요 → Notifier 클래스
@riverpod
class MenuListNotifier extends _$MenuListNotifier {
  @override
  Future<PaginationState<Menu>> build() async {
    return _fetchPage(1);
  }

  Future<void> loadNextPage() async { /* ... */ }
  Future<void> refresh() async { /* ... */ }
}
```

- 기본 AutoDispose, 유지 필요 시 `@Riverpod(keepAlive: true)` 명시
- family 파라미터는 함수 인자로 처리 (자동 family 생성)

### 2.4 Freezed (불변 모델)

상태 모델, sealed class가 필요한 경우 Freezed 사용.

```dart
@freezed
class PaginationState<T> with _$PaginationState<T> {
  const factory PaginationState({
    @Default([]) List<T> items,
    @Default(1) int currentPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _PaginationState;
}
```

### 2.5 GoRouter (라우팅)

```dart
// 경로는 RoutePaths 상수 클래스에서 관리
abstract class RoutePaths {
  static const home = '/';
  static const menu = '/menu';
  static const menuDetail = '/menu/:id';
}
```

- 네비게이션: `context.go()` / `context.push()` 만 사용
- `Navigator.push()` 직접 사용 금지
- 인증 가드는 `redirect`에서 전역 처리
- 바텀 네비 유지 탭은 `ShellRoute` 사용

---

## 3. Dio 설정

```dart
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref),    // 1순위: 토큰 주입
    ErrorInterceptor(),      // 2순위: 에러 변환
    if (kDebugMode) LoggingInterceptor(),  // 3순위: 디버그 로깅
  ]);

  return dio;
}
```

- Dio는 `keepAlive: true` 싱글톤
- 인터셉터 순서: Auth → Error → Logging 고정

---

## 4. 페이지네이션 패턴

페이지네이션이 필요한 리스트는 아래 패턴을 따른다.

- 기본 페이지 사이즈: 20
- 스크롤 하단 300px 전에 다음 페이지 로드
- `isLoadingMore` 플래그로 중복 요청 방지
- Pull-to-Refresh 시 첫 페이지부터 다시 로드

---

## 5. 네이밍 규칙

### 파일명

- 모든 파일: `snake_case.dart`
- 생성 파일: `원본명.g.dart`, `원본명.freezed.dart`

### 클래스/변수

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스 | PascalCase | `MenuResponse` |
| 변수/함수 | camelCase | `fetchMenuList()` |
| 상수 | camelCase | `defaultPageSize` |
| enum | PascalCase, 값은 camelCase | `MealType.lunch` |

### 레이어별 접미사

| 레이어 | 접미사 | 예시 |
|--------|--------|------|
| DTO | `*Response` / `*Request` | `MenuResponse` |
| Domain Model | 없음 | `Menu` |
| Repository 인터페이스 | `*Repository` | `MenuRepository` |
| Repository 구현 | `*RepositoryImpl` | `MenuRepositoryImpl` |
| Notifier | `*Notifier` | `MenuListNotifier` |
| Page | `*Page` | `MenuPage` |

---

## 6. 에러 핸들링

```
Dio → ErrorInterceptor (예외 변환)
  → Repository (try-catch)
    → Provider (AsyncValue.error 자동 처리)
      → UI (.when으로 분기)
```

UI에서는 반드시 `.when()`으로 3가지 상태를 모두 처리한다:

```dart
ref.watch(provider).when(
  data: (data) => /* 정상 UI */,
  loading: () => const LoadingIndicator(),
  error: (e, st) => ErrorView(
    message: e.toUserMessage(),
    onRetry: () => ref.invalidate(provider),
  ),
);
```

- 기술적 에러 메시지를 사용자에게 직접 노출하지 않는다
- 모든 에러 화면에 재시도 버튼 포함

---

## 7. 색상 규칙

Flutter 기본 보라/파랑 계열 색상은 **절대 허용하지 않는다.**

### 프로젝트 색상 팔레트

| 용도 | 색상 | 값 |
|------|------|----|
| 메인 포인트 (버튼, 탭, 링크) | 하늘 파랑 | `Color(0xFF00C4F9)` |
| 서브 포인트 (버튼 배경 등) | 연 하늘 | `Color(0xFF95E0F4)` |
| 배경 | 흰색 | `Colors.white` |
| 서브 배경 | 밝은 회색 | `Color(0xFFFAFAFA)` |
| 텍스트 기본 | 검정 | `Colors.black` / `Colors.black87` |
| 텍스트 보조 | 회색 | `Colors.grey` |
| 에러 | 빨강 | `Colors.red` |

### 금지 목록

- `Colors.blue`, `Colors.purple`, `Colors.indigo`, `Colors.deepPurple` ❌
- `ThemeData` 설정 없이 `ElevatedButton` 사용 → 보라색 default 적용됨 ❌
- `CircularProgressIndicator()` color 미지정 → 보라색 default 적용됨 ❌
- `TabBar` `indicatorColor`, `labelColor` 미지정 → 보라색 default 적용됨 ❌
- `TextField` `focusedBorder` 미지정 → 보라색 default 적용됨 ❌

### 올바른 사용 예시

```dart
// CircularProgressIndicator
CircularProgressIndicator(color: Color(0xFF00C4F9))

// ElevatedButton
ElevatedButton.styleFrom(backgroundColor: Color(0xFF95E0F4))

// TabBar
TabBar(
  indicatorColor: Color(0xFF00C4F9),
  labelColor: Color(0xFF00C4F9),
  unselectedLabelColor: Colors.grey,
)
```

---

## 8. 코드 스타일

- 한 파일에 public 클래스 1개 (private 보조 클래스 허용)
- 파일 300줄 초과 시 분리
- 함수 50줄 초과 시 분리
- import 순서: `dart:` → `package:` → 프로젝트 (상대경로 금지)
- 가능한 모든 곳에 `const` 적용
- 매직 넘버 금지, 상수로 추출
- `print()` 사용 금지, `Logger` 사용

---

## 8. 컴포넌트 분리 및 재사용 규칙

중복 코드는 절대 허용하지 않는다. 컴포넌트 분리를 생활화한다.

### 코드 작성 전 필수 절차

1. **기존 컴포넌트 탐색 먼저** — `lib/component/`, `lib/shared/` 디렉토리를 반드시 확인하고, 재사용 가능한 위젯이 있으면 새로 만들지 않고 활용한다.
2. **중복 금지** — 동일하거나 유사한 UI/로직이 2곳 이상에 존재하면 즉시 컴포넌트로 추출한다.
3. **분리 기준** — 아래 중 하나라도 해당하면 별도 파일로 분리한다:
   - 같은 위젯이 2곳 이상에서 사용되는 경우
   - 위젯 코드가 50줄을 초과하는 경우
   - 독립적으로 테스트 가능한 단위인 경우

### 컴포넌트 배치 규칙

| 범위 | 위치 |
|------|------|
| 특정 feature에서만 사용 | `features/{feature}/presentation/widget/` |
| 여러 feature에서 공유 | `shared/widget/` |
| 전역 공통 (버튼, 인풋 등) | `core/widget/` |

### 금지 사항

- 동일한 `TextStyle` 정의를 여러 파일에 복붙 ❌ → `AppTextStyles` 상수로 추출
- 동일한 `ButtonStyle` 정의를 여러 파일에 복붙 ❌ → 공통 버튼 컴포넌트로 추출
- 동일한 `InputDecoration` 정의를 여러 파일에 복붙 ❌ → 공통 TextField 컴포넌트로 추출

---

## 9. 보안 필수 규칙

### 인증

- 로그인 버튼 클릭 시 반드시 서버 API 호출 후 응답 결과로만 화면 전환
- 소셜 로그인(카카오/구글/애플) 구현 시 **PKCE + state 파라미터** 필수
- 토큰은 반드시 `flutter_secure_storage`에 저장 (`SharedPreferences` 금지)
- 보호된 화면은 GoRouter `redirect`에서 전역 인증 가드로만 처리

### 데이터

- 비밀번호 클라이언트 평문 저장/전송 금지
- API 통신은 HTTPS만 허용
- `print()`로 토큰, 사용자 정보 출력 금지 (Logger 사용)
- WebView 사용 시 JavaScript 허용 범위 및 안전하지 않은 콘텐츠 차단 설정 필수

---

## 10. 코드 작성 시 확인사항

코드를 생성할 때 아래 사항을 항상 확인한다:

1. DTO에 `toDomain()` 메서드가 있는가?
2. API 인터페이스가 Retrofit `@RestApi`로 선언되었는가?
3. Provider가 `@riverpod` 코드 생성 방식인가? (수동 Provider 아닌가?)
4. presentation 레이어에서 DTO를 직접 import하지 않았는가?
5. 새 라우트가 `RoutePaths`에 등록되었는가?
6. 에러/로딩/빈 상태 UI가 모두 처리되었는가?
7. 매직 넘버 없이 상수로 추출되었는가?
8. `.g.dart` part 선언이 포함되었는가?
9. **기존 컴포넌트를 먼저 확인하고 재사용했는가?**
10. **중복 코드가 없는가?**
11. **보안 이슈(인증 우회, 평문 저장, print 노출)가 없는가?**
