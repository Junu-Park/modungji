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
    private var updateWorkItem: DispatchWorkItem?
    
    func setNaverMapView(_ view: NMFMapView) {
        self.mapView = view
        guard let mapView else {
            return
        }
        mapView.addCameraDelegate(delegate: self)
    }
    
    func setPositionMode() {
        guard let mapView else {
            return
        }
        
        if mapView.positionMode == .disabled {
            mapView.positionMode = .normal
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let nmCoord = mapView.locationOverlay.location
                let cameraUpdate = NMFCameraUpdate(scrollTo: nmCoord)
                cameraUpdate.animation = .fly
                
                mapView.moveCamera(cameraUpdate)
            }
        } else {
            mapView.positionMode = .disabled
        }
    }
}

extension NaverMapViewModel: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        self.updateWorkItem?.cancel()
        
        self.updateWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            let coord = mapView.cameraPosition.target
            self.currentCoord = .init(latitude: coord.lat, longitude: coord.lng)
        }
        
        guard let updateWorkItem else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: updateWorkItem)
    }
}
