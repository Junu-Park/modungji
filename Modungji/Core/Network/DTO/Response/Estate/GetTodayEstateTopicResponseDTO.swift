//
//  GetTodayEstateTopicResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

// MARK: - GetTodayEstateTopicResponseDTO
struct GetTodayEstateTopicResponseDTO: Decodable {
    let data: [TodayEstateTopicDTO]
}

// MARK: - TodayEstateTopicDTO
struct TodayEstateTopicDTO: Decodable {
    let title: String
    let content: String
    let date: String
    let link: String?
}
