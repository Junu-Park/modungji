//
//  PathType.swift
//  Modungji
//
//  Created by 박준우 on 5/28/25.
//

import SwiftUI

enum PathType: Hashable {
    case auth
    case authWithEmail(authType: AuthWithEmailType)
    case main
    case map
    case detail(estateID: String)
    case chat(opponentID: String, roomData: ChatRoomResponseEntity? = nil)
    case chatRoomList
}
