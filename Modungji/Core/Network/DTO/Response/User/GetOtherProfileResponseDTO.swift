//
//  GetOtherProfileResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct GetOtherProfileResponseDTO: Decodable {
    let user_id: String
    let nick: String
    let introduction: String?
    let profileImage: String?
}
