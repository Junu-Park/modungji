//
//  SettingService.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import UIKit

protocol SettingService {
    func getMyProfile() async throws -> GetMyProfileResponseEntity
    func getAuthPlatform() throws -> AuthPlatformType
    func updateMyProfile(nickname: String?, introduction: String?, phoneNumber: String?, profileImage: UIImage?) async throws -> GetMyProfileResponseEntity
    func signOut() async throws
}
