//
//  MapClusterKey.swift
//  Modungji
//
//  Created by 박준우 on 7/18/25.
//

import NMapsMap

final class MapClusterKey: NSObject, NMCClusteringKey {
    let entity: EstateResponseEntity
    let position: NMGLatLng
    
    init(entity: EstateResponseEntity) {
        self.entity = entity
        self.position = .init(lat: entity.geolocation.latitude, lng: entity.geolocation.longitude)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MapClusterKey else {
            return false
        }
        
        if self === obj {
            return true
        }
        
        return obj.entity.estateID == self.entity.estateID
    }
    
    override var hash: Int {
        return self.entity.estateID.hashValue
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return MapClusterKey(entity: self.entity)
    }
}
