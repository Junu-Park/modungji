//
//  ChatRoomResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Foundation

/// CreateChatRoom API Response DTO
struct ChatRoomResponseDTO: Decodable {
    let roomID: String
    let createdAt: String
    let updatedAt: String
    let participants: [UserDTO]
    let lastChat: ChatResponseDTO?
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt, updatedAt, participants
        case lastChat = "lastChat"
    }
}
