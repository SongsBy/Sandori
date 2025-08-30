#  Sandori (산돌이)

**한국공학대학교 학생들을 위한 캠퍼스 생활 정보 앱**

---

## 🛠️ 개발 아키텍처 및 주요 구현 사항

### 1. 일관된 UI/UX를 위한 테마(Theming) 관리
-   `main.dart`에 `ThemeData`를 정의하여 앱 전체의 폰트와 텍스트 스타일을 중앙에서 관리합니다. 이를 통해 반복되는 `TextStyle` 코드를 줄이고 디자인의 일관성을 확보했습니다.
    -   `displayLarge` (w700): 주로 큰 텍스트 헤더, 타이틀
    -   `displayMedium` (w500): 중간 크기 텍스트
    -   `displaySmall` (w300): 작은 크기 텍스트
    -   `titleLarge` (w700): 'Krub' 폰트를 사용하는 특정 타이틀
-   모든 화면에서는 `Theme.of(context).textTheme.displayLarge` 와 같은 형태로 정의된 스타일을 가져와 사용합니다.

### 2. 가독성 및 유지보수를 위한 코드 구조화
-   각 화면(`Screen`)의 `build` 메소드 내 로직을 최소화하고, UI를 기능 단위의 `StatelessWidget` 컴포넌트로 분리하여 가독성과 재사용성을 높였습니다.
-   복잡한 로직은 별도의 함수로 분리하여 관리합니다.

### 3. 데이터 처리 및 컴포넌트 설계
-   **데이터 추상화**: `repository` 계층을 두어 데이터 소스를 UI와 분리했습니다. 추후 API나 실제 데이터베이스로 교체하더라도 UI 코드의 변경을 최소화할 수 있도록 설계했습니다.
-   **효율적인 리스트 렌더링**: 홈 화면의 카드 섹션들은 `PageView.builder`를 사용하여 메모리 효율성을 고려했으며, 외부(`HomeScreen`)에서 데이터를 주입받는 구조로 설계하여 오버플로우를 방지했습니다.
-   **페이지 컨트롤러**: 각 가로 스크롤 카드 섹션은 독립적인 `PageController`를 사용하여, 하나의 섹션을 스크롤해도 다른 섹션에 영향을 주지 않도록 구현했습니다.

### 3. 오픈소스 플러그인 
- `GoogleMap` : 구글맵 API를 활용하기위한 플러그인
- `GeoLocator`: 구글맵에서 지도를 활용하기위한 플러그인
-  `GetIt` : 데이터 처리를 간편하게 하는 플러그인

---

## 📂 주요 디렉토리 구조

-   `screen` : 각 페이지 UI를 구성하는 메인 화면 폴더
    -   `SplashScreen`: 앱 실행 시 표시되는 스플래시 화면
    -   `SigninGateScreen`: 간단한 소개 및 회원가입 유도 화면
    -   `LoginScreen`: 로그인 화면
    -   `SignScreen`: 회원가입 화면
    -   `HomeScreen`: 앱의 메인 홈 화면
    -   `Restaurant_detail_screen`: 학식 상세 페이지
    -   `Empty_detail_screen`: 빈 강의실 상세 페이지
    -   `BusTime_detail_screen`: 버스 시간표 상세 페이지

-   `component` : 화면을 구성하는 재사용 가능한 위젯 폴더
    -   `BannerCard_top`: 상단 광고 배너 UI
    -   `MealCard`: 홈 화면 학식 리스트 카드 UI
    -   `EmptyclassCard`: 홈 화면 빈 강의실 카드 UI
    -   `BusTimeCardScreen`: 홈 화면 버스 시간표 카드 UI
    -   `TopBar`: 상단바 (날짜, 인삿말, 알림, 유저 프로필) UI
    -   `HeaderText`: 각 카드 섹션의 제목 및 '더보기' 버튼 UI

-   `const` : 랭킹을 구성하는 재사용 가능한 색상폴더(향후 모든 색상 추가예정)

-   `model` : 데이터의 구조를 정의하는 모델 클래스 폴더
    -   `banner_model`: 배너 데이터 모델
    -   `class_model`: 빈 강의실 데이터 모델
    -   `meal_model`: 식단 데이터 모델
    -   `mealsranking_model`: 식단 랭킹 데이터 모델
    -   `bus_model`: 버스시간표 모델

-   `repository` : 데이터 소스를 관리하는 저장소 폴더
    -   `static_repository`: 현재 임시 정적 데이터를 제공하며, 추후 실제 데이터 로직으로 교체될 예정

---

## 🚀 향후 개발 계획
-   소셜 로그인(Kakao, Google, Apple)의 OAuth 2.0 인증 방식 적용 및 각 플랫폼별 API 가이드라인 준수
-   실시간 데이터 연동을 위한 백엔드 API 구축 및 연결
-   공지사항, 상세페이지
-   설정 페이지 (유저 설정페이지 )
