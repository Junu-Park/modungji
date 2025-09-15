//
//  PathModel.swift
//  Modungji
//
//  Created by 박준우 on 5/28/25.
//

import SwiftUI

final class PathModel: NSObject, ObservableObject {
    @Published var path: NavigationPath = .init() {
        didSet {
            if self.selectedChatRoomID == nil || oldValue.count <= self.path.count { return }
            
            self.selectedChatRoomID = nil
        }
    }
    @Published var selectedTab: Int = 0
    
    private let diContainer: DIContainer
    
    private var viewModelList: [String: any ObservableObject] = [:]
    
    private var selectedChatRoomID: String?
    
    init(diContainer: DIContainer) {
        self.diContainer = diContainer
        
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func push(_ path: PathType) {
        if case .chat(_, let roomID) = path {
            self.selectedChatRoomID = roomID
        }
        
        self.path.append(path)
    }
    
    func pop() {
        if self.path.isEmpty { return }
        
        self.path.removeLast()
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
                        service: self.diContainer.service.mainService,
                        pathModel: self
                    )
                    self.viewModelList["MainViewModel"] = vm
                    
                    return vm
                }
            }()
            
            MainView(viewModel: viewModel)
        case .map(let category):
            let viewModel = MapViewModel(
                service: self.diContainer.service.mapService,
                pathModel: self,
                selectedCategory: category
            )
            
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
        case .chat(let opponentID, let roomID):
            let viewModel: ChatViewModel = ChatViewModel(
                opponentID: opponentID,
                roomID: roomID,
                service: self.diContainer.service.chatService,
                pathModel: self
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

extension PathModel: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        guard let roomID = notification.request.content.userInfo["room_id"] as? String, self.selectedChatRoomID != roomID else {
            return []
        }
        
        guard let vm = self.viewModelList["ChatRoomListViewModel"] as? ChatRoomListViewModel else {
            return []
        }
        
        vm.action(.fetchChatRoomList)
        
        return [.badge, .banner, .list, .sound]
    }
    
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let roomID = response.notification.request.content.userInfo["room_id"] as? String, self.selectedChatRoomID != roomID else {
            return
        }
        
        // 앱이 완전히 로드될 때까지 대기
        try? await Task.sleep(for: .seconds(0.3))
        
        self.selectedTab = 1
        
        if self.selectedChatRoomID != nil {
            self.pop()
        }
        self.push(.chat(opponentID: "", roomID: roomID))
    }
}
