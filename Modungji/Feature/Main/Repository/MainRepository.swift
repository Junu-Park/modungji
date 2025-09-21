//
//  MainRepository.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Foundation

protocol MainRepository {
    func getEstateBanner() async throws -> [EstateBannerResponseEntity]
    func getHotEstate() async throws -> [EstateResponseEntity]
    func getTodayEstateTopic() async throws -> [TodayEstateTopicResponseEntity]
    func getBanner() async throws -> [BannerResponseEntity]
    func getAddress(coords: String) async throws -> ReverseGeocodingResponseEntity
}
