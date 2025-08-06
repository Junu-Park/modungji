//
//  MainRepository.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Foundation

protocol MainRepository {
    func getEstateBanner() async throws -> [EstateBannerResponseEntity]
}
