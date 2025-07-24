//
//  AuthRepository.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//

import Foundation

import Alamofire

protocol AuthRepository {
    func checkEmailValidation(request: ValidateEmailRequestDTO) async throws -> ValidateEmailResponseEntity
    func authWithApple(request: LoginWithAppleRequestDTO) async throws -> LoginResponseEntity
    func authWithKakao() async throws -> LoginResponseEntity
    func loginWithEmail(request: LoginWithEmailRequestDTO) async throws -> LoginResponseEntity
    func saveToken(accessToken: String, refreshToken: String) async throws
    @discardableResult func signUpWithEmail(request: JoinRequestDTO) async throws -> SignUpWithEmailResponseEntity
    func authWithAuto() async throws -> RefreshResponseEntity
}
