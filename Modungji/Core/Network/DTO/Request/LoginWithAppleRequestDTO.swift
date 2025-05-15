//
//  LoginWithAppleRequestDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct LoginWithAppleRequestDTO: Encodable {
    var idToken: String
    var deviceToken: String?
    var nick: String?
}
