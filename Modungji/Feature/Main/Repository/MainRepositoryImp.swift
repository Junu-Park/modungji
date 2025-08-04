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
    
    func getBannerEstate() async throws -> [BannerEstateResponseEntity] {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Estate.getBannerEstate, successDecodingType: GetBannerEstateResponseDTO.self)
        
        switch response {
        case .success(let success):
            return success.data.map { self.convertToEntity($0) }
        case .failure(let failure):
            throw failure
        }
    }
    
    private func convertToEntity(_ dto: BannerEstateDTO) -> BannerEstateResponseEntity {
        
        return BannerEstateResponseEntity(estateId: dto.estateId, title: dto.title, introduction: dto.introduction, thumbnails: dto.thumbnails.first ?? "", geolocation: GeolocationEntity(latitude: dto.geolocation.latitude, longitude: dto.geolocation.longitude))
    }
}
