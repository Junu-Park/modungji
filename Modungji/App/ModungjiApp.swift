//
//  ModungjiApp.swift
//  Modungji
//
//  Created by 박준우 on 5/9/25.
//

import SwiftUI

import KakaoSDKCommon
import ModungjiSecret

@main
struct ModungjiApp: App {
    private let diContainer = DIContainer.getDefaultDIContainer()
    
    init() {
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: ModungjiSecret.Kakao.key)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .injectDependency(self.diContainer)
        }
    }
}
