//
//  AuthPlatformType.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import SwiftUI

enum AuthPlatformType: String {
    case apple = "애플"
    case kakao = "카카오"
    case email = "이메일"
    
    var color: Color {
        switch self {
        case .apple:
            return .gray100
        case .kakao:
            return .yellow
        case .email:
            return .brightCream
        }
    }
}
