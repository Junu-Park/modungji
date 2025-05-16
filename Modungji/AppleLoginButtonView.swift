//
//  AppleLoginButtonView.swift
//  SocialLoginTest
//
//  Created by 박준우 on 5/16/25.
//

import AuthenticationServices
import SwiftUI

struct AppleLoginButtonView: View {
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    print(appleIDCredential.email ?? "No email")
                    print(appleIDCredential.fullName ?? "No full name")
                    
                    let token = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) ?? "No identity token"
                    print(token)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

#Preview {
    AppleLoginButtonView()
}
