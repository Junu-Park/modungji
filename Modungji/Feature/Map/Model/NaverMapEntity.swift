//
//  NaverMapEntity.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import Foundation

struct NaverMapEntity {
    var centerLocation: GeolocationEntity
    /// maxDistance를 계산하기 위한 최남단 좌표
    var southLocation: GeolocationEntity
    var zoomLevel: Double
}
