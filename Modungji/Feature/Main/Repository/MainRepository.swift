//
//  MainRepository.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Foundation

protocol MainRepository {
    func getEstateBanner() async throws -> [EstateBannerResponseEntity]
    func getHotEstate() async throws -> [HotEstateResponseEntity]
    func getTodayEstateTopic() async throws -> [TodayEstateTopicResponseEntity]
    func getAddress(coords: String) async throws -> ReverseGeocodingResponseEntity
}
