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
    let options: [EstateOptionEntity]
    let geolocation: GeolocationEntity
    let creator: UserEntity
    var isLiked: Bool
    let isReserved: Bool
    let likeCount: Int
    let isSafeEstate: Bool
    let isRecommended: Bool
    let comments: [CommentEntity]
    let createdAt: String
    let updatedAt: String
    var address: String
}

struct EstateOptionEntity {
    let name: String
    let image: ImageResource
    let state: Bool
}

struct UserEntity {
    let userID: String
    let nick: String
    let introduction: String
    let profileImage: String
}

struct CommentEntity {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserEntity
    let replies: [ReplyEntity]
}

struct ReplyEntity {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserEntity
}
