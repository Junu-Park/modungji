//
//  SignInUpWithEmailView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

struct SignInUpWithEmailView: View {
    @State private var email: String = ""
    @State private var nickname: String = ""
    @State private var password: String = ""
    @State private var passwordCheck: String = ""
    
    private let isSignUp: Bool
    
    init(isSignUp: Bool) {
        self.isSignUp = isSignUp
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Group {
                TextField("이메일", text: self.$email)
                
                if self.isSignUp {
                    TextField("닉네임", text: self.$nickname)
                }

                PasswordTextFieldView(password: self.$password, isPasswordCheck: false)
                    
                if self.isSignUp {
                    PasswordTextFieldView(password: self.$passwordCheck, isPasswordCheck: true)
                }
            }
            .padding(8)
            .frame(height: 50)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
            
            Spacer()
            
            self.signUpWithEmailButtonView()
        }
        .tint(.gray100)
        .font(PDFont.body2)
        .padding(20)
    }
    
    private func signUpWithEmailButtonView() -> some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .frame(height: 50)
                .overlay {
                    Text(self.isSignUp ? "이메일로 회원가입" : "이메일로 로그인")
                }
        }
    }
}
