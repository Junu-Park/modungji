//
//  SettingRepository.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import Foundation

struct SettingRepositoryImp: SettingRepository {
    private let networkManager: NetworkManager
    private let keychainManager: KeychainManager
    
    init(networkManager: NetworkManager, keychainManager: KeychainManager) {
        self.networkManager = networkManager
        self.keychainManager = keychainManager
    }
    
    func getMyProfile() async throws -> GetMyProfileResponseEntity {
        let result = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.getMyProfile, successDecodingType: GetMyProfileResponseDTO.self)
        
        switch result {
        case .success(let success):
            return success.convertToEntity()
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message)
        }
    }
    
    func getAuthPlatform() throws -> AuthPlatformType {
        let rawValue = try self.keychainManager.get(tokenType: .authPlatform)
        
        return AuthPlatformType(rawValue: rawValue)!
    }
    
    func uploadProfileImage(_ request: UploadFilesRequestEntity) async throws -> UploadProfileImageResponseEntity {
        let result = try await self.networkManager.requestEstateMultipartFiles(requestURL: EstateRouter.User.uploadProfileImage, dto: [request.convertToDTO()], successDecodingType: UploadProfileImageResponseDTO.self)
        
        switch result {
        case .success(let success):
            return success.convertToEntity()
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message)
        }
    }
    
    func updateMyProfile(_ request: UpdateMyProfileRequestEntity) async throws -> GetMyProfileResponseEntity {
        let result = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.updateMyProfile(body: request.convertToDTO()), successDecodingType: GetMyProfileResponseDTO.self)
        
        switch result {
        case .success(let success):
            return success.convertToEntity()
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message)
        }
    }
    
    func signOut() async throws {
        do {
            let _ = try await self.networkManager.requestEstate(requestURL: EstateRouter.User.logout)
            
            try self.keychainManager.delete(tokenType: .accessToken)
            try self.keychainManager.delete(tokenType: .refreshToken)
            try self.keychainManager.delete(tokenType: .userID)
            try self.keychainManager.delete(tokenType: .deviceToken)
            try self.keychainManager.delete(tokenType: .authPlatform)
        } catch {
            throw EstateErrorResponseEntity(message: "로그아웃 실패\n잠시 후, 다시 시도해주세요.")
        }
    }
}
