//
//  GetHotEstateResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

// MARK: - GetHotEstateResponseDTO
struct GetHotEstateResponseDTO: Decodable {
    let data: [HotEstateDTO]
}

// MARK: - HotEstateDTO
struct HotEstateDTO: Decodable {
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
    
    func convertToEntity() -> EstateResponseEntity {
        
        return .init(
            estateID: self.estateId,
            title: self.title,
            thumbnail: self.thumbnails.first ?? "",
            deposit: self.deposit,
            monthlyRent: self.monthlyRent,
            area: self.area,
            geolocation: .init(latitude: self.geolocation.latitude, longitude: self.geolocation.longitude),
            category: self.category,
            floors: self.floors,
            distance: self.distance,
            introduction: self.introduction,
            likeCount: self.likeCount,
            isRecommended: self.isRecommended,
            builtYear: self.builtYear,
            isSafeEstate: self.isSafeEstate
        )
    }
}
