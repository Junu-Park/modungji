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
    
    private func convertToEntity(_ dto: EstateBannerDTO) -> EstateBannerResponseEntity {
        
        return EstateBannerResponseEntity(estateId: dto.estateId, title: dto.title, introduction: dto.introduction, thumbnails: dto.thumbnails.first ?? "", geolocation: GeolocationEntity(latitude: dto.geolocation.latitude, longitude: dto.geolocation.longitude))
    }
}
