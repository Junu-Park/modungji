//
//  LoginResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

/// 이메일 로그인, 카카오 로그인, 애플 로그인에서 공통으로 사용하는 DTO
struct LoginResponseDTO: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
}
