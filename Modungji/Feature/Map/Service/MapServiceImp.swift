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
        let estateResponse = try await self.repository.getEstateWithGeo(entity: entity)
        
        return try await withThrowingTaskGroup(of: (Int, GetEstateWithGeoResponseEntity).self) { group in
            for (index, estate) in estateResponse.enumerated() {
                group.addTask {
                    let address = try await self.repository.getAddress(
                        coords: "\(estate.geolocation.longitude),\(estate.geolocation.latitude)"
                    )
                    
                    var entity = estate
                    if address.isExistRoadAddr {
                        entity.address = "\(address.area1Alias) \(address.area2) \(address.roadName) \(address.roadNumber)"
                    } else {
                        entity.address = "\(address.area1Alias) \(address.area2) \(address.area3)"
                    }
                    entity.address = address.area3
                    
                    return (index, entity)
                }
            }
            
            var result = Array<GetEstateWithGeoResponseEntity?>(repeating: nil, count: estateResponse.count)
            
            for try await (index, entity) in group {
                result[index] = entity
            }
            
            return result.compactMap { $0 }
        }
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
