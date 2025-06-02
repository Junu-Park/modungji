//
//  MapView.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import SwiftUI

struct MapView: View {
    @StateObject var viewModel = NaverMapViewModel()
    
    var body: some View {
        VStack{
            Text("현재 좌표: \(self.viewModel.currentCoord.latitude, specifier: "%.3f"), \(self.viewModel.currentCoord.longitude, specifier: "%.3f")")
                .padding()
            
            NaverMapView(viewModel: self.viewModel)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        self.viewModel.setPositionMode()
                    } label: {
                        Circle()
                            .fill(.brightCoast)
                            .frame(width: 50, height: 50)
                            .padding(20)
                    }
                }
        }
    }
}
