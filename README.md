# Sandori
---
## 한국공학대학교 챗봇 산돌이 어플 제작 
- 구현 내용 
  - splashScreen
  - LoginGateScreen
  - LoginScreen(Kakao , Google , Apple)
  - SigninScreen
  - HomeScreen 각각 card로 분리 3개의 별도 스크린 (TodayMeal , Emptyclass , BustimeScreen)
    - homeScreen 배너 광고 추가
    - 학식/식당 가로 스크롤 카드 변경
    
    


 
- 코드 설명
  - main.dart에 TextThem으로 텍스트 데이터 4가지
    -  displayLarge(w700) : 주로 큰 텍스트 헤더, 타이틀
    -  displayMedium(w500) :  중간텍스트
    -  displaySmall(w300) :  작은 사이즈의 글씨
    -  titleLarge(w700) : Krub폰트 타이틀 사용시
  -  다른 텍스트들 향후 추가 예정이지만 위 ThemeData를 앱천체 필드 텍스트로 지정해 반복되는 코드 줄임 "Theme.of(context).textTheme.위의 이름들" 형태로 Build함수에서 사용
  ---
  - 각 Build함수 내 로직은 최소화 하고 위젯을 top, middile , bottom으로 별도의 stlessWidget으로 선언해 가독성 확보
  - 로직 구현부는 함수로 두었습니다.
  ---
  - HomeScreen의 홈 카드 섹션 3가지 전부 별도의 스크린으로 구분 추후에 로직이 붙을 것 을 예상
  - 각 식당별 오늘의 식단 리스트 , 비어있는 강의실 리스트 , 다음버스 리스트를 데이터베이스에서 받아 보여주기위해 각각 카트섹션마다 별도 스크린과 리스트생성 후 map함수 사용해 자동 정렬
  ---
  - 로그인 페이지: 카카오,구글, 애플, 앱내 로그인 구현. 상태 위에서 관리
  - 회원가입 페이지 제작 List를 사용한 map함수로 텍스트 저장후 콜백 처리
  - 약관 동의 asMap사용
 


- 개발 예정
  - 각 식당 , 강의실 , 버스조회 상세페이지 제작
  - homeScreen.dart 디자인 수정
