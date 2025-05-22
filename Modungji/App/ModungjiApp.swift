//
//  ModungjiApp.swift
//  Modungji
//
//  Created by 박준우 on 5/9/25.
//

import SwiftUI

import KakaoSDKAuth
import KakaoSDKCommon
import ModungjiSecret

@main
struct ModungjiApp: App {
    @StateObject private var authViewModel: AuthViewModel
    
    init() {
        KakaoSDK.initSDK(appKey: ModungjiSecret.Kakao.key)
        
        let authRepository = AuthRepositoryImp(networkManager: NetworkManager(), kakaoManager: KakaoManager(), keychainManger: KeychainManager())
        let authService = AuthServiceImp(
            repository: authRepository
        )
        
        self._authViewModel = StateObject(wrappedValue: AuthViewModel(service: authService))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AuthView()
                    .onOpenURL { url in
                        if AuthApi.isKakaoTalkLoginUrl(url) {
                            guard AuthController.handleOpenUrl(url: url) else {
                                print("유효하지 않은 리다이렉트 URL")
                                return
                            }
                        } else {
                            print("카카오톡이 아닌 다른 곳에서 리다이렉트된 URL")
                        }
                    }
            }
            .environmentObject(authViewModel)
        }
    }
}
