//
//  GetTodayTopicResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

// MARK: - GetTodayTopicResponseDTO
struct GetTodayTopicResponseDTO: Decodable {
    let data: [TodayTopicDTO]
}

// MARK: - TodayTopicDTO
struct TodayTopicDTO: Decodable {
    let title: String
    let content: String
    let date: String
    let link: String?
}
