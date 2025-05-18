//
//  EmailSignUpButtonView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

struct EmailSignUpButtonView: View {
    var body: some View {
        NavigationLink {
            SignInUpWithEmailView(isSignUp: true)
        } label: {
            Text("이메일로 회원가입")
                .bold()
                .font(PDFont.caption1)
                .foregroundStyle(.gray100)
        }
    }
}

#Preview {
    EmailSignUpButtonView()
}
