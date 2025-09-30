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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var onLaunchScreen: Bool = true
    
    private let diContainer = DIContainer.getDefaultDIContainer()
    
    init() {
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: ModungjiSecret.Kakao.key)
        
        // 네이버지도 SDK 클라이언트 ID 지정
        NMFAuthManager.shared().ncpKeyId = ModungjiSecret.Naver.clientID
    }
    
    var body: some Scene {
        WindowGroup {
            if self.onLaunchScreen {
                self.buildLaunchScreen()
            } else {
                RootView()
                    .injectDependency(self.diContainer)
            }
        }
    }
    
    @ViewBuilder
    private func buildLaunchScreen() -> some View {
        ZStack {
            Color.brightCream
            
            VStack(spacing: 16) {
                Text("모둥지")
                    .foregroundStyle(.brightWood)
                    .font(YHFont.launchScreenTitle)
                
                Image(.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            self.onLaunchScreen = false
        }
    }
}
