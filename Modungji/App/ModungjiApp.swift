//
//  ModungjiApp.swift
//  Modungji
//
//  Created by 박준우 on 5/9/25.
//

import SwiftUI

import KakaoSDKCommon
import ModungjiSecret
import NMapsMap

@main
struct ModungjiApp: App {
    private let diContainer = DIContainer.getDefaultDIContainer()
    
    init() {
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: ModungjiSecret.Kakao.key)
        
        // 네이버지도 SDK 클라이언트 ID 지정
        NMFAuthManager.shared().ncpKeyId = ModungjiSecret.Naver.clientID
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .injectDependency(self.diContainer)
        }
    }
}
