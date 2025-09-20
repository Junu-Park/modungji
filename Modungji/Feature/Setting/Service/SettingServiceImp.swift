//
//  SettingService.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import UIKit

struct SettingServiceImp: SettingService {
    private let repository: SettingRepository
    
    init(repository: SettingRepository) {
        self.repository = repository
    }
    
    func getMyProfile() async throws -> GetMyProfileResponseEntity {
        return try await self.repository.getMyProfile()
    }
    
    func getAuthPlatform() throws -> AuthPlatformType {
        return try self.repository.getAuthPlatform()
    }
    
    func updateMyProfile(nickname: String?, introduction: String?, phoneNumber: String?, profileImage: UIImage?) async throws -> GetMyProfileResponseEntity {
        var imageURL: String?
        if let image = profileImage {
            guard let data = image.convertUIImageToJPEGData(targetSize: 1000000) else {
                throw EstateErrorResponseEntity(message: "이미지 압축 실패")
            }
            let userID = try KeychainManager().get(tokenType: .userID)
            let type = MultipartType.jpeg
            let imageRequest = UploadFilesRequestEntity(data: data, key: "profile", name: "\(userID) ProfileImage.\(type.rawValue)", type: type)
            let imageResponse = try await self.repository.uploadProfileImage(imageRequest)
            
            imageURL = imageResponse.imageURL
        }
        
        let updateRequest = UpdateMyProfileRequestEntity(nickname: nickname, introduction: introduction, phoneNumber: phoneNumber, profileImage: imageURL)
        return try await self.repository.updateMyProfile(updateRequest)
    }
    
    func signOut() async throws {
        try await self.repository.signOut()
    }
}
