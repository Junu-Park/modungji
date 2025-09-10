//
//  BannerResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 9/10/25.
//

import Foundation

struct BannerResponseEntity {
    let name: String
    let imageUrl: String
    let payload: BannerPayloadEntity
}

struct BannerPayloadEntity {
    let type: String
    let value: String
}
