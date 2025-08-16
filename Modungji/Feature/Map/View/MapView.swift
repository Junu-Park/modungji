//
//  MapView.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import SwiftUI

struct MapView: View {
    @ObservedObject private var viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            NaverMapView(viewModel: self.viewModel)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        self.viewModel.action(.tapCurrentLocationButton)
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.clear)
                            .frame(width: 48, height: 48)
                            .shapeBorderBackground(
                                shape: .rect(cornerRadius: 10),
                                backgroundColor: .gray0,
                                borderColor: .gray45
                            )
                            .shadow(color: .gray45, radius: 4)
                            .overlay {
                                Image(self.viewModel.state.showCurrentLocationMarker ? .focus : .unfocus)
                                    .renderingMode(.template)
                                    .foregroundStyle(.gray75)
                            }
                    }
                    .padding(20)
                }
        }
        .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
            Button("닫기") { }
        }
    }
}
