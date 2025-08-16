//
//  PostChatRequestDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Foundation

struct PostChatRequestDTO: Encodable {
    let content: String
    let files: [String]
}
