//
//  LoginWithKakaoRequestDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct LoginWithKakaoRequestDTO: Encodable {
    var oauthToken: String
    var deviceToken: String?
}
