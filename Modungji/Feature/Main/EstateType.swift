//
//  EstateType.swift
//  Modungji
//
//  Created by 박준우 on 5/23/25.
//

import Foundation

enum EstateType: String, CaseIterable {
    case oneroom = "원룸"
    case officetel = "오피스텔"
    case apartment = "아파트"
    case villa = "빌라"
    case commercial = "상가"
    
    var image: ImageResource {
        switch self {
        case .oneroom:
                .oneRoom
        case .officetel:
                .officetel
        case .apartment:
                .apartment
        case .villa:
                .villa
        case .commercial:
                .storefront
        }
    }
}
