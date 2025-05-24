//
//  AuthView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import AuthenticationServices
import SwiftUI

// MARK: - AuthView
struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Group {
                self.kakaoLoginButton
                
                self.appleLoginButton
                
                self.emailLoginButton
            }
            .frame(height: 50)
            
            self.emailSignUpButton
        }
        .padding(20)
        .alert("에러", isPresented: self.$authViewModel.state.showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(self.authViewModel.state.errorMessage)
        }
    }
}

// MARK: - AuthView Component
extension AuthView {
    var kakaoLoginButton: some View {
        Button {
            self.authViewModel.action(.authWithKakao)
        } label: {
            Image(.kakaoLoginButton)
                .resizable()
        }
    }
    
    var appleLoginButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            self.authViewModel.action(.authWithApple(result: result))
        }
    }
    
    var emailLoginButton: some View {
        NavigationLink {
            AuthWithEmailView(authType: .login)
        } label: {
            RoundedRectangle(cornerRadius: 6)
                .stroke(.gray100, lineWidth: 1)
                .background {
                    Text("이메일 로그인")
                        .bold()
                        .font(PDFont.body1)
                        .foregroundStyle(.gray100)
                }
        }
    }
    
    var emailSignUpButton: some View {
        NavigationLink {
            AuthWithEmailView(authType: .signUp)
        } label: {
            Text("이메일로 회원가입")
                .bold()
                .font(PDFont.caption1)
                .foregroundStyle(.gray100)
        }
    }
}
