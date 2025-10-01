//
//  DetailService.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import Foundation

protocol DetailService {
    func getEstateDetail(estateID: String) async throws -> GetEstateDetailResponseEntity
    func getSimilarEstates() async throws -> [EstateResponseEntity]
    func updateEstateLike(estateID: String, status: Bool) async throws -> UpdateEstateLikeResponseEntity
    func createOrder(estateID: String, price: Int) async throws -> CreateOrderResponseEntity
    func validatePayment(impUID: String) async throws -> Bool 
}
