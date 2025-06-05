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
    
    func getUserLocation() async throws {
        let state = self.repository.getAuthorizationState()
        
        switch state {
        case .notDetermined:
            self.repository.requestWhenInUseAuthorization()
        case .restricted:
            throw EstateErrorResponseEntity(message: "위치 권한을 확인해주세요.")
        case .denied:
            throw EstateErrorResponseEntity(message: "위치 권한을 확인해주세요.")
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            self.repository.requestAlwaysAuthorization()
        case .authorized:
            break
        @unknown default:
            throw EstateErrorResponseEntity(message: "위치 권한을 확인해주세요.")
        }
    }
}
