//
//  ChatResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 8/17/25.
//

import Foundation

struct ChatResponseEntity {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let sender: UserEntity
    let files: [String]
}
