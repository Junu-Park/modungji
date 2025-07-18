//
//  MapClusterKey.swift
//  Modungji
//
//  Created by 박준우 on 7/18/25.
//

import NMapsMap

final class MapClusterKey: NSObject, NMCClusteringKey {
    let entity: GetEstateWithGeoResponseEntity
    let position: NMGLatLng
    
    init(entity: GetEstateWithGeoResponseEntity) {
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
        
        return obj.entity.estateId == self.entity.estateId
    }
    
    override var hash: Int {
        return self.entity.estateId.hashValue
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return MapClusterKey(entity: self.entity)
    }
}
