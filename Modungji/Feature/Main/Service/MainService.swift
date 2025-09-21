//
//  MainService.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Foundation

protocol MainService {
    func getEstateBanner() async throws -> [EstateBannerEntity]
    func getHotEstate() async throws -> [EstateResponseEntity]
    func getTodayEstateTopic() async throws -> [TodayEstateTopicResponseEntity]
    func getBanner() async throws -> [BannerResponseEntity]
}
