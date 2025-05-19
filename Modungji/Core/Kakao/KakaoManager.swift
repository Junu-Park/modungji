//
//  KakaoManager.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//

import Foundation

import KakaoSDKAuth
import KakaoSDKUser

final class KakaoManager {
    
    @MainActor
    func requestLogin() async -> OAuthToken? {
        await withCheckedContinuation { continuation in
            // 카카오톡 설치 여부 체크
            if UserApi.isKakaoTalkLoginAvailable() {
                // 카카오톡으로 로그인
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let error {
                        continuation.resume(returning: nil)
                    }
                    
                    continuation.resume(returning: token)
                }
            } else {
                // 카카오 계정으로 로그인
                UserApi.shared.loginWithKakaoAccount { token, error in
                    if let error {
                        continuation.resume(returning: nil)
                    }
                    
                    continuation.resume(returning: token)
                }
            }
        }
    }
}
