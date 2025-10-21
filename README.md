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
### **BaseURL 및 APIKey 관리 - SPM을 통한 Local Package 방식**
`.swift 파일 + .gitignore 방식`보다 휴먼 에러 가능성이 낮으며 모듈화를 통해 구조적으로 관리 가능

`.plist/.xcconfig 파일`과 달리 타입 안정성을 가지고 자동완성 지원과 빌드 타임 에러 통한 휴먼 에러 발생 가능성 감소

\* 카카오 SDK App Key 관리

기존의 네트워크 BaseURL 및 APIKey를 관리하는 Local Package에 App Key를 통합

\+ Run Script를 통해서 Local Package 기반으로 App Key를 추출해서 Configuration 생성해서 관리
###

### **HTTP 통신 허용을 위한 ATS(App Transport Security) 설정 - ~~특정 도메인에 대해서만 허용 방식~~ -> 전체 도메인 허용 방식**
ATS에 대한 허용 처리는 Information Property List에서 가능

특정 도메인 예외 처리를 하려면 도메인이 필요

현재 BaseURL을 Local Package에서 관리

패키지의 소스 코드 파일에 있는 값을 읽어서 Info.plist에 적용 시키기 위해서는

Run Script를 통해 소스 코드를 읽어서 Info.plist에 예외 처리 속성을 추가

🚨이 과정에서 추가된 속성에 도메인이 그대로 노출되기 때문에, Info.plist에 대한 Git Ignore처리와 Run Script 실행 시, Info.plist를 생성하는 방식으로 수정

🚨새로 생성된 Info.plist에 대해서 자동으로 Target과 Copy Bundle Resources으로 추가되며 빌드 시 오류 발생시키기 때문에 해당 설정을 제거 해주는 작업 필요

위 두가지 사항을 고려해서 전체 도메인 허용 방식 선택
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

## Token 관리 방식
**Keychain 저장 방식**

vs UserDefaults
