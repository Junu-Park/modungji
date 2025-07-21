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
    func getEstateWithID(estateID: String) async throws -> GetEstateDetailResponseEntity
    func getAuthorizationState() -> CLAuthorizationStatus
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
}
