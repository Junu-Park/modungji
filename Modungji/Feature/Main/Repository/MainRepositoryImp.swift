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
    
    func getHotEstate() async throws -> [EstateResponseEntity] {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Estate.getHotEstate, successDecodingType: GetHotEstateResponseDTO.self)
        
        switch response {
        case .success(let success):
            return success.data.map { $0.convertToEntity() }
        case .failure(let failure):
            throw failure
        }
    }
    
    func getTodayEstateTopic() async throws -> [TodayEstateTopicResponseEntity] {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Estate.getTodayEstateTopic, successDecodingType: GetTodayEstateTopicResponseDTO.self)
        
        switch response {
        case .success(let success):
            return success.data.map { self.convertToEntity($0) }
        case .failure(let failure):
            throw failure
        }
    }
    
    func getBanner() async throws -> [BannerResponseEntity] {
        let response = try await self.networkManager.requestEstate(requestURL: EstateRouter.Banner.banner, successDecodingType: GetBannerResponseDTO.self)
        
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
    
    private func convertToEntity(_ dto: TodayEstateTopicDTO) -> TodayEstateTopicResponseEntity {
        
        return .init(
            title: dto.title,
            content: dto.content,
            date: dto.date,
            link: dto.link ?? ""
        )
    }
    
    private func convertToEntity(_ dto: BannerDTO) -> BannerResponseEntity {
        
        return BannerResponseEntity(
            name: dto.name,
            imageUrl: dto.imageUrl,
            payload: .init(
                type: dto.payload.type,
                value: dto.payload.value
            )
        )
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
}
