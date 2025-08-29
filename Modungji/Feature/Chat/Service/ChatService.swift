//
//  ChatService.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import UIKit

protocol ChatService {
    func createChatRoom(opponentID: String) async throws -> ChatRoomResponseEntity
    func getChatRoomChatHistory(roomID: String, next: Date?) async throws -> [ChatResponseEntity]
    func getChatRoomList() async throws -> [ChatRoomResponseEntity]
    @discardableResult func postChat(roomID: String, content: String, photos: [UIImage], files: [URL]) async throws -> ChatResponseEntity
}
