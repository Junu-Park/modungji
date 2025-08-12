//
//  DetailRepository.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import Foundation

protocol DetailRepository {
    func getEstateDetail(estateID: String) async throws -> GetEstateDetailResponseEntity
    func updateEstateLike(estateID: String, request: UpdateEstateLikeRequestDTO) async throws -> UpdateEstateLikeResponseEntity
}
