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
    
    private var viewModelList: [String: any ObservableObject] = [:]
    
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
        self.viewModelList.removeAll()
        self.path = NavigationPath()
    }
    
    @ViewBuilder
    func build(_ path: PathType) -> some View {
        switch path {
        case .auth:
            let viewModel: AuthViewModel = {
                if let vm = self.viewModelList["AuthViewModel"] as? AuthViewModel {
                    return vm
                } else {
                    let vm = AuthViewModel(
                        service: self.diContainer.service.authService,
                        authState: self.diContainer.state.authState
                    )
                    self.viewModelList["AuthViewModel"] = vm
                    
                    return vm
                }
            }()
            
            AuthView(viewModel: viewModel)
        case .authWithEmail(let authType):
            /*
            let viewModel: AuthWithEmailViewModel = {
                if let vm = self.viewModelList["AuthWithEmailViewModel"] as? AuthWithEmailViewModel {
                    return vm
                } else {
                    let vm = AuthWithEmailViewModel(
                        service: self.diContainer.service.authService,
                        authState: self.diContainer.state.authState
                    )
                    self.viewModelList["AuthWithEmailViewModel"] = vm
                    
                    return vm
                }
            }()
             */
            let viewModel: AuthWithEmailViewModel = AuthWithEmailViewModel(
                service: self.diContainer.service.authService,
                authState: self.diContainer.state.authState
            )
            
            AuthWithEmailView(authType: authType, viewModel: viewModel)
        case .main:
            let viewModel: MainViewModel = {
                if let vm = self.viewModelList["MainViewModel"] as? MainViewModel {
                    return vm
                } else {
                    let vm = MainViewModel(
                        service: self.diContainer.service.mainService
                    )
                    self.viewModelList["MainViewModel"] = vm
                    
                    return vm
                }
            }()
            
            MainView(viewModel: viewModel)
        case .map:
            let viewModel: MapViewModel = {
                if let vm = self.viewModelList["MapViewModel"] as? MapViewModel {
                    return vm
                } else {
                    let vm = MapViewModel(
                        service: self.diContainer.service.mapService,
                        pathModel: self
                    )
                    self.viewModelList["MapViewModel"] = vm
                    
                    return vm
                }
            }()
            
            MapView(viewModel: viewModel)
        case .detail(let estateID):
            let viewModel: DetailViewModel = {
                if let vm = self.viewModelList["DetailViewModel"] as? DetailViewModel, vm.state.detailData.estateID == estateID {
                    return vm
                } else {
                    let vm = DetailViewModel(
                        estateID: estateID,
                        service: self.diContainer.service.detailService,
                        pathModel: self
                    )
                    self.viewModelList["DetailViewModel"] = vm
                    
                    return vm
                }
            }()
            
            DetailView(viewModel: viewModel)
        case .chat(let opponentID, let roomData):
            let viewModel: ChatViewModel = ChatViewModel(
                opponentID: opponentID,
                chatRoomData: roomData,
                service: self.diContainer.service.chatService
            )
            
            ChatView(viewModel: viewModel)
        case .chatRoomList:
            let viewModel: ChatRoomListViewModel = {
                if let vm = self.viewModelList["ChatRoomListViewModel"] as? ChatRoomListViewModel {
                    return vm
                } else {
                    let vm = ChatRoomListViewModel(
                        service: self.diContainer.service.chatService,
                        pathModel: self
                    )
                    self.viewModelList["ChatRoomListViewModel"] = vm
                    
                    return vm
                }
            }()
            
            ChatRoomListView(viewModel: viewModel)
        }
    }
}
