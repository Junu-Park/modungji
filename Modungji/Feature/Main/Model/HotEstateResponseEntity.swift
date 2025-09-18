//
//  HotEstateResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 9/9/25.
//

import Foundation

struct HotEstateResponseEntity {
    let estateID: String
    let title: String
    let introduction: String
    let thumbnail: String
    let geolocation: GeolocationEntity
    var address: String = ""
    let deposit: Int
    let monthlyRent: Int
    let area: Double
    let likeCount: Int
    let isRecommended: Bool
    
    var squareMeter: Double {
        self.area * 3.3058
    }
}
