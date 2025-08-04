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
    
    func getBannerEstate() async throws -> [BannerEstateResponseEntity] {
        
        return try await self.repository.getBannerEstate()
    }
}
