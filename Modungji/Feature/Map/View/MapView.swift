//
//  MapView.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import SwiftUI

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack{
            NaverMapView(viewModel: self.viewModel)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        self.viewModel.action(.tapCurrentLocationButton)
                    } label: {
                        Circle()
                            .fill(self.viewModel.state.showCurrentLocationMarker ? .red : .brightCoast)
                            .frame(width: 50, height: 50)
                            .padding(20)
                    }
                }
        }
        .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
            Button("닫기") { }
        }
    }
}
