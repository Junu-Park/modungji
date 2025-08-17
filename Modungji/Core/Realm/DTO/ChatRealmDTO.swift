//
//  ChatRealmDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/17/25.
//

import Foundation

import RealmSwift

final class ChatRealmDTO: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var content: String
    @Persisted var files: List<String> = .init()
    @Persisted var senderID: String
    @Persisted var date: Date
    @Persisted(originProperty: "chatList") var chatRoom: LinkingObjects<ChatRoomRealmDTO>
}
