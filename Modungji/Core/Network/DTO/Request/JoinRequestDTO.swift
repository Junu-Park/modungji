//
//  JoinRequestDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct JoinRequestDTO: Encodable {
    var email: String
    var password: String
    var nick: String
    var phoneNum: String?
    var introduction: String?
    var deviceToken: String?
}
