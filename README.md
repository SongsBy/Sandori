# Sandori
---
## 한국공학대학교 챗봇 산돌이 어플 제작 
🛠️ 개발 아키텍처 및 주요 구현 사항
1. 일관된 UI/UX를 위한 테마(Theming) 관리
main.dart에 ThemeData를 정의하여 앱 전체의 폰트와 텍스트 스타일을 중앙에서 관리합니다. 이를 통해 반복되는 TextStyle 코드를 줄이고 디자인의 일관성을 확보했습니다.

displayLarge (w700): 주로 큰 텍스트 헤더, 타이틀

displayMedium (w500): 중간 크기 텍스트

displaySmall (w300): 작은 크기 텍스트

titleLarge (w700): 'Krub' 폰트를 사용하는 특정 타이틀

모든 화면에서는 Theme.of(context).textTheme.displayLarge 와 같은 형태로 정의된 스타일을 가져와 사용합니다.

2. 가독성 및 유지보수를 위한 코드 구조화
각 화면(Screen)의 build 메소드 내 로직을 최소화하고, UI를 기능 단위의 StatelessWidget 컴포넌트로 분리하여 가독성과 재사용성을 높였습니다.

복잡한 로직은 별도의 함수로 분리하여 관리합니다.

3. 데이터 처리 및 컴포넌트 설계
데이터 추상화: repository 계층을 두어 데이터 소스를 UI와 분리했습니다. 추후 API나 실제 데이터베이스로 교체하더라도 UI 코드의 변경을 최소화할 수 있도록 설계했습니다.

효율적인 리스트 렌더링: 홈 화면의 카드 섹션들은 PageView.builder를 사용하여 메모리 효율성을 고려했으며, 외부(HomeScreen)에서 데이터를 주입받는 구조로 설계하여 오버플로우를 방지했습니다.

페이지 컨트롤러: 각 가로 스크롤 카드 섹션은 독립적인 PageController를 사용하여, 하나의 섹션을 스크롤해도 다른 섹션에 영향을 주지 않도록 구현했습니다.
### 설명
  - screen
    - splashScreen : 스플레시 스크린 
    - SigninGateScreen : 간단한 소개와 회원가입 유도
    - LoginScreen : 로그인 화면 
    - SignScreen : 회원가입 화면 
    - homeScreen : 홈화면 
    - Restaurant_detail_screen : 학식 상세페이지 (8/26개발 예정)
    - Empty_detail_screen : 빈 강의실 상세 페이지 (8/26개발 예정)
    - BusTime_detail_screen : 버스 시간표 상세페이지 (8/26개발 예정)


  - component
    - BannerCard_top : 상단 광고배너 카드섹션 로직 구현부
    - MealCard : 홈화면 학식리스트 카드섹션 로직 구현부
    - EmptyclassCard : 홈화면 빈 강의실 카드섹션 로직 구현부
    - BusTimeCardScreen : 홈화면 버스시간표 카드섹션 로직 구현부     
    - TopBar : 상단의 날짜, 인삿말, 알림 , 유저 이미지 상단바 로직 구현부
    - HeaderText : 각 카드섹션 헤더 텍스트와 상세페이지 유도 버튼 구현부
  - model
    - banner_model : 배너에 들어갈 데이터 양식 파일 정의
    - class_model  : 빈 강의실을 구현하는 데이터 양식 파일 정의
    - meal_model   : 오늘의 식단을 구현하는 데이터 양식 파일 정의
  - repository
    - static_repository : 배너 , 빈 강의실 , 오늘의 식단 을 구성하는 임시 리스트 구현 추후에 API나 데이터 베이스 로직이 붙을시 이부분만 수정하면 되도록 제작.
 
 ### 개발 예정
  - 각 식당 , 강의실 , 버스조회 상세페이지 제작
  - OAuth로그인 인증 방식 변경 (키카오,구글 , 애플) 각자 요구하는 API 발급 과 인증방식을 통알해야하는 변수가 있음

