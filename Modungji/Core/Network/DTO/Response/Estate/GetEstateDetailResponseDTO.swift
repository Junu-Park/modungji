//
//  GetEstateDetailResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

struct GetEstateDetailResponseDTO: Decodable {
    let estateId: String
    let category: String
    let title: String
    let introduction: String
    let reservationPrice: Int
    let thumbnails: [String]
    let description: String
    let deposit: Int
    let monthlyRent: Int
    let builtYear: String
    let maintenanceFee: Int
    let area: Double
    let parkingCount: Int
    let floors: Int
    let options: EstateOptionDTO
    let geolocation: GeolocationDTO
    let creator: UserDTO
    let isLiked: Bool
    let isReserved: Bool
    let likeCount: Int
    let isSafeEstate: Bool
    let isRecommended: Bool
    let comments: [CommentDTO]
    // TODO: 스웨거에는 필수값이라 표기되어 있음
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case estateId = "estate_id"
        case category
        case title
        case introduction
        case reservationPrice = "reservation_price"
        case thumbnails
        case description
        case deposit
        case monthlyRent = "monthly_rent"
        case builtYear = "built_year"
        case maintenanceFee = "maintenance_fee"
        case area
        case parkingCount = "parking_count"
        case floors
        case options
        case geolocation
        case creator
        case isLiked = "is_liked"
        case isReserved = "is_reserved"
        case likeCount = "like_count"
        case isSafeEstate = "is_safe_estate"
        case isRecommended = "is_recommended"
        case comments
        case createdAt
        case updatedAt
    }
}
// MARK: - EstateOptionDTO
struct EstateOptionDTO: Decodable {
    let refrigerator: Bool
    let washer: Bool
    let airConditioner: Bool
    let closet: Bool
    let shoeRack: Bool
    let microwave: Bool
    let sink: Bool
    let tv: Bool
    
    enum CodingKeys: String, CodingKey {
        case refrigerator
        case washer
        case airConditioner = "air_conditioner"
        case closet
        case shoeRack = "shoe_rack"
        case microwave
        case sink
        case tv
    }
}

// MARK: - UserDTO
struct UserDTO: Decodable {
    let userId: String
    let nick: String
    let introduction: String?
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick
        case introduction
        case profileImage
    }
}

// MARK: - CommentDTO
struct CommentDTO: Decodable {
    let commentId: String
    let content: String
    let createdAt: String
    let creator: UserDTO
    let replies: [ReplyDTO]
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content
        case createdAt
        case creator
        case replies
    }
}

// MARK: - ReplyDTO
struct ReplyDTO: Decodable {
    let commentId: String
    let content: String
    let createdAt: String
    let creator: UserDTO
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case content
        case createdAt
        case creator
    }
}
