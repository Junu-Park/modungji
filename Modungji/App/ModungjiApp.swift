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
    
    init() {
        KakaoSDK.initSDK(appKey: ModungjiSecret.Kakao.key)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SignInView()
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
        }
    }
}
