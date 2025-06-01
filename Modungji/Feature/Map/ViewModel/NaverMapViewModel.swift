//
//  NaverMapViewModel.swift
//  Modungji
//
//  Created by 박준우 on 6/1/25.
//

import NMapsMap

final class NaverMapViewModel: NSObject, ObservableObject {
    @Published var currentCoord: CoordinateEntity = .init(latitude: 37.5666805, longitude: 126.9784147)
    @Published var currentMode: NMFMyPositionMode = .disabled {
        didSet {
            self.setPositionMode(self.currentMode)
        }
    }
    
    private weak var mapView: NMFMapView?
    private var updateWorkItem: DispatchWorkItem?
    
    func setNaverMapView(_ view: NMFMapView) {
        self.mapView = view
        guard let mapView else {
            return
        }
        mapView.addCameraDelegate(delegate: self)
    }
    
    private func setPositionMode(_ mode: NMFMyPositionMode) {
        guard let mapView else {
            return
        }
        mapView.positionMode = mode
        if mode == .normal {
            let nmCoord = mapView.locationOverlay.location
            let cameraUpdate = NMFCameraUpdate(scrollTo: nmCoord)
            cameraUpdate.animation = .fly
            
            mapView.moveCamera(cameraUpdate)
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
