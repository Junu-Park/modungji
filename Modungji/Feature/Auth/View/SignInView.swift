//
//  SignInView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Group {
                KakaoLoginButtonView()
                
                AppleLoginButtonView()
                
                EmailLoginButtonView()
            }
            .frame(height: 50)
            
            EmailSignUpButtonView()
        }
        .padding(20)
        .alert("에러", isPresented: self.$viewModel.state.showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(self.viewModel.state.errorMessage)
        }
    }
}

#Preview {
    SignInView()
}
