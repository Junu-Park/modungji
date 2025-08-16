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
        let locationManager: LocationManager
    }
    let manager: Manager
    
    // Repository
    struct Repository {
        let authRepository: AuthRepository
        let mapRepository: MapRepository
        let mainRepository: MainRepository
        let detailRepository: DetailRepository
        let chatRepository: ChatRepository
    }
    let repository: Repository
    
    // Service
    struct Service {
        let authService: AuthService
        let mapService: MapService
        let mainService: MainService
        let detailService: DetailService
        let chatService: ChatService
    }
    let service: Service
    
    struct State {
        let authState: AuthState
    }
    let state: State
    
    private init(
        networkManager: NetworkManager? = nil,
        keychainManager: KeychainManager? = nil,
        kakaoManager: KakaoManager? = nil,
        locationManager: LocationManager? = nil,
        authRepository: AuthRepository? = nil,
        mapRepository: MapRepository? = nil,
        mainRepository: MainRepository? = nil,
        detailRepository: DetailRepository? = nil,
        chatRepository: ChatRepository? = nil,
        authService: AuthService? = nil,
        mapService: MapService? = nil,
        mainService: MainService? = nil,
        detailService: DetailService? = nil,
        chatService: ChatService? = nil,
        authState: AuthState? = nil
    ) {
        self.manager = Manager(
            networkManager: networkManager ?? NetworkManager(),
            keychainManager: keychainManager ?? KeychainManager(),
            kakaoManager: kakaoManager ?? KakaoManager(),
            locationManager: locationManager ?? LocationManager()
        )
        
        self.repository = Repository(
            authRepository: authRepository ?? AuthRepositoryImp(
                networkManager: self.manager.networkManager,
                kakaoManager: self.manager.kakaoManager,
                keychainManger: self.manager.keychainManager
            ),
            mapRepository: mapRepository ?? MapRepositoryImp(
                networkManager: self.manager.networkManager,
                locationManager: self.manager.locationManager
            ),
            mainRepository: mainRepository ?? MainRepositoryImp(
                networkManager: self.manager.networkManager
            ),
            detailRepository: detailRepository ?? DetailRepositoryImp(
                networkManager: self.manager.networkManager
            ),
            chatRepository: chatRepository ?? ChatRepositoryImp(
                networkManager: self.manager.networkManager
            )
        )
        
        self.service = Service(
            authService: authService ?? AuthServiceImp(
                repository: self.repository.authRepository
            ),
            mapService: mapService ?? MapServiceImp(
                repository: self.repository.mapRepository
            ),
            mainService: mainService ?? MainServiceImp(
                repository: self.repository.mainRepository
            ),
            detailService: detailService ?? DetailServiceImp(
                repository: self.repository.detailRepository
            ),
            chatService: chatService ?? ChatServiceImp(
                repository: self.repository.chatRepository
            )
        )
        
        self.state = State(authState: authState ?? AuthState())
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
