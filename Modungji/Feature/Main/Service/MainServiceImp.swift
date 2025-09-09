//
//  MainServiceImp.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Foundation

struct MainServiceImp: MainService {
    private let repository: MainRepository
    
    init(repository: MainRepository) {
        self.repository = repository
    }
    
    func getEstateBanner() async throws -> [EstateBannerEntity] {
        let response = try await self.repository.getEstateBanner()
        
        return try await withThrowingTaskGroup(of: (Int, EstateBannerEntity).self) { group in
            for (index, banner) in response.enumerated() {
                group.addTask {
                    let address = try await self.repository.getAddress(
                        coords: "\(banner.geolocation.longitude),\(banner.geolocation.latitude)"
                    )
                    
                    let entity = EstateBannerEntity(
                        id: banner.estateId,
                        title: banner.title,
                        introduction: banner.introduction,
                        thumbnail: banner.thumbnails,
                        address: .init(area1: address.area1Alias, area2: address.area2, area3: address.area3)
                    )
                    
                    return (index, entity)
                }
            }
            
            var result = Array<EstateBannerEntity?>(repeating: nil, count: response.count)
            
            for try await (index, entity) in group {
                result[index] = entity
            }
            
            return result.compactMap { $0 }
        }
    }
    
    func getHotEstate() async throws -> [HotEstateResponseEntity] {
        let response = try await self.repository.getHotEstate()
        
        return try await withThrowingTaskGroup(of: (Int, HotEstateResponseEntity).self) { group in
            for (index, estate) in response.enumerated() {
                group.addTask {
                    let address = try await self.repository.getAddress(
                        coords: "\(estate.geolocation.longitude),\(estate.geolocation.latitude)"
                    )
                    
                    var entity = estate
                    entity.address = address.area3
                    
                    return (index, entity)
                }
            }
            
            var result = Array<HotEstateResponseEntity?>(repeating: nil, count: response.count)
            
            for try await (index, entity) in group {
                result[index] = entity
            }
            
            return result.compactMap { $0 }
        }
    }
}
