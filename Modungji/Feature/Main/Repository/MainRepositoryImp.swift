//
//  MainRepositoryImp.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Foundation

struct MainRepositoryImp: MainRepository {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getEstateBanner() async throws -> [EstateBannerResponseEntity] {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Estate.getEstateBanner, successDecodingType: GetEstateBannerResponseDTO.self)
        
        switch response {
        case .success(let success):
            return success.data.map { self.convertToEntity($0) }
        case .failure(let failure):
            throw failure
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
    
    private func convertToEntity(_ dto: EstateBannerDTO) -> EstateBannerResponseEntity {
        
        return EstateBannerResponseEntity(estateId: dto.estateId, title: dto.title, introduction: dto.introduction, thumbnails: dto.thumbnails.first ?? "", geolocation: GeolocationEntity(latitude: dto.geolocation.latitude, longitude: dto.geolocation.longitude))
    }
    
    private func convertToEntity(_ dto: ReverseGeocodingDTO) -> ReverseGeocodingResponseEntity {
        guard let data = dto.results.first?.region else {
            return ReverseGeocodingResponseEntity(area1: "알 수 없음", area1Alias: "알 수 없음", area2: "알 수 없음", area3: "알 수 없음")
        }
        
        return ReverseGeocodingResponseEntity(area1: data.area1.name, area1Alias: data.area1.alias ?? data.area1.name, area2: data.area2.name, area3: data.area3.name)
    }
}
