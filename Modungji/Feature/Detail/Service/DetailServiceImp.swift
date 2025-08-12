//
//  DetailServiceImp.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import CoreLocation

struct DetailServiceImp: DetailService {
    
    private let repository: DetailRepository
    
    init(repository: DetailRepository) {
        self.repository = repository
    }
    
    func getEstateDetail(estateID: String) async throws -> GetEstateDetailResponseEntity {
        var detailResponse = try await self.repository.getEstateDetail(estateID: estateID)
        let addressResponse = try await self.repository.getAddress(coords: "\(detailResponse.geolocation.longitude),\(detailResponse.geolocation.latitude)")
        if addressResponse.isExistRoadAddr {
            detailResponse.address = "\(addressResponse.area1Alias) \(addressResponse.area2) \(addressResponse.roadName) \(addressResponse.roadNumber)"
        } else {
            detailResponse.address = "\(addressResponse.area1Alias) \(addressResponse.area2) \(addressResponse.area3)"
        }
        return detailResponse
    }
    
    func updateEstateLike(estateID: String, status: Bool) async throws -> UpdateEstateLikeResponseEntity {
        let request = UpdateEstateLikeRequestDTO(like_status: status)
        return try await self.repository.updateEstateLike(estateID: estateID, request: request)
    }
}
