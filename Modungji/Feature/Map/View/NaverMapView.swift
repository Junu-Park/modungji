//
//  NaverMap.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import SwiftUI

import NMapsMap

struct NaverMapView: UIViewRepresentable {
    @ObservedObject var viewModel: NaverMapViewModel
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        return getNaverMapView()
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        print(#function)
    }
    
    private func getNaverMapView() -> NMFNaverMapView {
        let naverMap = NMFNaverMapView()
        
        // 줌 컨트롤 UI 제거
        naverMap.showZoomControls = false
        
        // 시작 위치 설정
        let starCoord = NMGLatLng(
            lat: self.viewModel.currentCoord.latitude,
            lng: self.viewModel.currentCoord.longitude
        )
        let cameraUpdate = NMFCameraUpdate(scrollTo: starCoord)
        cameraUpdate.animation = .fly
        naverMap.mapView.moveCamera(cameraUpdate)
        
        // viewModel과 연결
        self.viewModel.setNaverMapView(naverMap.mapView)
        
        return naverMap
    }
}
