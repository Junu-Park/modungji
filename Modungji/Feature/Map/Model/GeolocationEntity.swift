//
//  GeolocationEntity.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import CoreLocation

struct GeolocationEntity: Equatable {
    var latitude: Double
    var longitude: Double
    
    func getMeterDistance(with target: GeolocationEntity) -> Int {
        let standard = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let target = CLLocation(latitude: target.latitude, longitude: target.longitude)
        
        return Int(standard.distance(from: target))
    }
}
