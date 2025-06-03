//
//  GetHotTopicResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

// MARK: - GetHotTopicResponseDTO
struct GetHotTopicResponseDTO: Decodable {
    let data: [HotTopicDTO]
}

// MARK: - HotTopicDTO
struct HotTopicDTO: Decodable {
    let title: String
    let content: String
    let date: String
    let link: String
}
