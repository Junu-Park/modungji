//
//  ReverseGeocodingDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/6/25.
//

import Foundation

struct ReverseGeocodingDTO: Decodable {
    let results: [AddressDTO]
}

struct AddressDTO: Decodable {
    let region: Region
}

struct Region: Decodable {
    let area1: Area
    let area2: Area
    let area3: Area
}

struct Area: Decodable {
    let name: String
    let alias: String?
}
