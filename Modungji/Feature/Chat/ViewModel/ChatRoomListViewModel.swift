//
//  ChatRoomListViewModel.swift
//  Modungji
//
//  Created by 박준우 on 8/18/25.
//

import Foundation

final class ChatRoomListViewModel: ObservableObject {
    struct State {
        var chatRoomList: [ChatRoomResponseEntity] = []
        
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case fetchChatRoomList
        case tapChatRoom(opponentID: String, roomData: ChatRoomResponseEntity)
    }
    
    @Published var state: State = State()
    private let service: ChatService
    private let pathModel: PathModel
    
    init(service: ChatService, pathModel: PathModel) {
        self.service = service
        self.pathModel = pathModel
    }
    
    func action(_ action: Action) {
        switch action {
        case .tapChatRoom(let opponentID, let roomData):
            self.pathModel.push(.chat(opponentID: opponentID, roomData: roomData))
        case .fetchChatRoomList:
            self.fetchChatRoomList()
        }
    }
    
    private func fetchChatRoomList() {
        Task {
            do {
                let response = try await self.service.getChatRoomList()
                
                await MainActor.run {
                    self.state.chatRoomList = response
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
