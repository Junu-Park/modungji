//
//  ChatRepositoryImp.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Foundation

struct ChatRepositoryImp: ChatRepository {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func createChatRoom(opponentID: String) async throws -> ChatRoomResponseEntity {
        let request = CreateChatRoomRequestDTO(opponent_id: opponentID)
        
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Chat.createChatRoom(body: request), successDecodingType: ChatRoomResponseDTO.self)
        
        switch response {
        case .success(let success):
            return self.convertToEntity(success)
        case .failure(let failure):
            throw failure
        }
    }
    
    func getChatRoomChatHistory(roomID: String, next: Date?) async throws -> [ChatResponseEntity] {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Chat.getChatHistory(roomID: roomID, next: self.convertDateToDateString(next)), successDecodingType: GetChatHistoryResponseDTO.self)
        
        switch response {
        case .success(let success):
            return success.data.map { self.convertToEntity($0) }
        case .failure(let failure):
            throw failure
        }
    }
    
    private func convertToEntity(_ dto: ChatRoomResponseDTO) -> ChatRoomResponseEntity {
        return .init(
            roomID: dto.roomID,
            createdAt: self.convertDateStringToDate(dto.createdAt),
            updatedAt: self.convertDateStringToDate(dto.updatedAt),
            participants: dto.participants.map { self.convertToEntity($0) },
            lastChat: self.convertToEntity(dto.lastChat)
        )
    }
    
    private func convertToEntity(_ dto: ChatResponseDTO) -> ChatResponseEntity {
        return .init(
            chatID: dto.chatID,
            roomID: dto.roomID,
            content: dto.content,
            createdAt: self.convertDateStringToDate(dto.createdAt),
            updatedAt: self.convertDateStringToDate(dto.updatedAt),
            sender: self.convertToEntity(dto.sender),
            files: dto.files
        )
    }
    
    private func convertToEntity(_ dto: ChatResponseDTO?) -> ChatResponseEntity? {
        guard let dto else { return nil }
        
        return .init(
            chatID: dto.chatID,
            roomID: dto.roomID,
            content: dto.content,
            createdAt: self.convertDateStringToDate(dto.createdAt),
            updatedAt: self.convertDateStringToDate(dto.updatedAt),
            sender: self.convertToEntity(dto.sender),
            files: dto.files
        )
    }
    
    private func convertToEntity(_ dto: UserDTO) -> UserEntity {
        return .init(
            userID: dto.userId,
            nick: dto.nick,
            introduction: dto.introduction ?? "",
            profileImage: dto.profileImage ?? ""
        )
    }
    
    private func convertDateStringToDate(_ dateString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter.date(from: dateString) ?? Date()
    }
    
    private func convertDateToDateString(_ date: Date?) -> String? {
        guard let date else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter.string(from: date)
    }
}
