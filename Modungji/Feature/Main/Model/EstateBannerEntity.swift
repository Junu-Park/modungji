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
    let address: Address
}

struct Address {
    let si: String
    let gu: String
    let dong: String
}
