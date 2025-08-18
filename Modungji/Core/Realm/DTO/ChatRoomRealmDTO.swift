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
    @Persisted var lastChat: ChatRealmDTO?
    @Persisted var chatList: List<ChatRealmDTO> = .init()
}
