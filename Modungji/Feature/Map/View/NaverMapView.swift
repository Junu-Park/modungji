//
//  NaverMap.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import SwiftUI

import NMapsMap
/*
 화면 이동 시,
 Coordinator -> ViewModel -> NaverMapView
 
 데이터 변경 시,
 부모 뷰 -> ViewModel -> NaverMapView -> Coordinator
 */
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

        if self.viewModel.state.shouldMoveCamera {
            self.moveCamera(
                view: uiView.mapView,
                latitude: self.viewModel.state.centerLocation.latitude,
                longitude: self.viewModel.state.centerLocation.longitude
            )

            self.viewModel.state.shouldMoveCamera = false
        }

        context.coordinator.setMarkerList()
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

// MARK: - Coordinator
final class Coordinator: NSObject, NMFMapViewCameraDelegate {
    
    var cluster: NMCClusterer<MapClusterKey>
    private weak var viewModel: MapViewModel?
    private var clusterMarkerUpdater: NMCClusterMarkerUpdater
    private var leafMarkerUpdater: NMCLeafMarkerUpdater
    private var thresholdStrategy: NMCThresholdStrategy
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        self.clusterMarkerUpdater = ClusterMarkerUpdater()
        self.leafMarkerUpdater = LeafMarkerUpdater(viewModel: viewModel)
        self.thresholdStrategy = ThresholdStrategy()
        
        let clusterBuilder = NMCComplexBuilder<MapClusterKey>()
        clusterBuilder.clusterMarkerUpdater = self.clusterMarkerUpdater
        clusterBuilder.leafMarkerUpdater = self.leafMarkerUpdater
        clusterBuilder.thresholdStrategy = self.thresholdStrategy
        clusterBuilder.minClusteringZoom = 10
        clusterBuilder.maxClusteringZoom = 18
        self.cluster = clusterBuilder.build()
        
        super.init()
    }
    
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        
        self.dismissKeyboard()
        
        if !self.cluster.empty {
            self.cluster.clear()
        }
        
        let centerLocation = GeolocationEntity(latitude: mapView.latitude, longitude: mapView.longitude)
        let southLocation = GeolocationEntity(latitude: mapView.contentBounds.southWestLat, longitude: mapView.longitude)
        let entity = NaverMapEntity(
            centerLocation: centerLocation,
            southLocation: southLocation,
            zoomLevel: mapView.zoomLevel
        )
        self.viewModel?.action(.moveCamera(entity: entity))
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func setMarkerList() {
        var list: [MapClusterKey: NSNull] = [:]
        for entity in self.viewModel?.state.estateList ?? [] {
            list[MapClusterKey(entity: entity)] = NSNull()
        }
        
        self.cluster.addAll(list)
    }
}

// MARK: - ClusterMarkerUpdater
final class ClusterMarkerUpdater: NSObject, NMCClusterMarkerUpdater {
    func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
        marker.iconImage = NMFOverlayImage(image: MapClusterMarkerView(count: info.size).converToUIImage())
        marker.touchHandler = { overlay in
            return true
        }
    }
}

// MARK: - LeafMarkerUpdater
final class LeafMarkerUpdater: NSObject, NMCLeafMarkerUpdater {
    private weak var viewModel: MapViewModel?
    private var defaultLeafMarkerImage: NMFOverlayImage = NMFOverlayImage(
        image: DefaultMapLeafMakerView().converToUIImage(),
        reuseIdentifier: "DefaultMapLeafMakerImage"
    )
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        guard let key = info.key as? MapClusterKey else { return }
        
        marker.iconImage = self.defaultLeafMarkerImage
        
        marker.touchHandler = { [weak self] overlay in
            self?.viewModel?.action(.tapEstate(estateID: key.entity.estateId))
            return true
        }
        
        Task {
            do {
                let response = try await NetworkManager().requestEstate(requestURL: EstateRouter.File.file(urlString: key.entity.thumbnail))
                
                switch response {
                case .success(let success):
                    if let loadedImage = UIImage(data: success) {
                        await MainActor.run {
                            marker.iconImage = NMFOverlayImage(
                                image: MapLeafMarkerView(
                                    image: loadedImage,
                                    deposit: key.entity.deposit,
                                    monthlyRent: key.entity.monthlyRent
                                ).converToUIImage(),
                                reuseIdentifier: key.entity.estateId
                            )
                        }
                    }
                case .failure:
                    break
                }
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - ThresholdStrategy
final class ThresholdStrategy: NSObject, NMCThresholdStrategy {
    func getThreshold(_ zoom: Int) -> Double {
        switch zoom {
        case ...10:
            return 75
        case 11...12:
            return 80
        case 13...14:
            return 85
        case 15...16:
            return 90
        case 17...18:
            return 95
        case 19...:
            return 100
        default:
            return 70
        }
    }
}
