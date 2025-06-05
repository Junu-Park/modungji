//
//  MapRepositoryImp.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import CoreLocation

struct MapRepositoryImp: MapRepository {
    private let networkManager: NetworkManager
    private let locationManager: LocationManager
    
    init(networkManager: NetworkManager, locationManager: LocationManager) {
        self.networkManager = networkManager
        self.locationManager = locationManager
    }
    
    func getEstateWithGeo(entity: GetEstateWithGeoRequestEntity) async throws -> [GetEstateWithGeoResponseEntity] {
        let response = try await self.networkManager.requestEstate(
            requestURL: EstateRouter.Estate.getEstateWithGeo(
                category: entity.category,
                longitude: entity.longitude,
                latitude: entity.latitude,
                maxDistance: entity.maxDistance
            ),
            successDecodingType: GetEstateWithGeoResponseDTO.self
        )
        switch response {
        case .success(let success):
            return success.data.map{ self.convertToEntity(dto: $0) }
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func getAuthorizationState() -> CLAuthorizationStatus {
        return self.locationManager.getAuthorizationState()
    }
    
    func requestWhenInUseAuthorization() {
        return self.locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        return self.locationManager.requestAlwaysAuthorization()
    }
    
    private func convertToEntity(dto: EstateWithGeoDTO) -> GetEstateWithGeoResponseEntity {
        return GetEstateWithGeoResponseEntity(
            estateId: dto.estateId,
            category: dto.category,
            title: dto.title,
            thumbnail: dto.thumbnails.first ?? "",
            deposit: dto.deposit,
            monthlyRent: dto.monthlyRent,
            area: dto.area,
            floors: dto.floors,
            geolocation: GeolocationEntity(
                latitude: dto.geolocation.latitude,
                longitude: dto.geolocation.longitude
            ),
            distance: dto.distance
        )
    }
}
