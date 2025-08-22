//
//  ChatRoomRealmDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/17/25.
//

import Foundation

import RealmSwift

final class ChatRoomRealmDTO: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var createdDate: Date
    @Persisted var user: UserRealmDTO?
    @Persisted var opponent: UserRealmDTO?
    @Persisted var chatList: List<ChatRealmDTO> = .init()
    
    var lastChat: ChatRealmDTO? {
        return self.chatList.sorted { $0.date > $1.date }.first
    }
    
    var updatedDate: Date {
        return self.lastChat?.date ?? self.createdDate
    }
}
