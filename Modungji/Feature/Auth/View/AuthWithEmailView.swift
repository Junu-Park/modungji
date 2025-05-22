//
//  AuthWithEmailView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

// MARK: - AuthWithEmailView
struct AuthWithEmailView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    private let isSignUp: Bool
    
    init(isSignUp: Bool) {
        self.isSignUp = isSignUp
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            emailInputView()
            
            if self.isSignUp {
                nicknameInputView
            }

            passwordInputView()
                
            if self.isSignUp {
                passwordCheckInputView
            }
            
            Spacer()
            
            self.confirmButtonView()
        }
        .tint(.gray100)
        .font(PDFont.body2)
        .padding(20)
        .onAppear {
            self.viewModel.input.isSignUp = self.isSignUp
        }
        .onDisappear {
            self.viewModel.action(.resetInput)
        }
    }
}

// MARK: - AuthWithEmailView Component
extension AuthWithEmailView {
    @ViewBuilder
    func emailInputView() -> some View {
        TextField("이메일", text: self.$viewModel.input.email)
            .padding(8)
            .frame(height: 50)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
        
        if self.isSignUp {
            Text(self.viewModel.state.validateEmailResponseEntity.message)
                .foregroundStyle(self.viewModel.state.validateEmailResponseEntity.isValid ? .blue : .red)
                .font(PDFont.caption1)
                .padding([.top, .leading], 8)
        }
    }
    
    @ViewBuilder
    var nicknameInputView: some View {
        TextField("닉네임", text: self.$viewModel.input.nickname)
            .padding(8)
            .frame(height: 50)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
        Text("닉네임을 입력해주세요.")
            .foregroundStyle(self.viewModel.input.nickname.isEmpty ? .red : .blue)
            .font(PDFont.caption1)
            .padding([.top, .leading], 8)
    }
    
    @ViewBuilder
    func passwordInputView() -> some View {
        PasswordTextFieldView(isPasswordCheck: false)
            .padding(8)
            .frame(height: 50)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
        if self.isSignUp {
            Text("최소 8자 이상이며, 영문자, 숫자, 특수문자(@$!%*#?&)를 각각 1개 이상 포함")
                .foregroundStyle(self.viewModel.state.isValidatePassword ? .blue : .red)
                .font(PDFont.caption1)
                .padding([.top, .leading], 8)
        }
    }
    
    @ViewBuilder
    var passwordCheckInputView: some View {
        PasswordTextFieldView(isPasswordCheck: true)
            .padding(8)
            .frame(height: 50)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
        Text("동일한 비밀번호를 입력해주세요.")
            .foregroundStyle(self.viewModel.state.isMatchPasswordCheck ? .blue : .red)
            .font(PDFont.caption1)
            .padding([.top, .leading], 8)
    }
    
    func confirmButtonView() -> some View {
        Button {
            if isSignUp {
                viewModel.action(.signUpWithEmail)
            } else {
                viewModel.action(.loginWithEmail)
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .frame(height: 50)
                .overlay {
                    Text(self.isSignUp ? "이메일로 회원가입" : "이메일로 로그인")
                }
        }
        .disabled(!self.viewModel.state.canConfirmAuthWithEmail)
    }
}
