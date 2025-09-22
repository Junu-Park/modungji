//
//  UpdateMyProfileRequestEntity.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import Foundation

struct UpdateMyProfileRequestEntity {
    var nickname: String?
    var introduction: String?
    var phoneNumber: String?
    var profileImage: String?
    
    func convertToDTO() -> UpdateMyProfileRequestDTO {
        return .init(
            nick: self.nickname,
            introduction: self.introduction,
            phoneNum: self.phoneNumber,
            profileImage: self.profileImage
        )
    }
}
