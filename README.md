# 모둥지

## 프로젝트 소개
부동산 어플 프로젝트

## 프로젝트 기간
2025년 5월 9일 금요일 ~

## 프로젝트 폴더링
Feature(기능) 단위 폴더링

Project
- App
- Common
- Core
- Feature
- Resource


## 프로젝트 기기 최소 타겟 버전 설정
**iOS 16.0 +**

<img width="250" alt="image" src="https://github.com/user-attachments/assets/24a047ba-3b9d-431f-9ddc-3e07f97eda65"/>

[iOS 버전별 점유율](https://developer.apple.com/kr/support/app-store/)

2025년 1월 21일 기준 아이폰 전체 기기 중 87%가 iOS 17.0 이상을 사용중인 점과 

(iOS 18.0이 나오기 전 데이터 기준) 95% 이상이 iOS 16.0 이상을 사용했던 점을 고려

## 디자인 시스템
### 이미지 파일 설정
**@2x(2배율)과 @3x(3배율)**

<img width="547" alt="image" src="https://github.com/user-attachments/assets/dd2a3261-55ed-4900-a2be-7a2c55e8c2a9" />

[Apple 디자인 가이드](https://developer.apple.com/design/human-interface-guidelines/images)

프로젝트 타겟 OS가 iOS이고 iOS는 2배율과 3배율을 사용한다는 점을 고려

\* [App Thinning / App Slicing 기술](https://developer.apple.com/kr/videos/play/wwdc2015/404)

## 프로젝트 네트워크 BaseURL 및 APIKey 설정
**SPM을 통한 Local Package(+ .gitignore)로 관리**

`.swift 파일 + .gitignore 방식`보다 휴먼 에러 가능성이 낮으며 모듈화를 통해 구조적으로 관리 가능

`.plist/.xcconfig 파일 + .gitignore 방식`과 달리 타입 안정성을 가지고 자동완성 지원과 빌드 타임 에러 통한 휴먼 에러 발생 가능성 감소

## HTTP 통신 허용을 위한 ATS(App Transport Security) 설정
~~**특정 도메인에 대해서만 허용 방식**~~

ATS에 대한 허용 처리는 Information Property List에서 가능

특정 도메인 예외 처리를 하려면 도메인이 필요

현재 BaseURL을 Local Package에서 관리

패키지의 소스 코드 파일에 있는 값을 읽어서 Info.plist에 적용 시키기 위해서는

Run Script를 통해 소스 코드를 읽어서 Info.plist에 예외 처리 속성을 추가

🚨이 과정에서 추가된 속성에 도메인이 그대로 노출되기 때문에, Info.plist에 대한 Git Ignore처리와 Run Script 실행 시, Info.plist를 생성하는 방식으로 수정

🚨새로 생성된 Info.plist에 대해서 자동으로 Target과 Copy Bundle Resources으로 추가되며 빌드 시 오류 발생시키기 때문에 해당 설정을 제거 해주는 작업 필요

⬇

**전체 도메인 허용 방식**

## 카카오 SDK App Key 관리
**Local Package 기반 Configuration 파일로 관리**

기존의 네트워크 BaseURL 및 APIKey를 관리하는 Local Package에 App Key를 통합 관리

Run Script를 통해서 Local Package 기반으로 App Key를 추출해서 Configuration 생성해서 관리

## Token 관리 방식
**Keychain 저장 방식**

vs UserDefaults vs Realm(서드파티 라이브러리)

## 네트워크 에러 처리 방식
Result vs Error Throw

## 로직을 class이 아닌 struct으로 구현한 이유

## @EnvironmentObject가 아닌 @Environment를 사용한 이유
