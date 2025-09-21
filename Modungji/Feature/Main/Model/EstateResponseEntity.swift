//
//  EstateResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 9/21/25.
//

import Foundation

struct EstateResponseEntity: Equatable {
    let estateID: String
    let title: String
    let thumbnail: String
    let deposit: Int
    let monthlyRent: Int
    let area: Double
    var address: String = ""
    let geolocation: GeolocationEntity
    let category: String
    let floors: Int
    let distance: Double?
    let introduction: String
    let likeCount: Int
    let isRecommended: Bool
    let builtYear: String
    let isSafeEstate: Bool
    
    var squareMeter: Double {
        self.area * 3.3058
    }
}
