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
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleExpiredRefreshToken),
            name: .expiredRefreshToken,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .expiredRefreshToken, object: nil)
    }
    
    func login(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isLogin = true
    }
    
    @objc private func handleExpiredRefreshToken() {
        Task {
            await MainActor.run {
                self.accessToken = nil
                self.refreshToken = nil
                self.isLogin = false
            }
        }
    }
}
