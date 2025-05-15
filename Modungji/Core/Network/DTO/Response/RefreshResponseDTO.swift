//
//  RefreshResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct RefreshResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
