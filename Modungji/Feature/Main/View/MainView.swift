//
//  MainView.swift
//  Modungji
//
//  Created by 박준우 on 5/23/25.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel: MainViewModel
    @State private var searchQuery: String = ""
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Group {
                Color.gray15
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        
                        self.estateBannerView(data: viewModel.state.EstateBannerList)
                        
                        Group {
                            self.estateFilterView()
                            
                            self.recentSearchEstateView()
                            
                            self.hotEstateView()
                        }
                        .padding(.bottom, 16)
                        
                        self.todayEstateTopicView()
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // searchBar가 상단 SafeArea에 겹치는 걸 방지하기 위한 ScrollView와 분리
            VStack {
                self.searchBar
                Spacer()
            }
        }
    }
}

// MARK: MainView View Component
extension MainView {
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("검색어를 입력해주세요.", text: self.$searchQuery)
            Spacer()
        }
        .padding(16)
        .shapeBorderBackground(shape: .capsule, backgroundColor: .gray0, borderColor: .gray45)
        .padding(20)
    }
    
    private func estateBannerView(data: [EstateBannerEntity]) -> some View {
        TabView {
            ForEach(data, id: \.id) { entity in
                self.estateBanner(data: entity)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 400)
    }
    
    private func estateBanner(data: EstateBannerEntity) -> some View {
        URLImageView(urlString: data.thumbnail) {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(.brightCream)
        }
        .scaledToFill()
        .frame(width: UIScreen.main.bounds.width)
        .clipped()
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 2) {
                    Image(.location)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text("\(data.address.area1) \(data.address.area3)")
                        .font(PDFont.caption2)
                }
                .foregroundStyle(.gray15)
                .padding(.vertical, 2)
                .padding(.leading, 4)
                .padding(.trailing, 8)
                .background(.gray60.opacity(0.5))
                .clipShape(Capsule())
                
                Text(data.title)
                    .foregroundStyle(.gray15)
                    .font(YHFont.title1)
                    .padding(.bottom, 2)
                
                Text(data.introduction)
                    .foregroundStyle(.gray60)
                    .font(YHFont.caption1)
            }
            .padding([.leading, .vertical], 20)
            .padding(.bottom, 40)
        }
    }
    
    private func estateFilterView() -> some View {
        HStack(spacing: 16) {
            ForEach(EstateCategory.allCases, id: \.self) { type in
                self.estateFilterButton(type: type)
            }
        }
        .padding(20)
    }
    
    private func estateFilterButton(type: EstateCategory) -> some View {
        Button {
            
        } label: {
            VStack(spacing: 4) {
                Image(type.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(12)
                    .background(.gray30, in: .rect(cornerRadius: 16))
                Text(type.rawValue)
                    .foregroundStyle(.gray75)
                    .font(PDFont.body3)
            }
        }
    }
    
    private func recentSearchEstateView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("최근검색 매물")
                    .font(PDFont.body2)
                    .bold()
                    .foregroundStyle(.gray90)
                    
                Spacer()
                
                Button {
                    
                } label: {
                    Text("View All")
                        .font(PDFont.caption1)
                        .bold()
                        .foregroundStyle(.deepCoast)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<6) { _ in
                        self.recentSearchEstateCard()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func recentSearchEstateCard() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 68, height: 68)
                .clipShape(.rect(cornerRadius: 10))
                .background(.brightCoast)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Text("추천")
                        .font(PDFont.caption3)
                        .foregroundStyle(.brightWood)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(.brightCream, in: .rect(cornerRadius: 4))
                    
                    Text("원룸")
                        .font(PDFont.caption2)
                        .foregroundStyle(.deepWood)
                }
                
                Text("월세 3,000/20")
                    .font(PDFont.body3)
                    .foregroundStyle(.gray90)
                
                Text("문래동 112.4㎡")
                    .font(PDFont.caption1)
                    .foregroundStyle(.gray60)
            }
        }
        .padding(10)
        .shapeBorderBackground(shape: .rect(cornerRadius: 16), backgroundColor: .gray0, borderColor: .gray30)
        .padding(.vertical,4)
        
    }
    
    private func hotEstateView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("HOT 매물")
                    .font(PDFont.body2)
                    .bold()
                    .foregroundStyle(.gray90)
                    
                Spacer()
                
                Button {
                    
                } label: {
                    Text("View All")
                        .font(PDFont.caption1)
                        .bold()
                        .foregroundStyle(.deepCoast)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(self.viewModel.state.hotEstateList, id: \.estateID) { estate in
                        self.hotEstateCard(estate: estate)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func hotEstateCard(estate: HotEstateResponseEntity) -> some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading) {
                if estate.isRecommended {
                    Image(.fire)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 18, height: 20)
                        .foregroundStyle(.gray0)
                }
                
                Spacer()
                
                Text("\(estate.likeCount)명이 함께 보는중")
                    .font(PDFont.caption3)
                    .foregroundStyle(.gray0)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .background(.gray60.opacity(0.5), in: .rect(cornerRadius: 4))
            }
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(estate.title)
                    .font(YHFont.caption1)
                    .foregroundStyle(.gray0)
                Text("월세 \(self.convertPriceToString(estate.deposit))/\(self.convertPriceToString(estate.monthlyRent))")
                    .font(PDFont.body1)
                    .foregroundStyle(.gray0)
                
                Text("\(estate.address) \(String(format: "%0.1f",estate.area))㎡")
                    .font(PDFont.caption2)
                    .foregroundStyle(.gray45)
                    .padding(.top, 16)
            }
        }
        .padding(10)
        .background {
            URLImageView(urlString: estate.thumbnail){
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
            }
            .scaledToFill()
        }
        .clipShape(.rect(cornerRadius: 12))
    }
    
    private func todayEstateTopicView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오늘의 부동산 TOPIC")
                .font(PDFont.body2)
                .bold()
                .foregroundStyle(.gray90)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
            
            
            LazyVStack {
                ForEach(self.viewModel.state.todayEstateTopicList, id: \.title) { topic in
                    self.todayEstateTopicRow(topic)
                }
            }
            .background(.gray0)
        }
    }
    
    private func todayEstateTopicRow(_ topic: TodayEstateTopicResponseEntity) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(topic.title)
                        .bold()
                        .foregroundStyle(.gray90)
                    
                    Text(topic.content)
                        .foregroundStyle(.gray60)
                }
                
                Spacer()
                
                Text(topic.date)
                    .foregroundStyle(.gray75)
            }
            .font(PDFont.body2)
            .padding(.vertical, 12)
            
            Divider()
        }
        .padding(.horizontal, 20)
    }
    
    private func todayEstateBannerRow(_ banner: BannerResponseEntity) -> some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("광고")
                        .font(PDFont.body2)
                        .bold()
                        .foregroundStyle(.gray75)
                    
                    Text(banner.name)
                        .font(PDFont.caption2)
                        .foregroundStyle(.gray45)
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.leading, 32)
            .background {
                URLImageView(urlString: banner.imageUrl) {
                    Color.gray15
                }
            }
            .clipShape(.rect(cornerRadius: 5))
            
            Divider()
        }
        .padding(.horizontal, 20)
    }
    
    private func convertPriceToString(_ price: Int) -> String {
        if price >= 1000000000000 {
            return String(price / 1000000000000) + "조"
        }
        else if price >= 100000000 {
            return String(price / 100000000) + "억"
        } else if price >= 10000 {
            return String(price / 10000) + "만"
        } else {
            return "1만↓"
        }
    }
}
