//
//  EstateListView.swift
//  Modungji
//
//  Created by 박준우 on 9/21/25.
//

import SwiftUI

enum EstateListFilterType: String, CaseIterable {
    case area = "면적"
    case deposit = "보증금"
    case monthlyRent = "월세"
    case buildYear = "신축"
}

struct EstateListView: View {
    @ObservedObject private var viewModel: EstateListViewModel
    
    private let title: String
    private let isFromMap: Bool
    
    init(title: String, viewModel: EstateListViewModel, isFromMap: Bool) {
        self.title = title
        self.viewModel = viewModel
        self.isFromMap = isFromMap
    }
    
    var body: some View {
        VStack(spacing: 16) {
            self.buildFilterView()
            
            self.buildListView()
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden()
        .background(.gray15)
        .toolbar {
            self.buildNavigationBar()
        }
    }
    
    @ToolbarContentBuilder
    private func buildNavigationBar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                self.viewModel.action(.tapBack)
            } label: {
                Image(.chevron)
                    .renderingMode(.template)
                    .foregroundStyle(.gray75)
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 4){
                if self.isFromMap {
                    Image(.location)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                
                Text(self.title)
                    .font(PDFont.body1.bold())
            }
            .foregroundStyle(.gray75)
        }
    }
    
    @ViewBuilder
    private func buildFilterView() -> some View {
        ScrollView(.horizontal){
            HStack(spacing: 4) {
                ForEach(EstateListFilterType.allCases, id: \.self) { filter in
                    Button {
                        self.viewModel.action(.tapFilter(selectedFilter: filter))
                    } label: {
                        Text("\(filter.rawValue) 순")
                            .font(PDFont.body2)
                            .foregroundStyle(filter == self.viewModel.state.selectedFilter ? .brightWood : .gray75)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 20), backgroundColor: .gray0, borderColor: filter == self.viewModel.state.selectedFilter ? .brightWood : .gray45)
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func buildListView() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(self.viewModel.state.estateList.enumerated()), id: \.element.estateID) { (idx, data) in
                    VStack(spacing: 0) {
                        Button {
                            self.viewModel.action(.tapEstate(estateID: data.estateID))
                        } label: {
                            self.buildListRow(data)
                        }

                        if idx != (self.viewModel.state.estateList.count - 1) {
                            Divider()
                                .background(.gray30)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .id("\(idx)_\(data.estateID)")
                }
            }
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .shapeBorderBackground(shape: .rect(cornerRadii: .init(topLeading: 24, topTrailing: 24)), backgroundColor: .gray0, borderColor: .clear, shadowRadius: 1)
        .animation(.default, value: self.viewModel.state.estateList)
    }
    
    @ViewBuilder
    private func buildListRow(_ data: EstateResponseEntity) -> some View {
        HStack(spacing: 20) {
            URLImageView(urlString: data.thumbnail) {
                Color.brightCream
            }
            .frame(width: 140, height: 108)
            .overlay(alignment: .topLeading) {
                if data.isSafeEstate {
                    Image(.safty)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.gray15)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .shapeBorderBackground(shape: .circle, backgroundColor: .deepCoast, borderColor: .gray15)
                        .padding([.top, .leading], 8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(data.category)
                        .font(PDFont.caption2.bold())
                        .foregroundStyle(.brightWood)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 4), backgroundColor: .clear, borderColor: .brightWood)
                    
                    Text(data.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .font(PDFont.caption1.bold())
                        .foregroundStyle(.gray75)
                }
                
                Text("월세 \(data.deposit.convertPriceToString())/\(data.monthlyRent.convertPriceToString())")
                    .font(PDFont.body1.bold())
                    .foregroundStyle(.gray90)
                
                Text("\(String(format: "%0.1f",data.squareMeter))㎡ • \(data.floors)층")
                    .font(PDFont.caption1)
                    .foregroundStyle(.gray60)
                
                Text(data.address)
                    .font(PDFont.caption1)
                    .foregroundStyle(.gray60)
                
                Text("◆ \(data.introduction)")
                    .lineLimit(1)
                    .font(PDFont.caption1)
                    .foregroundStyle(.gray45)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
