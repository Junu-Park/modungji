//
//  EmailLoginButtonView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

struct EmailLoginButtonView: View {
    var body: some View {
        NavigationLink {
            SignInUpWithEmailView(isSignUp: false)
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
}

#Preview {
    EmailLoginButtonView()
}
