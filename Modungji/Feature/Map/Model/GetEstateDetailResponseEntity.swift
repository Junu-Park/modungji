//
//  GetEstateDetailResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 7/21/25.
//

import Foundation

struct GetEstateDetailResponseEntity {
   let estateID: String
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
   let options: EstateOptionEntity
   let geolocation: GeolocationEntity
   let creator: UserEntity
   let isLiked: Bool
   let isReserved: Bool
   let likeCount: Int
   let isSafeEstate: Bool
   let isRecommended: Bool
   let comments: [CommentEntity]
   let createdAt: String
   let updatedAt: String
   
   enum CodingKeys: String, CodingKey {
       case estateID = "estate_id"
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

struct EstateOptionEntity {
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

struct UserEntity {
   let userID: String
   let nick: String
   let introduction: String
   let profileImage: String
   
   enum CodingKeys: String, CodingKey {
       case userID = "user_id"
       case nick
       case introduction
       case profileImage
   }
}

struct CommentEntity {
   let commentID: String
   let content: String
   let createdAt: String
   let creator: UserEntity
   let replies: [ReplyEntity]
   
   enum CodingKeys: String, CodingKey {
       case commentID = "comment_id"
       case content
       case createdAt
       case creator
       case replies
   }
}

struct ReplyEntity {
   let commentID: String
   let content: String
   let createdAt: String
   let creator: UserEntity
   
   enum CodingKeys: String, CodingKey {
       case commentID = "comment_id"
       case content
       case createdAt
       case creator
   }
}
