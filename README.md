# Sandori (산돌이)

**한국공학대학교 학생들을 위한 캠퍼스 생활 정보 앱**

---

## 🛠️ 개발 아키텍처

### 아키텍처: Feature-First + 3-Layer

기능별 모듈 단위로 코드를 분리하고, 각 기능 안에서 data / domain / presentation 3계층을 유지합니다.

- `presentation` → `domain` 참조 허용
- `presentation` → `data` (DTO 직접 참조) 금지
- feature 간 직접 참조 금지 → 공유 시 `shared/`로 추출

### 상태관리: Riverpod (코드 생성 방식)

`@riverpod` 어노테이션만 사용. `StateProvider`, `StateNotifierProvider` 등 수동 선언 금지.

### 네트워킹: Retrofit + Dio

`@RestApi` 인터페이스로 API 선언. Dio는 `keepAlive: true` 싱글톤, 인터셉터 순서: Auth → Error → Logging.

### 라우팅: GoRouter

`context.go()` / `context.push()` 만 사용. `Navigator.push()` 직접 사용 금지.

### 코드 생성 도구

| 역할 | 패키지 |
|---|---|
| JSON 직렬화 | `json_serializable` + `json_annotation` |
| API 클라이언트 | `retrofit_generator` |
| 상태관리 | `riverpod_generator` |
| 불변 모델 | `freezed` |

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 📂 디렉토리 구조

```
lib/
├── main.dart
│
├── core/                          # 전역 공통
│   ├── constants/
│   │   └── api_constants.dart     # baseUrl 등 API 상수
│   ├── network/
│   │   └── dio_provider.dart      # Dio 싱글톤 프로바이더
│   ├── router/
│   │   ├── app_router.dart        # GoRouter 설정
│   │   └── route_paths.dart       # 경로 상수
│   └── utils/
│       └── date_formatter.dart    # ISO 8601 → yyyy.MM.dd 포맷터
│
├── features/                      # 기능별 모듈
│   └── notice/                    # 공지사항 기능
│       ├── data/
│       │   ├── data_source/
│       │   │   └── notice_api.dart            # @RestApi Retrofit 인터페이스
│       │   ├── dto/
│       │   │   ├── notice_item_response.dart
│       │   │   ├── paginated_notice_response.dart
│       │   │   ├── shuttle_item_response.dart
│       │   │   ├── paginated_shuttle_response.dart
│       │   │   └── shuttle_recent_response.dart
│       │   └── repository/
│       │       └── notice_repository_impl.dart
│       ├── domain/
│       │   ├── model/
│       │   │   ├── notice.dart
│       │   │   ├── shuttle.dart
│       │   │   └── shuttle_recent.dart
│       │   └── repository/
│       │       └── notice_repository.dart     # abstract Repository
│       └── presentation/
│           ├── page/
│           │   ├── notice_page.dart           # 탭(일반/기숙사/셔틀) 목록
│           │   └── notice_detail_page.dart    # WebView 상세
│           ├── provider/
│           │   └── notice_provider.dart       # @riverpod Notifier
│           └── widget/
│               ├── notice_card.dart
│               └── shuttle_card.dart          # 이미지 탭 → 전체화면 뷰어
│
├── shared/                        # feature 간 공유
│   ├── model/
│   │   └── pagination_state.dart  # @freezed PaginationState<T>
│   └── widget/
│       └── full_screen_image_viewer.dart  # InteractiveViewer 전체화면 이미지
│
├── screen/                        # 메인 화면 (구 구조, 점진적 마이그레이션 예정)
│   ├── maain_shell.dart           # IndexedStack 바텀탭 셸
│   ├── splashScreen.dart
│   ├── SignInGateScreen.dart
│   ├── LoginScreen.dart
│   ├── SigninScreen.dart
│   ├── home_screen.dart
│   ├── Restaurant_detail_screen.dart
│   ├── BusTime_detail_screen.dart
│   ├── Empty_detail_screen.dart   # 빈 강의실 지도 + SlidingUpPanel
│   └── Notice_Screen.dart         # (레거시 WebView 공지, NoticePage로 교체됨)
│
├── component/                     # 재사용 위젯 (구 구조)
│   ├── BannerCard_top.dart        # 상단 배너 슬라이더
│   ├── MealCard.dart              # 홈 학식 리스트 (세로 컴팩트)
│   ├── EmptyclassCard.dart        # 홈 빈 강의실 카드
│   ├── BustimeCardScreen.dart     # 홈 버스 카드
│   ├── Header_text.dart           # 섹션 헤더 텍스트
│   ├── SelectableIconButton.dart  # 선택형 아이콘 버튼
│   ├── Topdar.dart                # 상단바 (날짜, 인삿말, 알림, 프로필)
│   └── app_bottom_nav.dart        # 바텀 네비게이션 바
│
├── model/                         # 도메인 모델 (구 구조)
│   ├── banner_model.dart
│   ├── class_model.dart           # EmptyClass
│   ├── meal_model.dart
│   ├── Meals_ranking_model.dart
│   └── bus_model.dart
│
├── repository/                    # 데이터 저장소 (구 구조)
│   ├── static_repository.dart     # 정적 더미 데이터
│   └── Empty_Class_Repository.dart
│
└── const/
    └── colors.dart
```

### 바텀 네비게이션 탭 순서

| 인덱스 | 탭 | 화면 |
|---|---|---|
| 0 | 버스시간표 | `BusTimeDetailScreen` |
| 1 | 학식 | `RestaurantDetailScreen` |
| **2** | **홈 (중앙)** | **`HomeScreen`** |
| 3 | 공지사항 | `NoticePage` |
| 4 | 빈 강의실 | `EmptyDetailScreen` |

---

## 🎨 색상 팔레트

| 용도 | 색상값 |
|---|---|
| 메인 포인트 | `Color(0xFF00C4F9)` |
| 서브 포인트 | `Color(0xFF95E0F4)` |
| 배경 | `Colors.white` |
| 서브 배경 | `Color(0xFFFAFAFA)` |
| 텍스트 기본 | `Colors.black` / `Colors.black87` |
| 텍스트 보조 | `Colors.grey` |

> Flutter 기본 보라/파랑 계열(`Colors.blue`, `Colors.purple` 등) 사용 금지.
> `CircularProgressIndicator`, `TabBar`, `ElevatedButton` 등 기본값이 보라색인 위젯은 반드시 색상 지정.

---

## 📦 주요 의존성

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  dio: ^5.9.2
  retrofit: ">=4.6.0 <4.9.0"
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.4
  go_router: ^17.1.0
  flutter_secure_storage: ^10.0.0
  get_it: ^9.2.1
  google_maps_flutter: ^2.15.0
  geolocator: ^14.0.2
  sliding_up_panel: ^2.0.0+1
  webview_flutter: ^4.13.1

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^2.4.3
  retrofit_generator: ^9.0.0
  json_serializable: ^6.9.4
  freezed: ^2.5.7
```

---

## 🚀 설치 & 실행

```bash
# 저장소 클론
git clone https://github.com/SongsBy/Sandori.git

# 패키지 설치
flutter pub get

# 코드 생성
dart run build_runner build --delete-conflicting-outputs

# iOS 실행
flutter run -d ios

# Android 실행
flutter run -d android
```

---

## 🗺️ 향후 개발 계획

- 소셜 로그인 (Kakao / Google / Apple) — PKCE + state 파라미터 적용
- 실시간 API 연동 (학식 메뉴, 버스 시간표)
- `screen/`, `component/`, `model/`, `repository/` 레거시 코드 → Feature-First 구조로 점진적 마이그레이션
- 푸시 알림 (공지사항, 셔틀 출발 알림)
