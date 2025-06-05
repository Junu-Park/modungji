//
//  GetEstateWithGeoResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import Foundation

struct GetEstateWithGeoResponseEntity {
    let estateId: String
    let category: String
    let title: String
    let thumbnail: String
    let deposit: Int
    let monthlyRent: Int
    let area: Double
    let floors: Int
    let geolocation: GeolocationEntity
    let distance: Double?
}
