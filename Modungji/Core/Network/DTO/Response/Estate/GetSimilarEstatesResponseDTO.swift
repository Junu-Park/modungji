//
//  GetSimilarEstatesResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

// MARK: - GetSimilarEstatesResponseDTO
struct GetSimilarEstatesResponseDTO: Decodable {
    let data: [SimilarEstateDTO]
    
    func convertToEntity() -> GetSimilarEstatesResponseEntity {
        return .init(
            data: self.data.map(
                {
                    .init(
                        estateID: $0.estateId,
                        title: $0.title,
                        thumbnail: $0.thumbnails.first ?? "",
                        deposit: $0.deposit,
                        monthlyRent: $0.monthlyRent,
                        area: $0.area,
                        geolocation: .init(latitude: $0.geolocation.latitude, longitude: $0.geolocation.longitude),
                        category: $0.category,
                        floors: $0.floors,
                        distance: $0.distance,
                        introduction: $0.introduction,
                        likeCount: $0.likeCount,
                        isRecommended: $0.isRecommended,
                        builtYear: $0.builtYear,
                        isSafeEstate: $0.isSafeEstate
                    )
                })
        )
    }
}

// MARK: - SimilarEstateDTO
struct SimilarEstateDTO: Decodable {
    let estateId: String
    let category: String
    let title: String
    let introduction: String
    let thumbnails: [String]
    let deposit: Int
    let monthlyRent: Int
    let builtYear: String
    let area: Double
    let floors: Int
    let geolocation: GeolocationDTO
    let distance: Double?
    let likeCount: Int
    let isSafeEstate: Bool
    let isRecommended: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case estateId = "estate_id"
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
        case distance
        case likeCount = "like_count"
        case isSafeEstate = "is_safe_estate"
        case isRecommended = "is_recommended"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
