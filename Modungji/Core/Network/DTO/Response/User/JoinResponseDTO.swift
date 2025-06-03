//
//  JoinResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct JoinResponseDTO: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
