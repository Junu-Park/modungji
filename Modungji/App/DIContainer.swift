//
//  DIContainer.swift
//  Modungji
//
//  Created by 박준우 on 5/24/25.
//

import SwiftUI

struct DIContainer {
    // Manager
    struct Manager {
        let networkManager: NetworkManager
        let keychainManager: KeychainManager
        let kakaoManager: KakaoManager
    }
    let manager: Manager
    
    // Repository
    struct Repository {
        let authRepository: AuthRepository
    }
    let repository: Repository
    
    // Service
    struct Service {
        let authService: AuthService
    }
    let service: Service
    
    private init(
        networkManager: NetworkManager? = nil,
        keychainManager: KeychainManager? = nil,
        kakaoManager: KakaoManager? = nil,
        authRepository: AuthRepository? = nil,
        authService: AuthService? = nil
    ) {
        self.manager = Manager(
            networkManager: networkManager ?? NetworkManager(),
            keychainManager: keychainManager ?? KeychainManager(),
            kakaoManager: kakaoManager ?? KakaoManager()
        )
        
        self.repository = Repository(
            authRepository: authRepository ?? AuthRepositoryImp(
                networkManager: self.manager.networkManager,
                kakaoManager: self.manager.kakaoManager,
                keychainManger: self.manager.keychainManager
            )
        )
        
        self.service = Service(
            authService: authService ?? AuthServiceImp(
                repository: self.repository.authRepository
            )
        )
    }
}

// MARK: 팩토리 메서드
extension DIContainer {
    static func getDefaultDIContainer() -> DIContainer {
        return DIContainer()
    }
}

// MARK: - Environment로 주입하기 위한 EnvironmentKey 및 EnvironmentValue 설정
private struct DIContainerKey: EnvironmentKey {
    static let defaultValue: DIContainer = DIContainer.getDefaultDIContainer()
}

extension EnvironmentValues {
    var DIContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
