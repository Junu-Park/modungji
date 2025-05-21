//
//  AuthService.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//

import AuthenticationServices
import Foundation

protocol AuthService {
    func checkEmailValidation(_ email: String) async throws -> ValidateEmailResponseEntity
    func authWithApple(result: Result<ASAuthorization, any Error>) async throws -> LoginResponseEntity
    func authWithKakao() async throws -> LoginResponseEntity
    func loginWithEmail(request: LoginWithEmailRequestEntity) async throws -> LoginResponseEntity
    
    /// 회원가입 후, 바로 자동 로그인
    func signUpWithEmail(request: SignUpWithEmailRequestEntity) async throws -> LoginResponseEntity
    
    func checkPasswordValidation(password: String) -> Bool
    func checkPasswordCheckMatch(password: String, passwordCheck: String) -> Bool
}
