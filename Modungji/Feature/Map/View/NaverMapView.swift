//
//  NaverMap.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import SwiftUI

import NMapsMap

struct NaverMapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let naverMap = NMFNaverMapView()
        
        return naverMap
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        print(#function)
    }
}
