//
//  GetChatHistoryResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Foundation

struct GetChatHistoryResponseDTO: Decodable {
    let data: [ChatResponseDTO]
}
