//
//  KakaoLoginButtonView.swift
//  Modungji
//
//  Created by 박준우 on 5/16/25.
//

import SwiftUI

import KakaoSDKUser

struct KakaoLoginButtonView: View {
    var body: some View {
        Button {
            // 카카오톡 설치 여부 체크
            if UserApi.isKakaoTalkLoginAvailable() {
                // 카카오톡으로 로그인
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let error {
                        print(error)
                        return
                    }
                    
                    guard let token else {
                        print("Token is nil")
                        return
                    }
                }
            } else {
                // 카카오 계정으로 로그인
                UserApi.shared.loginWithKakaoAccount { token, error in
                    if let error {
                        print(error)
                        return
                    }
                    
                    guard let token else {
                        print("Token is nil")
                        return
                    }
                }
            }
        } label: {
            Image(.kakaoLoginButton)
                .resizable()
        }
    }
}

#Preview {
    KakaoLoginButtonView()
}
