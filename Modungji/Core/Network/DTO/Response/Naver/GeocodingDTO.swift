//
//  GeocodingDTO.swift
//  Modungji
//
//  Created by 박준우 on 9/16/25.
//

import Foundation

struct GeocodingDTO: Decodable {
    let status: String
    let meta: MetaDTO
    let addresses: [AddressesDTO]
    let errorMessage: String
}

struct MetaDTO: Decodable {
    let totalCount: Int
    let page: Int
    let count: Int
}

struct AddressesDTO: Decodable {
    let roadAddress: String
    let longitude: String
    let latitude: String
    
    enum CodingKeys: String, CodingKey {
        case roadAddress
        case longitude = "x"
        case latitude = "y"
    }
}
