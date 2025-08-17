//
//  ChatViewModel.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

//import Combine
import Foundation

final class ChatViewModel: ObservableObject {
    struct State {
        var chatRoomData: ChatRoomResponseEntity = .init(roomID: "", createdAt: Date(), updatedAt: Date(), participants: [], lastChat: nil)
        var chatDataList: [ChatResponseEntity] = []
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case sendChat
        case appendImage
    }
    
    @Published var state: State = State()
    private let service: ChatService
    private let pathModel: PathModel
//    private var cancellables: Set<AnyCancellable> = .init()
    
    init(opponentID: String? = nil, service: ChatService, pathModel: PathModel) {
        self.service = service
        self.pathModel = pathModel
        
        guard let opponentID else {
            return
        }
        
        self.startChat(opponentID: opponentID)
        
//        self.transform()
    }
    
//    func transform() {
//        self.$state.map(\.opponentID)
//            .removeDuplicates()
//            .dropFirst()
//            .sink { [weak self] opponentID in
//                guard let self else { return }
//                
//                guard let opponentID else {
//                    self.pathModel.pop()
//                    return
//                }
//                
//                self.startChat(opponentID: opponentID)
//            }
//            .store(in: &self.cancellables)
//    }
    
    private func startChat(opponentID: String) {
        Task {
            do {
                let chatRoomResponse = try await self.service.createChatRoom(opponentID: opponentID)
                // TODO: Socket 연결하기
                
                if chatRoomResponse.lastChat != nil {
                    // TODO: 언제 날짜 채팅부터 불러올지, 내부 DB에 있는 가장 최근 채팅 날짜 비교해서
                    let chatHistoryResponse = try await self.service.getChatRoomChatHistory(roomID: chatRoomResponse.roomID, next: nil)
                }
                
                await MainActor.run {
                    self.state.chatRoomData = chatRoomResponse
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
