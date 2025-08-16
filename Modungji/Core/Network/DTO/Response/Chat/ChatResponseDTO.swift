//
//  ChatResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Foundation

/// PostChat API Response DTO
struct ChatResponseDTO: Decodable {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: UserDTO
    let files: [String]
    
    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, updatedAt, sender, files
    }
}
