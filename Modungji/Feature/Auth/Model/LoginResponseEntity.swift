//
//  LoginResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//

import Foundation

struct LoginResponseEntity: Equatable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
}
