//
//  DetailRepository.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import Foundation

protocol DetailRepository {
    func getEstateDetail(estateID: String) async throws -> GetEstateDetailResponseEntity
    func getSimilarEstates() async throws -> GetSimilarEstatesResponseEntity
    func updateEstateLike(estateID: String, request: UpdateEstateLikeRequestDTO) async throws -> UpdateEstateLikeResponseEntity
    func getAddress(coords: String) async throws -> ReverseGeocodingResponseEntity
    func createOrder(request: CreateOrderRequestDTO) async throws -> CreateOrderResponseEntity
    func validatePayment(request: ValidatePaymentRequestDTO) async throws -> Bool
}
