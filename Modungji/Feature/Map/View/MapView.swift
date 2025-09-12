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
    
    private var safeAreaBottomPadding: CGFloat {
        var safeAreaBottom: CGFloat = 0
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
            safeAreaBottom = window.safeAreaInsets.bottom
        }
        
        return safeAreaBottom
    }
    
    @ViewBuilder
    private var currentLocationButton: some View {
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
    }
    
    @ViewBuilder
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(.search)
                .resizable()
                .renderingMode(.template)
                .frame(width: 20, height: 20)
            
            TextField("검색어를 입력하세요.", text: .init(get: {
                self.viewModel.state.searchQuery
            }, set: { query in
                self.viewModel.action(.inputSearchQuery(query: query))
            }))
            .tint(.gray60)
            .submitLabel(.search)
            .onSubmit {
                
            }
        }
        .foregroundStyle(.gray60)
        .font(PDFont.body2)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 20), backgroundColor: .clear, borderColor: .gray45)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    var body: some View {
        VStack {
            self.searchBar
            
            NaverMapView(viewModel: self.viewModel)
                .overlay(alignment: .bottomTrailing) {
                    self.currentLocationButton
                        .padding(self.safeAreaBottomPadding)
                }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    self.viewModel.action(.tapBackbutton)
                } label: {
                    Image(.chevron)
                        .renderingMode(.template)
                        .foregroundStyle(.gray75)
                }
            }
            
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 4){
                    Image(.location)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                    
                    Text(self.viewModel.state.searchQuery)
                        .font(PDFont.body1.bold())
                }
                .foregroundStyle(.gray75)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(.list)
                        .renderingMode(.template)
                        .foregroundStyle(.gray75)
                }
            }
        }
        .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
            Button("닫기") { }
        }
    }
}
