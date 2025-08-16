//
//  ChatRoomResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 8/17/25.
//

import Foundation

struct ChatRoomResponseEntity {
    let roomID: String
    let createdAt: Date
    let updatedAt: Date
    let participants: [UserEntity]
    let lastChat: ChatResponseEntity?
}
