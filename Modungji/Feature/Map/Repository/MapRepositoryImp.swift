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
    
    func getEstateWithGeo(entity: GetEstateWithGeoRequestEntity) async throws -> [EstateResponseEntity] {
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
            return success.data.map{ $0.convertToEntity() }
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func getAddress(coords: String) async throws -> ReverseGeocodingResponseEntity {
        let response = try await self.networkManager.requestEstate(requestURL: NaverRouter.Map.reverseGeocoding(coords: coords), successDecodingType: ReverseGeocodingDTO.self)
        
        switch response {
        case .success(let success):
            return self.convertToEntity(success)
        case .failure(let failure):
            throw failure
        }
    }
    
    func getCoordinator(query: String) async throws -> GeocodingResponseEntity {
        let response = try await self.networkManager.requestEstate(requestURL: NaverRouter.Map.geocoding(query: query), successDecodingType: GeocodingDTO.self)
        
        switch response {
        case .success(let success):
            return try self.convertToEntity(success)
        case .failure(let failure):
            throw failure
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
    
    private func convertToEntity(_ dto: ReverseGeocodingDTO) -> ReverseGeocodingResponseEntity {
        let admcodes = dto.results.filter({ $0.name == "admcode" })
        let roadaddrs = dto.results.filter({ $0.name == "roadaddr" })
        
        guard let admcode = admcodes.first else {
            return ReverseGeocodingResponseEntity(isExistRoadAddr: false, area1: "알 수 없음", area1Alias: "알 수 없음", area2: "알 수 없음", area3: "알 수 없음", roadName: "알 수 없음", roadNumber: "")
        }
        
        if let roadaddr = roadaddrs.first, let roadName = roadaddr.land?.name, let roadNumber = roadaddr.land?.number {
            return .init(
                isExistRoadAddr: true,
                area1: admcode.region.area1.name,
                area1Alias: admcode.region.area1.alias ?? admcode.region.area1.name,
                area2: admcode.region.area2.name,
                area3: admcode.region.area3.name,
                roadName: roadName,
                roadNumber: roadNumber
            )
        } else {
            return .init(
                isExistRoadAddr: false,
                area1: admcode.region.area1.name,
                area1Alias: admcode.region.area1.alias ?? admcode.region.area1.name,
                area2: admcode.region.area2.name,
                area3: admcode.region.area3.name,
                roadName: "",
                roadNumber: ""
            )
        }
    }
    
    private func convertToEntity(_ dto: GeocodingDTO) throws -> GeocodingResponseEntity {
        guard let last = dto.addresses.last else {
            throw EstateErrorResponseEntity(message: "검색 결과가 없습니다.")
        }
        
        return .init(
            address: last.roadAddress,
            geolocation: .init(
                latitude: Double(last.latitude)!,
                longitude: Double(last.longitude)!
            )
        )
    }
}
