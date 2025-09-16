//
//  MapService.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import Foundation

protocol MapService {
    func getEstateWithGeo(entity: GetEstateWithGeoRequestEntity) async throws -> [GetEstateWithGeoResponseEntity]
    func getAddress(coords: GeolocationEntity) async throws -> String
    func getCoordinator(query: String) async throws -> GeocodingResponseEntity
    func getUserLocation() async throws -> Bool
}
