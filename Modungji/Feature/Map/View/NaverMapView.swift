//
//  NaverMap.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import SwiftUI

import NMapsMap

struct NaverMapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: self.viewModel)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let naverMap = self.getNaverMapView()
        
        // Naver Map Camera Delegate 연결
        naverMap.mapView.addCameraDelegate(delegate: context.coordinator)
        
        context.coordinator.cluster.mapView = naverMap.mapView
        return naverMap
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let viewModelMode: NMFMyPositionMode = self.viewModel.state.showCurrentLocationMarker ? .normal : .disabled
        
        if uiView.mapView.positionMode != viewModelMode {
            uiView.mapView.positionMode = viewModelMode
            if self.viewModel.state.showCurrentLocationMarker {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.moveCamera(
                        view: uiView.mapView,
                        latitude: uiView.mapView.locationOverlay.location.lat,
                        longitude: uiView.mapView.locationOverlay.location.lng
                    )
                }
            }
        }
        
        self.viewModel.state.estateMarkerList.forEach { marker in
            marker.mapView = uiView.mapView
        }
    }
    
    private func getNaverMapView() -> NMFNaverMapView {
        let naverMap = NMFNaverMapView()
        
        naverMap.mapView.minZoomLevel = 7
        naverMap.mapView.maxZoomLevel = 19

        naverMap.showZoomControls = false
        
        // 지도 시작 위치 설정 및 카메라 이동
        self.moveCamera(
            view: naverMap.mapView,
            latitude: self.viewModel.state.centerLocation.latitude,
            longitude: self.viewModel.state.centerLocation.longitude
        )
        
        return naverMap
    }
    
    private func moveCamera(view: NMFMapView, latitude: Double, longitude: Double) {
        let location = NMGLatLng(lat: latitude, lng: longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: location)
        cameraUpdate.animation = .fly
        view.moveCamera(cameraUpdate)
    }
}

extension NaverMapView {
    final class Coordinator: NSObject, NMFMapViewCameraDelegate, NMCClusterMarkerUpdater, NMCLeafMarkerUpdater {

        var cluster: NMCClusterer<MapClusterKey> = .init()
        
        private var viewModel: MapViewModel
        private var updateWorkItem: DispatchWorkItem?
        
        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
            
            super.init()
            
            let clusterBuilder = NMCComplexBuilder<MapClusterKey>()
            clusterBuilder.clusterMarkerUpdater = self
            clusterBuilder.leafMarkerUpdater = self
            self.cluster = clusterBuilder.build()
        }
        
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            self.updateWorkItem?.cancel()
            
            self.cluster.clear()
            
            self.updateWorkItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                
                let centerLocation = GeolocationEntity(latitude: mapView.latitude, longitude: mapView.longitude)
                let southLocation = GeolocationEntity(latitude: mapView.contentBounds.southWestLat, longitude: mapView.longitude)
                let entity = NaverMapEntity(
                    centerLocation: centerLocation,
                    southLocation: southLocation,
                    zoomLevel: mapView.zoomLevel
                )
                self.viewModel.action(.moveCamera(entity: entity))
            }
            
            guard let updateWorkItem else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: updateWorkItem)
        }
        
        func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
            marker.iconImage = NMFOverlayImage(image: MapClusterMarkerView(count: info.size).converToUIImage())
        }
        
        func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
            guard let key = info.key as? MapClusterKey else { return }
            
            marker.iconImage = NMFOverlayImage(
                image: MapLeafMarkerView(
                    imageName: key.entity.thumbnail,
                    deposit: key.entity.deposit,
                    monthlyRent: key.entity.monthlyRent
                ).converToUIImage()
            )
        }
    }
}
