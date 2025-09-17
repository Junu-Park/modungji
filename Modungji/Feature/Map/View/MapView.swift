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
                self.viewModel.action(.search)
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
                .overlay {
                    VStack {
                        HStack(spacing: 4) {
                            ForEach(MapOptionType.allCases, id: \.self) { option in
                                self.buildOption(option)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if self.viewModel.state.selectedOptionType != nil {
                            self.buildOptionView()
                                .padding(.vertical, 4)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 12) {
                            HStack {
                                Spacer()
                                
                                self.currentLocationButton
                            }
                            .padding(.trailing, 20)
                            
                            if !self.viewModel.state.estateList.isEmpty {
                                self.buildEstateInfoList()
                            }
                        }
                        .padding(.bottom, self.safeAreaBottomPadding)
                    }
                }
                .animation(.default, value: self.viewModel.state.estateList)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    self.viewModel.action(.tapBackButton)
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
                    
                    Text(self.viewModel.state.currentAddress)
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
    
    @ViewBuilder
    private func buildOption(_ option: MapOptionType) -> some View {
        let isSelected = self.viewModel.state.selectedOptionType == option
        let title: String? = {
            switch option {
            case .category:
                return self.viewModel.state.selectedCategory?.rawValue
            case .area:
                return nil
            case .monthlyRent:
                return nil
            case .deposit:
                return nil
            }
        }()
        
        Button {
            withAnimation {
                self.viewModel.action(.tapOption(option: isSelected ? nil : option))
            }
        } label: {
            Text(title ?? "\(option.rawValue) 선택")
                .font(PDFont.body2)
                .bold(isSelected)
                .foregroundStyle(isSelected ? .brightWood : .gray75)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 20), backgroundColor: .gray0, borderColor: isSelected ? .brightWood : .gray45)
        }
    }
    
    @ViewBuilder
    private func buildOptionView() -> some View {
        self.buildOptionControl()
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 16), backgroundColor: .white, borderColor: .clear, shadowRadius: 5)
    }
    
    @ViewBuilder
    private func buildOptionControl() -> some View {
        switch self.viewModel.state.selectedOptionType {
        case .category:
            self.buildCategoryOption()
        case .area:
            EmptyView()
        case .monthlyRent:
            EmptyView()
        case .deposit:
            EmptyView()
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func buildCategoryOption() -> some View {
        HStack(spacing: 16) {
            ForEach(EstateCategory.allCases, id: \.self) { type in
                self.buildCategoryButton(type: type)
            }
        }
    }
    
    @ViewBuilder
    private func buildCategoryButton(type: EstateCategory) -> some View {
        let isSelected = self.viewModel.state.selectedCategory == type
        
        Button {
            withAnimation {
                self.viewModel.action(.selectCategory(category: isSelected ? nil : type))
            }
        } label: {
            VStack(spacing: 4) {
                Image(type.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(12)
                    .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 16), backgroundColor: .gray0, borderColor: isSelected ? .brightWood : .gray30)
                Text(type.rawValue)
                    .foregroundStyle(isSelected ? .brightWood : .gray75)
                    .font(PDFont.body3)
                    .bold(isSelected)
            }
        }
    }
    
    @ViewBuilder
    private func buildEstateInfoList() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 12) {
                ForEach(self.viewModel.state.estateList, id: \.estateId) { estate in
                    Button {
                        self.viewModel.action(.tapEstate(estateID: estate.estateId))
                    } label:{
                        self.buildEstateInfo(estate)
                    }
                }
            }
            .padding(.horizontal, 20)
            .fixedSize()
        }
        .scrollIndicators(.never)
    }
    
    @ViewBuilder
    private func buildEstateInfo(_ estate: GetEstateWithGeoResponseEntity) -> some View {
        HStack(spacing: 20) {
            URLImageView(urlString: estate.thumbnail) {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(estate.title)")
                    .font(PDFont.body3.bold())
                    .foregroundStyle(.gray75)
                Text("월세 \(estate.deposit.convertPriceToString())/\(estate.monthlyRent.convertPriceToString())")
                    .font(PDFont.title1.bold())
                    .foregroundStyle(.gray90)
                Text("\(String(format: "%0.1f", estate.area))㎡ • \(estate.floors)층")
                    .font(PDFont.caption1)
                    .foregroundStyle(.gray60)
                Text(estate.address)
                    .font(PDFont.caption1)
                    .foregroundStyle(.gray60)
            }
        }
        .padding(16)
        .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 16), backgroundColor: .gray0, borderColor: .clear, shadowRadius: 5)
    }
}
