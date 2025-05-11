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
