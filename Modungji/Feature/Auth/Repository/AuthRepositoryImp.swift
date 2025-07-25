//
//  AuthRepositoryImp.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//

import Foundation

import Alamofire

final class AuthRepositoryImp: AuthRepository {
    
    private let networkManager: NetworkManager
    private let kakaoManager: KakaoManager
    private let keychainManager: KeychainManager
    
    init(networkManager: NetworkManager, kakaoManager: KakaoManager, keychainManger: KeychainManager) {
        self.networkManager = networkManager
        self.kakaoManager = kakaoManager
        self.keychainManager = keychainManger
    }
    
    func checkEmailValidation(request: ValidateEmailRequestDTO) async throws -> ValidateEmailResponseEntity {
        
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.validateEmail(body: request), successDecodingType: ValidateEmailResponseDTO.self)
        
        switch response {
        case .success(let success):
            return ValidateEmailResponseEntity(isValid: true, message: success.message)
        case .failure(let failure):
            return ValidateEmailResponseEntity(isValid: false, message: failure.message)
        }
    }
    
    func authWithApple(request: LoginWithAppleRequestDTO) async throws -> LoginResponseEntity {
        
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.loginWithApple(body: request), successDecodingType: LoginResponseDTO.self)
        
        switch response {
        case .success(let success):
            
            return LoginResponseEntity(user_id: success.user_id, email: success.email, nick: success.nick, profileImage: success.profileImage, accessToken: success.accessToken, refreshToken: success.refreshToken)
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func authWithKakao() async throws -> LoginResponseEntity {
        let token = await self.kakaoManager.requestLogin()
        
        guard let token else {
            throw EstateErrorResponseEntity(message: "카카오 로그인 실패")
        }
        
        let request = LoginWithKakaoRequestDTO(oauthToken: token.accessToken)
        
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.loginWithKakao(body: request), successDecodingType: LoginResponseDTO.self)
        
        switch response {
        case .success(let success):
            return LoginResponseEntity(user_id: success.user_id, email: success.email, nick: success.nick, profileImage: success.profileImage, accessToken: success.accessToken, refreshToken: success.refreshToken)
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func loginWithEmail(request: LoginWithEmailRequestDTO) async throws -> LoginResponseEntity {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.loginWithEmail(body: request), successDecodingType: LoginResponseDTO.self)
        
        switch response {
        case .success(let success):
            
            return LoginResponseEntity(user_id: success.user_id, email: success.email, nick: success.nick, profileImage: success.profileImage, accessToken: success.accessToken, refreshToken: success.refreshToken)
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func saveToken(accessToken: String, refreshToken: String) async throws {
        do {
            try self.keychainManager.saveToken(tokenType: .accessToken, token: accessToken)
            try self.keychainManager.saveToken(tokenType: .refreshToken, token: refreshToken)
        } catch {
            throw EstateErrorResponseEntity(message: "토큰 저장 실패")
        }
    }
    
    func signUpWithEmail(request: JoinRequestDTO) async throws -> SignUpWithEmailResponseEntity {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.join(body: request), successDecodingType: JoinResponseDTO.self)
        
        switch response {
        case .success(let success):
            return SignUpWithEmailResponseEntity(user_id: success.user_id, email: success.email, nick: success.nick, accessToken: success.accessToken, refreshToken: success.refreshToken)
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func authWithAuto() async throws -> RefreshResponseEntity {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Auth.renewToken, successDecodingType: RefreshResponseDTO.self)
        
        switch response {
        case .success(let success):
            return RefreshResponseEntity(accessToken: success.accessToken, refreshToken: success.refreshToken)
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
}
