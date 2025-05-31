//
//  NaverMapViewModel.swift
//  Modungji
//
//  Created by 박준우 on 6/1/25.
//

import NMapsMap

final class NaverMapViewModel: NSObject, ObservableObject {
    @Published var currentCoord: CoordinateEntity = .init(latitude: 37.5666805, longitude: 126.9784147)
    
    private weak var mapView: NMFMapView?
    
    func setNaverMapView(_ view: NMFMapView) {
        self.mapView = view
        guard let mapView else {
            return
        }
        mapView.addCameraDelegate(delegate: self)
    }
}

extension NaverMapViewModel: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        let coord = mapView.cameraPosition.target
        self.currentCoord = .init(latitude: coord.lat, longitude: coord.lng)
    }
}
