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
        return try await self.repository.getEstateDetail(estateID: estateID)
    }
    
    func updateEstateLike(estateID: String, status: Bool) async throws -> UpdateEstateLikeResponseEntity {
        let request = UpdateEstateLikeRequestDTO(like_status: status)
        return try await self.repository.updateEstateLike(estateID: estateID, request: request)
    }
}
