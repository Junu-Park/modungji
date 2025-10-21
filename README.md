<img width="100" height="100" src="https://github.com/user-attachments/assets/45a3cf3f-5a71-41a5-be6b-862f633494d2">

# 모둥지 (Modungji)
> 지도 기반 부동산 매물 중계 서비스 iOS 앱

---

## 📱 소개
**모둥지**는 이메일·소셜 로그인으로 간편하게 시작하고,
맞춤 필터와 지도 탐색을 통해 원하는 부동산을 찾고 예약까지 한 번에 가능한 스마트 부동산 앱입니다.

- ⭐️ 간편 로그인(애플, 카카오, 이메일)
- ⭐️ 매물 추천(인기 및 추천 매물 정보)
- ⭐️ 부동산 토픽 컨텐츠(부동산 관련 뉴스 및 토픽)
- ⭐️ 지도 탐색(지도 기반 매물 탐색 및 주소 검색)
- ⭐️ 맞춤 필터(매물 종류 / 평수 / 월세 / 보증금 등 다양한 필터)
- ⭐️ 실시간 소통(중개인과 전화 또는 1:1 채팅)
- ⭐️ 매물 예약(PG 결제를 통한 매물 예약)

---

## 📸 스크린샷
<div align="leading">
  <img src="https://github.com/user-attachments/assets/bea52b9c-188d-4aa8-9347-febff6823b31" width="19%">
  <img src="https://github.com/user-attachments/assets/fbcfcaf7-3d3c-4815-9075-fa49ddc591ce" width="19%">
  <img src="https://github.com/user-attachments/assets/eff7cab0-2f73-45c5-ba99-f8512bf57b3a" width="19%">
  <img src="https://github.com/user-attachments/assets/b4a2bfdb-9782-4132-a34e-5f0f3bb51e14" width="19%">
  <img src="https://github.com/user-attachments/assets/c93963d1-5251-424f-bdc2-c7439b51bedc" width="19%">
</div>

---

## 🛠 개발 정보
- ⏰ 개발 기간: 3개월 (2025. 07 - 2025. 09)
- 👨‍💻 개발 인원: 3명 (iOS 1명, 서버 1명, 디자인 1명)
- 📋 담당 역할: iOS 개발
- 📱 최소 지원 버전: iOS 16.0+

---

## 📚 기술 스택
| 구분               | 기술 스택                                      |
|--------------------|-----------------------------------------------|
| 언어 및 UI| Swift (SwiftUI)                |
| 아키텍쳐       | MVVM                     |
| 반응형 프로그래밍          | Combine             |
| 네트워크            | Alamofire / Socket.IO                                  |
| 인증 및 보안                 | Keychain / JWT Token    |
| 데이터베이스                 | Realm |
| 지도 / 위치 서비스                 | CoreLocation / Naver Maps SDK |
| 웹 및 결제                 | WebKit / PG Payment |
| 푸시 알림                 | FCM (Firebase Cloud Messaging) |

---

## 💭 고려한 점
### **채팅 구현 - Socket.IO + Realm**

- **실시간 양방향 통신을 위한 Socket.IO 채택**
  - HTTP 폴링 방식 대비 낮은 레이턴시와 서버 부하 감소
  - 채팅방별 네임스페이스를 통한 효율적인 연결 관리
  - 이벤트 핸들링으로 안정적인 실시간 메시지 송수신 구현

- **Realm을 활용한 로컬 데이터 영속성 및 오프라인 지원**
  - 채팅 메시지를 로컬에 저장하여 네트워크 없이도 이전 대화 내용 조회 가능

- **3단계 데이터 소싱 전략**
  1. Realm에서 로컬 캐시 데이터 즉시 로드
  2. 서버 API로 최신 메시지 fetch
  3. Socket 실시간 메시지 수신

  → 세 가지 데이터(로컬, 서버, Socket)를 병합 및 정렬하여 채팅 구현

- **네트워크 상태 감지 및 자동 복구**
  - `NetworkMonitor`를 통해 네트워크 상태를 감지해서 재연결 시, 자동으로 최신 메시지 동기화
  - 토큰 만료 시, 자동 갱신 후 소켓 재연결 및 최신 메시지 동기화

- **키보드와 스크롤뷰 레이아웃**
  - `NotificationCenter`를 활용한 키보드 이벤트 감지
  - 키보드 높이만큼 전체 뷰를 위로 이동(`offset`)시켜 입력창과 채팅 화면이 키보드에 가려지지 않도록 처리
  - 디바이스별 Safe Area 하단 패딩을 고려하여 키보드 높이 계산
  - `ScrollViewReader`와 앵커를 활용한 자동 스크롤
    - 사용자가 하단에 있을 때만 자동 스크롤 활성화
    - 새 메시지 수신 시 자동으로 하단 스크롤

###

### **PG 결제 검증 로직 - 서버 기반 검증**
- **클라이언트-서버 2단계 검증 프로세스**
  1. **주문 생성 단계**: 서버에서 주문ID 및 가격 생성 → PG사 결제 요청 시 사용
  2. **결제 검증 단계**: PG사로부터 받은 결제ID를 서버로 전달하여 최종 검증

- **서버 검증의 이유**
  - 클라이언트만으로 검증 시, 결제 금액 등 데이터 위변조 및 중복 결제에 취약
  - PG사와 서버 간 직접 통신으로 결제 내역의 실제 데이터와 주문 데이터 비교
  - 결제ID를 통해 서버가 PG사 API로 결제 상태 조회 및 검증 수행

- **보안 강화 설계**
  - 주문 번호는 서버에서 생성하여 클라이언트 조작 방지
  - Access Token 기반 인증으로 검증 API 접근 제어

- **구현 흐름**
  1. 사용자 결제 버튼 클릭
  2. 서버에서 주문ID 등 주문 데이터 생성 및 발급
  3. Iamport SDK로 PG 결제창 호출 (WebView)
  4. 결제 성공 시, 결제ID 반환
  5. 서버가 PG사 API로 실제 결제 검증
  6. 검증 성공 시 매물 예약 상태 업데이트

###

### **BaseURL 및 APIKey 관리 - SPM을 통한 Local Package 방식**
- `.swift 파일`보다 휴먼 에러 가능성이 낮으며 모듈화를 통해 구조적으로 관리 가능
- `.plist/.xcconfig 파일`과 달리 타입 안정성을 가지고 자동완성 지원 및 빌드 타임 에러를 통한 휴먼 에러 발생 가능성 감소

**카카오 SDK App Key 관리**
- 기존의 네트워크 BaseURL 및 APIKey를 관리하는 Local Package에 App Key를 통합
- Run Script를 통해서 Local Package 기반으로 App Key를 추출하여 Configuration 생성 및 관리

###

### **HTTP 통신 허용을 위한 ATS(App Transport Security) 설정 - ~~특정 도메인에 대해서만 허용 방식~~ -> 전체 도메인 허용 방식**
- ATS에 대한 허용 처리는 Information Property List에서 가능

- 특정 도메인 예외 처리를 하려면 도메인이 필요

- 현재 BaseURL을 Local Package에서 관리

- 패키지의 소스 코드 파일에 있는 값을 읽어서 Info.plist에 적용 시키기 위해서, Run Script를 통해 소스 코드를 읽어서 Info.plist에 예외 처리 속성을 추가

- 🚨이 과정에서 추가된 속성에 도메인이 그대로 노출되기 때문에, Info.plist에 대한 Git Ignore처리와 Run Script 실행 시, Info.plist를 생성하는 방식으로 수정

- 🚨새로 생성된 Info.plist에 대해서 자동으로 Target과 Copy Bundle Resources으로 추가되며 빌드 시 오류 발생시키기 때문에 해당 설정을 제거 해주는 작업 필요

위 사항들을 고려해서 전체 도메인 허용 방식 선택
###

### **프로젝트 기기 최소 타겟 버전 설정 - iOS 16.0+**
<img width="250" alt="image" src="https://github.com/user-attachments/assets/24a047ba-3b9d-431f-9ddc-3e07f97eda65"/>

[iOS 버전별 점유율](https://developer.apple.com/kr/support/app-store/)

- 2025년 1월 21일 기준 아이폰 전체 기기 중 87%가 iOS 17.0 이상을 사용중인 점

- (iOS 18.0이 나오기 전 데이터 기준) 95% 이상이 iOS 16.0 이상을 사용했던 점

위 두가지 사항을 고려
###

### **이미지 파일 배율 설정 - @2x(2배율)과 @3x(3배율)**
<img width="547" alt="image" src="https://github.com/user-attachments/assets/dd2a3261-55ed-4900-a2be-7a2c55e8c2a9" />

[Apple 디자인 가이드](https://developer.apple.com/design/human-interface-guidelines/images)

iOS는 2배율과 3배율을 사용한다는 점을 고려

\* 참고 문서: [App Thinning / App Slicing 기술](https://developer.apple.com/kr/videos/play/wwdc2015/404)
###

---
