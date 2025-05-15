//
//  LoginWithEmailRequestDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct LoginWithEmailRequestDTO: Encodable {
    var email: String
    var password: String
    var deviceToken: String?
}
