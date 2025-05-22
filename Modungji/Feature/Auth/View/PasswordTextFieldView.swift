//
//  PasswordTextFieldView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

// MARK: - PasswordTextFieldView
struct PasswordTextFieldView: View {
    @EnvironmentObject var viewModel: AuthViewModel
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
                SecureField(self.placeholder, text: isPasswordCheck ? self.$viewModel.input.passwordCheck : self.$viewModel.input.password)
            } else {
                TextField(self.placeholder, text: isPasswordCheck ? self.$viewModel.input.passwordCheck : self.$viewModel.input.password)
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
