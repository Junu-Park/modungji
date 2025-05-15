//
//  GetMyProfileResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct GetMyProfileResponseDTO: Decodable {
    let user_id: String
    let email: String?
    let nick: String
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
}
