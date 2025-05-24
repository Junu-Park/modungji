//
//  AuthState.swift
//  Modungji
//
//  Created by 박준우 on 5/24/25.
//

import Foundation

final class AuthState: ObservableObject {
    @Published var isLogin: Bool = false
    
    var accessToken: String?
    var refreshToken: String?
    
    func login(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isLogin = true
    }
}
