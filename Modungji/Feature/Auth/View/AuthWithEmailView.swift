//
//  AuthWithEmailView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

// MARK: - AuthWithEmailView
struct AuthWithEmailView: View {
    @EnvironmentObject var pathModel: PathModel
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var authWithEmailViewModel: AuthWithEmailViewModel
    
    private let authType: AuthWithEmailType
    
    init(authType: AuthWithEmailType) {
        self.authType = authType
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            self.emailInputView()
            
            if self.authWithEmailViewModel.state.authType == .signUp {
                self.nicknameInputView
            }

            self.passwordInputView()
                
            if self.authWithEmailViewModel.state.authType == .signUp {
                self.passwordCheckInputView
            }
            
            Spacer()
            
            self.confirmButtonView()
        }
        .tint(.gray100)
        .font(PDFont.body2)
        .padding(20)
        .onAppear {
            self.authWithEmailViewModel.action(.changeAuthType(self.authType))
        }
        .onDisappear {
            self.authWithEmailViewModel.action(.reset)
        }
        .alert(self.authWithEmailViewModel.state.alertMessage, isPresented: self.$authWithEmailViewModel.state.showAlert) {
            Button("닫기") { }
        }
        .customOnChange(value: self.authState.isLogin) { isLogin in
            if isLogin {
                self.pathModel.pop()
            }
        }
    }
}

// MARK: - AuthWithEmailView Component
extension AuthWithEmailView {
    @ViewBuilder
    func emailInputView() -> some View {
        TextField("이메일", text: self.$authWithEmailViewModel.input.email)
            .padding(8)
            .frame(height: 50)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
        
        if self.authWithEmailViewModel.state.authType == .signUp {
            Text(self.authWithEmailViewModel.state.emailValidationMessage)
                .foregroundStyle(self.authWithEmailViewModel.state.isEmailValid ? .blue : .red)
                .font(PDFont.caption1)
                .padding([.top, .leading], 8)
        }
    }
    
    @ViewBuilder
    var nicknameInputView: some View {
        TextField("닉네임", text: self.$authWithEmailViewModel.input.nickname)
            .padding(8)
            .frame(height: 50)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
        Text("닉네임을 입력해주세요.")
            .foregroundStyle(self.authWithEmailViewModel.state.isNicknameValid ? .blue : .red)
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
        if self.authWithEmailViewModel.state.authType == .signUp {
            Text("최소 8자 이상이며, 영문자, 숫자, 특수문자(@$!%*#?&)를 각각 1개 이상 포함")
                .foregroundStyle(self.authWithEmailViewModel.state.isPasswordValid ? .blue : .red)
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
            .foregroundStyle(self.authWithEmailViewModel.state.isMatchPassword ? .blue : .red)
            .font(PDFont.caption1)
            .padding([.top, .leading], 8)
    }
    
    func confirmButtonView() -> some View {
        Button {
            if self.authWithEmailViewModel.state.authType == .signUp {
                authWithEmailViewModel.action(.signUp)
            } else {
                authWithEmailViewModel.action(.login)
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .frame(height: 50)
                .overlay {
                    Text(self.authWithEmailViewModel.state.authType == .signUp ? "이메일로 회원가입" : "이메일로 로그인")
                }
        }
        .disabled(!self.authWithEmailViewModel.state.canAuth)
    }
}

// MARK: - PasswordTextFieldView
private struct PasswordTextFieldView: View {
    @EnvironmentObject var authWithEmailViewModel: AuthWithEmailViewModel
    @State private var isSecure: Bool = true
    
    private let isPasswordCheck: Bool
    private var placeholder: String {
        return self.isPasswordCheck ? "비밀번호 확인" : "비밀번호"
    }
    private var secureImage: String {
        return self.isSecure ? "eye.slash" : "eye"
    }
    
    init(isPasswordCheck: Bool = false) {
        self.isPasswordCheck = isPasswordCheck
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if self.isSecure {
                SecureField(self.placeholder, text: isPasswordCheck ? self.$authWithEmailViewModel.input.passwordCheck : self.$authWithEmailViewModel.input.password)
            } else {
                TextField(self.placeholder, text: isPasswordCheck ? self.$authWithEmailViewModel.input.passwordCheck : self.$authWithEmailViewModel.input.password)
            }
            
            self.secureButton
        }
        .keyboardType(.alphabet)
    }
}

// MARK: - PasswordTextFieldView Component
extension PasswordTextFieldView {
    var secureButton: some View {
        Button {
            self.isSecure.toggle()
        } label: {
            Image(systemName: self.secureImage)
                .frame(width: 30, height: 30)
        }
    }
}
