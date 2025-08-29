//
//  ChatRoomResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 8/17/25.
//

import Foundation

struct ChatRoomResponseEntity: Hashable {
    static func == (lhs: ChatRoomResponseEntity, rhs: ChatRoomResponseEntity) -> Bool {
        return lhs.roomID == rhs.roomID
    }
    
    var roomID: String
    let createdAt: Date
    let updatedAt: Date
    let userData: UserEntity
    var opponentUserData: UserEntity
    let lastChat: ChatResponseEntity?
}
