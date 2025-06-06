//
//  PathModel.swift
//  Modungji
//
//  Created by 박준우 on 5/28/25.
//

import SwiftUI

final class PathModel: ObservableObject {
    @Published var path: NavigationPath = .init()
    
    private let diContainer: DIContainer
    
    init(diContainer: DIContainer) {
        self.diContainer = diContainer
    }
    
    func push(_ path: PathType) {
        self.path.append(path)
    }
    
    func pop() {
        if !self.path.isEmpty {
            self.path.removeLast()
        }
    }
    
    func root() {
        self.path = NavigationPath()
    }
    
    @ViewBuilder
    func build(_ path: PathType) -> some View {
        switch path {
        case .auth:
            let viewModel = AuthViewModel(
                service: self.diContainer.service.authService,
                authState: self.diContainer.state.authState
            )
            
            AuthView(viewModel: viewModel)
        case .authWithEmail(let authType):
            let viewModel = AuthWithEmailViewModel(
                service: self.diContainer.service.authService,
                authState: self.diContainer.state.authState
            )
            
            AuthWithEmailView(authType: authType, viewModel: viewModel)
        case .main:
            MainView()
        case .map:
            let viewModel = MapViewModel(
                service: self.diContainer.service.mapService
            )
            
            MapView(viewModel: viewModel)
        }
    }
}
