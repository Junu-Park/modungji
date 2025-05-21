//
//  KakaoLoginButtonView.swift
//  Modungji
//
//  Created by 박준우 on 5/16/25.
//

import SwiftUI

import KakaoSDKUser

struct KakaoLoginButtonView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Button {
            viewModel.action(.authWithKakao)
        } label: {
            Image(.kakaoLoginButton)
                .resizable()
        }
    }
}

#Preview {
    KakaoLoginButtonView()
}
