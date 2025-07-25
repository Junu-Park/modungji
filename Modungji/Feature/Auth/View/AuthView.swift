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
    @EnvironmentObject var pathModel: PathModel
    @StateObject private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
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
        .onAppear {
            self.viewModel.action(.authWithAuto)
        }
        .padding(20)
        .alert("에러", isPresented: self.$viewModel.state.showErrorAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(self.viewModel.state.errorMessage)
        }
    }
}

// MARK: - AuthView Component
extension AuthView {
    var kakaoLoginButton: some View {
        Button {
            self.viewModel.action(.authWithKakao)
        } label: {
            Image(.kakaoLoginButton)
                .resizable()
        }
    }
    
    var appleLoginButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            self.viewModel.action(.authWithApple(result: result))
        }
    }
    
    var emailLoginButton: some View {
        Button {
            self.pathModel.push(.authWithEmail(authType: .login))
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
        Button {
            self.pathModel.push(.authWithEmail(authType: .signUp))
        } label: {
            Text("이메일로 회원가입")
                .bold()
                .font(PDFont.caption1)
                .foregroundStyle(.gray100)
        }
    }
}
