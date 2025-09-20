//
//  SettingRepository.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import Foundation

protocol SettingRepository {
    func getMyProfile() async throws -> GetMyProfileResponseEntity
    func getAuthPlatform() throws -> AuthPlatformType
    func uploadProfileImage(_ request: UploadFilesRequestEntity) async throws -> UploadProfileImageResponseEntity
    func updateMyProfile(_ request: UpdateMyProfileRequestEntity) async throws -> GetMyProfileResponseEntity
    func signOut() async throws
}
