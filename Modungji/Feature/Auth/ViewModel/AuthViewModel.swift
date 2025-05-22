//
//  AuthViewModel.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//
import Combine
import Foundation
import AuthenticationServices

final class AuthViewModel: ObservableObject {
    
    struct State {
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
        var validateEmailResponseEntity: ValidateEmailResponseEntity = ValidateEmailResponseEntity(isValid: false, message: "")
        var loginResponseEntity: LoginResponseEntity = LoginResponseEntity(user_id: "", email: "", nick: "", profileImage: nil, accessToken: "", refreshToken: "")
        var isValidatePassword: Bool = false
        var isMatchPasswordCheck: Bool = false
        var canConfirmAuthWithEmail: Bool = false
    }
    
    struct Input {
        var email: String = ""
        var password: String = ""
        var passwordCheck: String = ""
        var nickname: String = ""
        var isSignUp: Bool = true
    }
    
    enum Action {
        case authWithApple(result: Result<ASAuthorization, any Error>)
        case authWithKakao
        case loginWithEmail
        case signUpWithEmail
        case resetInput
    }
    
    @Published var state: State = State()
    @Published var input: Input = Input()
    private var cancellables: Set<AnyCancellable> = []
    private let service: AuthService
    
    init(service: AuthService) {
        self.service = service
        self.transform()
    }
    
    private func transform() {
        Publishers.CombineLatest(self.$input.map(\.email), self.$input.map(\.isSignUp))
            .filter { email, isSignUp in
                return isSignUp
            }
            .map(\.0)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [weak self] email -> AnyPublisher<ValidateEmailResponseEntity, NetworkError> in
                guard let self else {
                    return Fail(error: .unknown)
                        .eraseToAnyPublisher()
                }
                
                return Future { [weak self] promise in
                    guard let self else {
                        return
                    }
                    Task {
                        do {
                            let result = try await self.service.checkEmailValidation(email)
                            promise(.success(result))
                        } catch {
                            promise(.failure(.unknown))
                        }
                    }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            }
            .catch { [weak self] error in
                guard let self else {
                    return Just(ValidateEmailResponseEntity(isValid: false, message: "")).eraseToAnyPublisher()
                }
                
                self.state.errorMessage = "잠시 후, 다시 시도해주세요."
                self.state.showErrorAlert = true
                
                return Just(ValidateEmailResponseEntity(isValid: false, message: "")).eraseToAnyPublisher()
            }
            .sink { [weak self] entity in
                guard let self, !entity.message.isEmpty else {
                    return
                }
                self.state.validateEmailResponseEntity = entity
            }
            .store(in: &self.cancellables)
        
        Publishers.CombineLatest(self.$input.map(\.password), self.$input.map(\.passwordCheck))
            .removeDuplicates { previous, current in
                previous.0 == current.0 && previous.1 == current.1
            }
            .sink { [weak self] pw, pwc in
                guard let self else {
                    return
                }
                self.state.isValidatePassword = self.service.checkPasswordValidation(password: pw)
                self.state.isMatchPasswordCheck = self.service.checkPasswordCheckMatch(password: pw, passwordCheck: pwc)
            }
            .store(in: &self.cancellables)
        
        let signUpButtonState = Publishers.CombineLatest4(
            self.$state.map(\.isValidatePassword),
            self.$state.map(\.isMatchPasswordCheck),
            self.$input.map(\.nickname),
            self.$state.map(\.validateEmailResponseEntity.isValid))
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .map { (pw, pwc, nick, email) in
                return pw && pwc && !nick.isEmpty && email
            }
        
        let loginButtonState = Publishers.CombineLatest(
            self.$input.map(\.email),
            self.$input.map(\.password))
            .map { (email, pw) in
                return !email.isEmpty && !pw.isEmpty
            }
        
        Publishers.CombineLatest(signUpButtonState, loginButtonState)
            .map { [weak self] signUpButtonState, loginButtonState in
                guard let self else {
                    return false
                }
                
                return self.input.isSignUp ? signUpButtonState : loginButtonState
            }
            .sink { [weak self] state in
                guard let self else {
                    return
                }
                self.state.canConfirmAuthWithEmail = state
            }
            .store(in: &self.cancellables)
    }
    
    func action(_ action: Action) {
        self.state.errorMessage = ""
        switch action {
        case .authWithApple(let result):
            self.authWithApple(result: result)
        case .authWithKakao:
            self.authWithKakao()
        case .loginWithEmail:
            self.loginWithEmail()
        case .signUpWithEmail:
            self.signUpWithEmail()
        case .resetInput:
            self.input = Input()
        }
    }
    
    private func authWithApple(result: Result<ASAuthorization, any Error>) {
        Task {
            do {
                let result = try await self.service.authWithApple(result: result)
                await MainActor.run {
                    self.state.loginResponseEntity = result
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
    
    private func authWithKakao() {
        Task { @MainActor in
            do {
                let result = try await self.service.authWithKakao()
                
                self.state.loginResponseEntity = result
                
            } catch let error as EstateErrorResponseEntity {
                self.state.errorMessage = error.message
                self.state.showErrorAlert = true
            }
        }
    }
    
    private func loginWithEmail() {
        Task {
            do {
                let request = LoginWithEmailRequestEntity(email: self.input.email, password: self.input.password)
                
                let result = try await self.service.loginWithEmail(request: request)
                await MainActor.run {
                    self.state.loginResponseEntity = result
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
    
    private func signUpWithEmail() {
        Task {
            do {
                let request = SignUpWithEmailRequestEntity(email: self.input.email, password: self.input.password, nickname: self.input.nickname)
                let result = try await self.service.signUpWithEmail(request: request)
                await MainActor.run {
                    self.state.loginResponseEntity = result
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
}
