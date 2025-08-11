//
//  MapServiceImp.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import CoreLocation

struct MapServiceImp: MapService {
    
    private let repository: MapRepository
    
    init(repository: MapRepository) {
        self.repository = repository
    }
    
    func getEstateWithGeo(entity: GetEstateWithGeoRequestEntity) async throws -> [GetEstateWithGeoResponseEntity] {
        return try await self.repository.getEstateWithGeo(entity: entity)
    }
    
    func getUserLocation() async throws -> Bool {
        let state = self.repository.getAuthorizationState()
        
        switch state {
        case .notDetermined:
            self.repository.requestWhenInUseAuthorization()
            return false
        case .restricted:
            throw EstateErrorResponseEntity(message: "위치 권한을 확인해주세요.")
        case .denied:
            throw EstateErrorResponseEntity(message: "위치 권한을 확인해주세요.")
        case .authorizedAlways:
            return true
        case .authorizedWhenInUse:
            self.repository.requestAlwaysAuthorization()
            return true
        case .authorized:
            return true
        @unknown default:
            throw EstateErrorResponseEntity(message: "위치 권한을 확인해주세요.")
        }
    }
}
