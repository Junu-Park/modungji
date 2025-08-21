//
//  AuthServiceImp.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//

import AuthenticationServices
import Foundation

struct AuthServiceImp: AuthService {
    
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func checkEmailValidation(_ email: String) async throws -> ValidateEmailResponseEntity {
        
        if email.isEmpty {
            return ValidateEmailResponseEntity(isValid: false, message: "이메일을 입력해주세요.")
        }
        
//        let emailPattern = "^[A-Za-z0-9]+@[A-Za-z0-9.]+(?:\\.[A-Za-z0-9]+)*\\.[A-Za-z]{2,}$"
        let emailPattern = /^[A-Za-z0-9]+@[A-Za-z0-9.]+(?:\.[A-Za-z0-9]+)*\.[A-Za-z]{2,}$/
        if email.wholeMatch(of: emailPattern) == nil {
            return ValidateEmailResponseEntity(isValid: false, message: "유효하지 않은 이메일")
        }
        
        return try await self.repository.checkEmailValidation(request: ValidateEmailRequestDTO(email: email))
    }
    
    func authWithApple(result: Result<ASAuthorization, any Error>) async throws -> LoginResponseEntity {
        switch result {
        case .success(let success):
            guard let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential else {
                throw EstateErrorResponseEntity(message: "애플 로그인 실패")
            }
            
            guard let token = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) else {
                throw EstateErrorResponseEntity(message: "애플 로그인 실패")
            }
            
            let deviceToken = try? self.repository.getDeviceToken()
            
            var request = LoginWithAppleRequestDTO(idToken: token, deviceToken: deviceToken)
            
            if let first = appleIDCredential.fullName?.givenName, let family = appleIDCredential.fullName?.familyName {
                request.nick = "\(family) \(first)"
            }
            
            let response = try await self.repository.authWithApple(request: request)
            
            try self.repository.saveLoginData(accessToken: response.accessToken, refreshToken: response.refreshToken, userID: response.user_id)
            
            return response
            
        case .failure:
            throw EstateErrorResponseEntity(message: "애플 로그인 실패")
        }
    }
    
    func authWithKakao() async throws -> LoginResponseEntity {
        let response = try await self.repository.authWithKakao()

        try self.repository.saveLoginData(accessToken: response.accessToken, refreshToken: response.refreshToken, userID: response.user_id)
        
        return response
    }
    
    func loginWithEmail(request: LoginWithEmailRequestEntity) async throws -> LoginResponseEntity {
        let deviceToken = try? self.repository.getDeviceToken()
        
        let requestDTO = LoginWithEmailRequestDTO(email: request.email, password: request.password, deviceToken: deviceToken)
        let response = try await self.repository.loginWithEmail(request: requestDTO)
        
        try self.repository.saveLoginData(accessToken: response.accessToken, refreshToken: response.refreshToken, userID: response.user_id)
        
        return response
    }
    
    func signUpWithEmail(request: SignUpWithEmailRequestEntity) async throws -> LoginResponseEntity {
        let requestDTO = JoinRequestDTO(email: request.email, password: request.password, nick: request.nickname)
        
        try await self.repository.signUpWithEmail(request: requestDTO)
        
        let deviceToken = try? self.repository.getDeviceToken()
        
        let response = try await self.repository.loginWithEmail(request: LoginWithEmailRequestDTO(email: request.email, password: request.password, deviceToken: deviceToken))
        
        return response
    }
    
    func checkPasswordValidation(password: String) -> Bool {
        let passwordPattern = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*#?&]).{8,}$/
        
        if password.wholeMatch(of: passwordPattern) == nil {
            return false
        }
        return true
    }
    
    func checkPasswordCheckMatch(password: String, passwordCheck: String) -> Bool {
        return !password.isEmpty && (password == passwordCheck)
    }
    
    func authWithAuto() async throws -> RefreshResponseEntity {
        let response = try await self.repository.authWithAuto()
        let userID = try KeychainManager().get(tokenType: .userID)
        try self.repository.saveLoginData(accessToken: response.accessToken, refreshToken: response.refreshToken, userID: userID)
        
        let deviceToken = try KeychainManager().get(tokenType: .deviceToken)
        let body = UpdateDeviceTokenRequestDTO(deviceToken: deviceToken)
        try await self.repository.updateDeviceToken(body: body)
        
        return response
    }
}
