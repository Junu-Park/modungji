//
//  AppleLoginButtonView.swift
//  SocialLoginTest
//
//  Created by 박준우 on 5/16/25.
//

import AuthenticationServices
import SwiftUI

struct AppleLoginButtonView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            self.viewModel.action(.authWithApple(result: result))
        }
    }
}

#Preview {
    AppleLoginButtonView()
}
