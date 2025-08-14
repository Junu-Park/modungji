//
//  GetOrderHistoryResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/14/25.
//

import Foundation

struct GetOrderHistoryResponseDTO: Decodable {
    let data: [OrderDTO]
}

struct OrderDTO: Decodable {
    let orderID: String
    let orderCode: String
    let estate: Estate
    let paidAt: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case estate
        case paidAt
        case createdAt
        case updatedAt
    }
}

struct Estate: Decodable {
    let id: String
    let category: String
    let title: String
    let introduction: String
    let thumbnails: [String]
    let deposit: Int
    let monthlyRent: Int
    let builtYear: Date
    let area: Double
    let floors: Int
    let geolocation: GeolocationDTO
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case category
        case title
        case introduction
        case thumbnails
        case deposit
        case monthlyRent = "monthly_rent"
        case builtYear = "built_year"
        case area
        case floors
        case geolocation
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
