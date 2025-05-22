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
            
            if self.isSignUp {
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
                
            if self.isSignUp {
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
            
            Spacer()
            
            self.signUpWithEmailButtonView()
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
    
    private func signUpWithEmailButtonView() -> some View {
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
        // TODO: ViewModel로 빼야하나?
        .disabled(
            {
                if self.isSignUp {
                    return !(self.viewModel.state.isValidatePassword && self.viewModel.state.isMatchPasswordCheck && self.viewModel.state.validateEmailResponseEntity.isValid && !self.viewModel.input.nickname.isEmpty)
                } else {
                    return self.viewModel.input.email.isEmpty || self.viewModel.input.password.isEmpty
                }
            }()
        )
    }
}
