//
//  GetBannerResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 9/10/25.
//

import Foundation

struct GetBannerResponseDTO: Decodable {
    let data: [BannerDTO]
}

struct BannerDTO: Decodable {
    let name: String
    let imageUrl: String
    let payload: BannerPayloadDTO
}

struct BannerPayloadDTO: Decodable {
    let type: String
    let value: String
}
