//
//  SignInView.swift
//  Modungji
//
//  Created by 박준우 on 5/18/25.
//

import SwiftUI

struct SignInView: View {
    var body: some View {
        VStack(spacing: 20) {
            Group {
                KakaoLoginButtonView()
                
                AppleLoginButtonView()
                
                EmailLoginButtonView()
            }
            .frame(height: 50)
            .padding(.horizontal, 20)
            
            EmailSignUpButtonView()
        }
    }
}

#Preview {
    SignInView()
}
