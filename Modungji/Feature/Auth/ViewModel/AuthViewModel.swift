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
        var loginData: LoginResponseEntity?
    }
    
    enum Action {
        case authWithApple(result: Result<ASAuthorization, any Error>)
        case authWithKakao
    }
    
    @Published var state: State = State()
    private var cancellables: Set<AnyCancellable> = []
    private let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    func action(_ action: Action) {
        self.state.errorMessage = ""
        switch action {
        case .authWithApple(let result):
            self.authWithApple(result: result)
        case .authWithKakao:
            self.authWithKakao()
        }
    }
    
    private func authWithApple(result: Result<ASAuthorization, any Error>) {
        Task {
            do {
                let result = try await self.service.authWithApple(result: result)
                await MainActor.run {
                    self.state.loginData = result
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
                
                self.state.loginData = result
                
            } catch let error as EstateErrorResponseEntity {
                self.state.errorMessage = error.message
                self.state.showErrorAlert = true
            }
        }
    }
}
