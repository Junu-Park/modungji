//
//  UpdateMyProfileRequestDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct UpdateMyProfileRequestDTO: Encodable {
    var nick: String?
    var introduction: String?
    var phoneNumber: String?
    var profileImage: String?
}
