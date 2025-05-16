//
//  ModungjiApp.swift
//  Modungji
//
//  Created by 박준우 on 5/9/25.
//

import SwiftUI

import EstateAPI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct ModungjiApp: App {
    
    init() {
        KakaoSDK.initSDK(appKey: EstateAPI.kakaoKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
