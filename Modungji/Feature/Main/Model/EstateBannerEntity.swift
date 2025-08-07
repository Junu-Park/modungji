//
//  EstateBannerEntity.swift
//  Modungji
//
//  Created by 박준우 on 5/23/25.
//

import Foundation

struct EstateBannerEntity {
    let id: String
    let title: String
    let introduction: String
    let thumbnail: String
    let address: AddressEntity
}

struct AddressEntity {
    // 시/도
    let area1: String
    // 시/군/구
    let area2: String
    // 읍/면/동
    let area3: String
}
