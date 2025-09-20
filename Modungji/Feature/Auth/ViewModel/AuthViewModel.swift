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
        var isAutoLogin: Bool = false
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case authWithApple(result: Result<ASAuthorization, any Error>)
        case authWithKakao
        case authWithAuto
    }
    
    @Published var state: State = State()
    private var cancellables: Set<AnyCancellable> = []
    private let service: AuthService
    private let authState: AuthState
    
    init(service: AuthService, authState: AuthState) {
        self.service = service
        self.authState = authState
    }
    
    func action(_ action: Action) {
        self.state.errorMessage = ""
        switch action {
        case .authWithApple(let result):
            self.authWithApple(result: result)
        case .authWithKakao:
            self.authWithKakao()
        case .authWithAuto:
            self.authWithAuto()
        }
    }
    
    private func authWithApple(result: Result<ASAuthorization, any Error>) {
        Task {
            do {
                let result = try await self.service.authWithApple(result: result)
                await MainActor.run {
                    self.authState.login(accessToken: result.accessToken, refreshToken: result.refreshToken)
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
                
                self.authState.login(accessToken: result.accessToken, refreshToken: result.refreshToken)
            } catch let error as EstateErrorResponseEntity {
                self.state.errorMessage = error.message
                self.state.showErrorAlert = true
            }
        }
    }
    
    private func authWithAuto() {
        Task {
            do {
                let refresh = try? KeychainManager().get(tokenType: .refreshToken)
                
                if refresh == nil {
                    return
                }
                
                await MainActor.run {
                    self.state.isAutoLogin = true
                }
                
                let result = try await self.service.authWithAuto()
                
                await MainActor.run {
                    self.authState.login(accessToken: result.accessToken, refreshToken: result.refreshToken)
                    self.state.isAutoLogin = false
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.isAutoLogin = false
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            } catch {
                await MainActor.run {
                    self.state.isAutoLogin = false
                }
            }
        }
    }
}
