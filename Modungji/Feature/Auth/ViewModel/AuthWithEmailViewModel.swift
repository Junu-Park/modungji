//
//  AuthWithEmailViewModel.swift
//  Modungji
//
//  Created by 박준우 on 5/22/25.
//

import Combine
import Foundation

final class AuthWithEmailViewModel {
    struct Input {
        var email: String = ""
        var nickname: String = ""
        var password: String = ""
        var passwordCheck: String = ""
    }
    
    struct State {
        var emailValidationMessage: String = ""
        var isEmailValid: Bool = false
        var isNicknameValid: Bool = false
        var isPasswordValid: Bool = false
        var isMatchPassword: Bool = false
        var canAuth: Bool = false
    }

    enum Action {
        case login
        case signUp
    }
    
    @Published var state: State = .init()
    @Published var input: Input = .init()
    private var cancellables: Set<AnyCancellable> = .init()
    private var service: AuthService
    
    init(service: AuthService) {
        self.service = service
        self.transform()
    }
    
    func transform() {
        
    }
    
    func action(_ action: Action) {
        switch action {
        case .login:
            self.login()
        case .signUp:
            self.signUp()
        }
    }
    
    private func login() {
        
    }
    
    private func signUp() {
        
    }
}
