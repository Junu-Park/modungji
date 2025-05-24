//
//  AuthWithEmailViewModel.swift
//  Modungji
//
//  Created by 박준우 on 5/22/25.
//

import Combine
import Foundation

final class AuthWithEmailViewModel: ObservableObject {
    struct Input {
        var email: String = ""
        var nickname: String = ""
        var password: String = ""
        var passwordCheck: String = ""
    }
    
    struct State {
        var emailValidationMessage: String = "이메일을 입력해주세요"
        var isEmailValid: Bool = false
        var isNicknameValid: Bool = false
        var isPasswordValid: Bool = false
        var isMatchPassword: Bool = false
        var canAuth: Bool = false
        var authType: AuthWithEmailType = .login
        var showAlert: Bool = false
        var alertMessage: String = ""
    }

    enum Action {
        case changeAuthType(_ type: AuthWithEmailType)
        case login
        case signUp
        case reset
    }
    
    @Published var state: State = .init()
    @Published var input: Input = .init()
    private var cancellables: Set<AnyCancellable> = .init()
    private let service: AuthService
    private let authState: AuthState
    
    init(service: AuthService, authState: AuthState) {
        self.service = service
        self.authState = authState
        self.transform()
    }
    
    func transform() {
        
        self.$input.map(\.email)
            .removeDuplicates()
            .filter { [weak self] email in
                guard let self, self.state.authType == .signUp else {
                    return false
                }
                
                // 이메일을 수정하는 동안, 버튼 비활성화
                self.state.canAuth = false
                
                return true
            }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [weak self] email -> AnyPublisher<ValidateEmailResponseEntity, Never> in
                guard let self else {
                    return Just(ValidateEmailResponseEntity(isValid: false, message: "잠시 후, 다시 시도해주세요."))
                        .eraseToAnyPublisher()
                }
                
                return Future { [weak self] promise in
                    guard let self else {
                        return promise(.success(ValidateEmailResponseEntity(isValid: false, message: "잠시 후, 다시 시도해주세요.")))
                    }
                    
                    Task {
                        do {
                            let result = try await self.service.checkEmailValidation(email)
                            promise(.success(result))
                        } catch {
                            promise(.success(ValidateEmailResponseEntity(isValid: false, message: "잠시 후, 다시 시도해주세요.")))
                        }
                    }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] entity in
                guard let self else {
                    return
                }
                self.state.emailValidationMessage = entity.message
                self.state.isEmailValid = entity.isValid
            }
            .store(in: &self.cancellables)
        
        self.$input
            .map(\.nickname)
            .removeDuplicates()
            .sink { [weak self] nickname in
                guard let self else {
                    return
                }
                
                self.state.isNicknameValid = !nickname.isEmpty
            }
            .store(in: &self.cancellables)
        
        Publishers.CombineLatest(self.$input.map(\.password), self.$input.map(\.passwordCheck))
            .removeDuplicates(by: ==)
            .sink { [weak self] password, passwordCheck in
                guard let self else {
                    return
                }
                
                self.state.isPasswordValid = self.service.checkPasswordValidation(password: password)
                
                self.state.isMatchPassword = self.service.checkPasswordCheckMatch(password: password, passwordCheck: passwordCheck)
            }
            .store(in: &self.cancellables)
        
        let signUpState = Publishers.CombineLatest4(
            self.$state.map(\.isEmailValid),
            self.$state.map(\.isNicknameValid),
            self.$state.map(\.isPasswordValid),
            self.$state.map(\.isMatchPassword))
            .removeDuplicates(by: ==)
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main)
            .map { email, nickname , password, passwordCheck in
                return email && nickname && password && passwordCheck
            }
        
        let loginState = Publishers.CombineLatest(
            self.$input.map(\.email),
            self.$input.map(\.password))
            .removeDuplicates(by: ==)
            .map { email, password in
                return !email.isEmpty && !password.isEmpty
            }
        
        Publishers.CombineLatest(signUpState, loginState)
            .removeDuplicates(by: ==)
            .map { [weak self] signUpState, loginState in
                guard let self else {
                    return false
                }
                
                return self.state.authType == .signUp ? signUpState : loginState
            }
            .sink { [weak self] canAuth in
                guard let self else {
                    return
                }
                
                self.state.canAuth = canAuth
            }
            .store(in: &self.cancellables)
    }
    
    func action(_ action: Action) {
        switch action {
        case .changeAuthType(let type):
            self.changeAuthType(type)
        case .login:
            self.login()
        case .signUp:
            self.signUp()
        case .reset:
            self.reset()
        }
    }
    
    private func changeAuthType(_ type: AuthWithEmailType) {
        self.state.authType = type
    }
    
    private func login() {
        Task {
            do {
                let request = LoginWithEmailRequestEntity(email: self.input.email, password: self.input.password)
                
                let response = try await self.service.loginWithEmail(request: request)
                
                await MainActor.run {
                    self.authState.login(accessToken: response.accessToken, refreshToken: response.refreshToken)
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.alertMessage = error.message
                    self.state.showAlert = true
                }
            }
        }
    }
    
    private func signUp() {
        Task {
            do {
                let request = SignUpWithEmailRequestEntity(email: self.input.email, password: self.input.password, nickname: self.input.nickname)
                
                let response = try await self.service.signUpWithEmail(request: request)
                
                await MainActor.run {
                    self.authState.login(accessToken: response.accessToken, refreshToken: response.refreshToken)
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.alertMessage = error.message
                    self.state.showAlert = true
                }
            }
        }
    }
    
    private func reset() {
        self.input = .init()
    }
}
