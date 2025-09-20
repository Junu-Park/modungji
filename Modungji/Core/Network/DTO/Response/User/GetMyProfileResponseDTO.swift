//
//  GetMyProfileResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

/// 내 프로필 조회, 내 프로필 수정에서 공통으로 사용하는 DTO
struct GetMyProfileResponseDTO: Decodable {
    let user_id: String
    let email: String?
    let nick: String
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
    
    func convertToEntity() -> GetMyProfileResponseEntity {
        return .init(
            userID: self.user_id,
            email: self.email ?? "",
            nickname: self.nick,
            introduction: self.introduction ?? "",
            profileImage: self.profileImage ?? "",
            phoneNumber: self.phoneNum ?? ""
        )
    }
}
