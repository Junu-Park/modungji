//
//  GetEstateWithGeoRequestEntity.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import Foundation

struct GetEstateWithGeoRequestEntity {
    var category: EstateCategory?
    var longitude: Double
    var latitude: Double
    var maxDistance: Int?
}
