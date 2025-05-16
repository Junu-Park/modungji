//
//  ModungjiApp.swift
//  Modungji
//
//  Created by 박준우 on 5/9/25.
//

import SwiftUI

import EstateAPI
import KakaoSDKCommon

@main
struct ModungjiApp: App {
    
    init() {
        KakaoSDK.initSDK(appKey: EstateAPI.kakaoKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
