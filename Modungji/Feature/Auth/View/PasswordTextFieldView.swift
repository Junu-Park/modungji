//
//  PasswordTextFieldView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

struct PasswordTextFieldView: View {
    @State private var isSecure: Bool = true
    @Binding var password: String
    
    private let placeholder: String
    private var secureImage: String {
        return self.isSecure ? "eye.slash" : "eye"
    }
    
    init(password: Binding<String>, isPasswordCheck: Bool = false) {
        self._password = password
        self.placeholder = isPasswordCheck ? "비밀번호 확인" : "비밀번호"
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if self.isSecure {
                SecureField(self.placeholder, text: self.$password)
            } else {
                TextField(self.placeholder, text: self.$password)
            }
            
            self.secureButtonView()
        }
    }
    
    private func secureButtonView() -> some View {
        Button {
            self.isSecure.toggle()
        } label: {
            Image(systemName: self.secureImage)
                .frame(width: 30, height: 30)
        }
    }
}
