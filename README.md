#  Sandori (산돌이)

**한국공학대학교 학생들을 위한 캠퍼스 생활 정보 앱**

---

## 🛠️ 개발 아키텍처 및 주요 구현 사항
### (9/14): 사용자 UI UX 피드백 반영버전
- 업데이트 내용
  - 광고 배너 카드 자동 스크롤
  - 카드 안에 위젯은 chip으로 관리 좀 더 가독성 좋은 버전으로 변경
  - 추후에 변동 될 예정이지만 티노 이미지 사용
  - 빈 강의실 상세 페이지는 지도 위에 마커로 표시했고 마커를 클릭시 필터링 된 값만 보여 줄 것인지는 추후 논의
  - 현재 공지사항 페이지는 그냥 웹뷰로 감싼 형태 효율성이 일단은 좋아보이긴 하지만 팀원들과 논의 필요 

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
```
lib/
├─ screen/                      # 각 페이지
│  ├─ Splash_screen.dart
│  ├─ Signin_gate_screen.dart
│  ├─ Login_screen.dart
│  ├─ Sign_screen.dart
│  ├─ Home_screen.dart
│  ├─ Restaurant_detail_screen.dart
│  ├─ Empty_detail_screen.dart   # 지도+마커, SlidingUpPanel
│  ├─ BusTime_detail_screen.dart
│  └─ Notice_screen.dart         # WebView 래핑
│
├─ component/                   # 재사용 위젯
│  ├─ BannerCard_top.dart       # 상단 배너 (오토슬라이드)
│  ├─ MealCard.dart             # 학식 카드
│  ├─ EmptyclassCard.dart       # 빈 강의실 카드
│  ├─ BusTimeCardScreen.dart    # 버스 카드
│  ├─ TopBar.dart               # 상단바(날짜/인사/알림/유저)
│  └─ HeaderText.dart           # 섹션 헤더(+더보기)
│
├─ const/                       # 공용 색/상수 (랭킹 등 → 추후 확장)
│
├─ model/                       # 데이터 모델 (더미 중심)
│  ├─ banner_model.dart
│  ├─ class_model.dart
│  ├─ meal_model.dart
│  ├─ meals_ranking_model.dart
│  └─ bus_model.dart
│
└─ repository/
   ├─ static_repository.dart    # 임시 정적 데이터
   └─ empty_class_repository.dart
```
---

##  향후 개발 계획 
-   소셜 로그인(Kakao, Google, Apple)의 OAuth 2.0 인증 방식 적용 및 각 플랫폼별 API 가이드라인 준수
-   실시간 데이터 연동을 위한 백엔드 API 구축 및 연결
-   공지사항,
-   전반적인 코드 정리와 상태관리9/1)

---
<p float="left">
  <img width="320" src="https://github.com/user-attachments/assets/811955ee-a714-4e6c-a9fd-3f43f2074cb9" alt="Home Screenshot" />
  <img width="320" src="https://github.com/user-attachments/assets/d02a3f29-5d6a-460d-a865-94323685b99d" alt="Detail Screenshot" />
</p>




## 🚀 설치 & 실행 방법

```bash
# 저장소 클론
git clone https://github.com/username/remind.git](https://github.com/SongsBy/Sandori.git

# 패키지 설치
flutter pub get

# iOS 실행
flutter run -d ios

# Android 실행
flutter run -d android
