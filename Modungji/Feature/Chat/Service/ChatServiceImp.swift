//
//  ChatServiceImp.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Foundation

struct ChatServiceImp: ChatService {
    private let repository: ChatRepository
    
    init(repository: ChatRepository) {
        self.repository = repository
    }
    
    func createChatRoom(opponentID: String) async throws -> ChatRoomResponseEntity {
        return try await self.repository.createChatRoom(opponentID: opponentID)
    }
    
    func getChatRoomChatHistory(roomID: String, next: Date?) async throws -> [ChatResponseEntity] {
        return try await self.repository.getChatRoomChatHistory(roomID: roomID, next: next)
    }
    
    func getChatRoomList() async throws -> [ChatRoomResponseEntity] {
        return try await self.repository.getChatRoomList()
    }
}
