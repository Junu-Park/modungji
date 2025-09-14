//
//  MapRepository.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import CoreLocation
import Foundation


protocol MapRepository {
    func getEstateWithGeo(entity: GetEstateWithGeoRequestEntity) async throws -> [GetEstateWithGeoResponseEntity]
    func getAddress(coords: String) async throws -> ReverseGeocodingResponseEntity
    func getAuthorizationState() -> CLAuthorizationStatus
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
}
