//
//  DetailView.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if self.viewModel.state.isLoading {
                ProgressView()
                    .tint(.deepCream)
                    .navigationBarBackButtonHidden()
                    .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
                        Button("닫기") { }
                    }
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        ImageCarouselView(imageURLs: self.viewModel.state.detailData.thumbnails)
                            .frame(height: 250)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(.safty)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    
                                    Text("구매자 안심매물")
                                        .font(PDFont.caption1.bold())
                                }
                                .foregroundStyle(self.viewModel.state.detailData.isSafeEstate ? .deepCoast : .gray30)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .shapeBorderBackground(shape: .capsule, backgroundColor: .clear, borderColor: self.viewModel.state.detailData.isSafeEstate ? .deepCoast : .gray30)
                                .padding(.vertical, 16)
                                
                                Spacer()
                                
                                Text(Date.iso8601StringToDate(self.viewModel.state.detailData.updatedAt).getRelativeTimeString())
                                    .foregroundStyle(.gray45)
                                    .font(PDFont.body3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(self.viewModel.state.detailData.address)
                                
                                HStack(spacing: 8) {
                                    Text("월세")
                                        .foregroundStyle(.gray75)
                                        .font(YHFont.title1)
                                    
                                    Text("\(self.viewModel.state.detailData.deposit / 1000)/\(self.viewModel.state.detailData.monthlyRent / 1000)")
                                        .foregroundStyle(.gray90)
                                        .font(PDFont.title1)
                                }
                                
                                Text("관리비 \(self.viewModel.state.detailData.maintenanceFee / 1000)만원 • \(String(format: "%.1f", self.viewModel.state.detailData.area))㎡")
                            }
                            .foregroundStyle(.gray60)
                            .font(PDFont.body2)
                            .padding(.bottom, 16)
                            
                            Divider()
                            
                            Text("옵션 정보")
                                .foregroundStyle(.gray75)
                                .font(PDFont.body2.bold())
                                .padding(.vertical, 8)
                            
                            if !self.viewModel.state.detailData.options.isEmpty {
                                Grid(horizontalSpacing: 28, verticalSpacing: 8) {
                                    GridRow {
                                        ForEach(self.viewModel.state.detailData.options[0..<4], id: \.name) { opt in
                                            VStack(spacing: 8) {
                                                Image(opt.image)
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 32, height: 32)
                                                    .scaledToFit()
                                                
                                                Text(opt.name)
                                                    .font(PDFont.caption1.bold())
                                            }
                                            .foregroundStyle(opt.state ? .gray75 : .gray30)
                                            .padding(.vertical, 4)
                                        }
                                    }
                                    
                                    GridRow {
                                        ForEach(self.viewModel.state.detailData.options[4..<8], id: \.name) { opt in
                                            VStack(spacing: 8) {
                                                Image(opt.image)
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 32, height: 32)
                                                    .scaledToFit()
                                                
                                                Text(opt.name)
                                                    .font(PDFont.caption1.bold())
                                            }
                                            .foregroundStyle(opt.state ? .gray75 : .gray30)
                                        }
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 16), backgroundColor: .gray0, borderColor: .gray30)
                                .padding(.vertical, 8)
                            }
                            
                            HStack(spacing: 4) {
                                Image(.parking)
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                                Text("세대별 차량 \(self.viewModel.state.detailData.parkingCount)대 주차 가능")
                                    .font(PDFont.caption1.bold())
                            }
                            .foregroundStyle(.gray60)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 16), backgroundColor: .gray0, borderColor: .gray30)
                            .padding(.bottom, 16)
                            
                            Divider()
                            
                            Text("상세 설명")
                                .foregroundStyle(.gray75)
                                .font(PDFont.body2.bold())
                                .padding(.vertical, 8)
                            
                            Text(self.viewModel.state.detailData.description)
                                .foregroundStyle(.gray60)
                                .font(PDFont.caption1)
                                .lineLimit(nil)
                                .padding(.vertical, 8)
                                .padding(.bottom, 16)
                            
                            Divider()
                            
                            Text("유사한 매물")
                                .foregroundStyle(.gray75)
                                .font(PDFont.body2.bold())
                                .padding(.vertical, 8)
                            
                            Label {
                                Text("새싹 AI 알고리즘 기반으로 추천된 매물입니다.")
                                    .font(PDFont.caption2)
                            } icon: {
                                Image(.safty)
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            .foregroundStyle(.gray45)
                            .labelStyle(.customLabelStyle(spacing: 4))
                            .padding(.bottom, 16)
                            
                            Divider()
                            
                            Text("중개사 정보")
                                .foregroundStyle(.gray75)
                                .font(PDFont.body2.bold())
                                .padding(.vertical, 8)
                            
                            HStack(spacing: 0) {
                                URLImageView(urlString: self.viewModel.state.detailData.creator.profileImage)
                                    .frame(width: 60, height: 60)
                                    .clipShape(.circle)
                                    .padding(.trailing, 12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(self.viewModel.state.detailData.creator.nick)
                                        .foregroundStyle(.gray90)
                                        .font(PDFont.body1.bold())
                                    
                                    Text(self.viewModel.state.detailData.creator.introduction)
                                        .foregroundStyle(.gray60)
                                        .font(PDFont.body3)
                                }
                                
                                Spacer()
                                
                                Button {
                                    if let phoneURL = URL(string: "tel://\(123456789)"), UIApplication.shared.canOpenURL(phoneURL) {
                                        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                                    }
                                } label: {
                                    Image(.phone)
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(.gray0)
                                        .frame(width: 24, height: 24)
                                        .padding(8)
                                        .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 8), backgroundColor: .deepCream, borderColor: .clear)
                                }
                                .padding(.trailing, 8)

                                Button {
                                    self.viewModel.action(.tapChat)
                                } label: {
                                    Image(.frame)
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(.gray0)
                                        .frame(width: 24, height: 24)
                                        .padding(8)
                                        .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 8), backgroundColor: .deepCream, borderColor: .clear)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    
                    Divider()
                    
                    HStack(spacing: 16) {
                        Button {
                            self.viewModel.action(.tapLike)
                        } label: {
                            Image(self.viewModel.state.detailData.isLiked ? .likeFill : .likeEmpty)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.gray75)
                                .frame(width: 32, height: 32)
                                .padding(8)
                        }
                        
                        Button {
                            self.viewModel.action(.tapPayment)
                        } label: {
                            Text(self.viewModel.state.detailData.isReserved ? "예약완료" : "예약하기")
                                .foregroundStyle(.gray0)
                                .font(PDFont.title1.bold())
                                .padding(.vertical, 12)
                                .frame(maxWidth: UIScreen.main.bounds.width)
                                .background(self.viewModel.state.detailData.isReserved ? .gray45 : .deepCream)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .disabled(self.viewModel.state.detailData.isReserved)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                }
                .background(.gray15)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(spacing: 10){
                            Button {
                                self.dismiss()
                            } label: {
                                Image(.chevron)
                                    .renderingMode(.template)
                            }
                            
                            Text(self.viewModel.state.detailData.title)
                                .font(PDFont.body1.bold())
                        }
                        .foregroundStyle(.gray75)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 10){
                            Button {
                                self.viewModel.action(.tapLike)
                            } label: {
                                Image(self.viewModel.state.detailData.isLiked ? .likeFill : .likeEmpty)
                                    .renderingMode(.template)
                            }
                        }
                        .foregroundStyle(.gray75)
                    }
                }
                .alert(self.viewModel.state.errorMessage, isPresented: self.$viewModel.state.showErrorAlert) {
                    Button("닫기") { }
                }
            }
            
            if self.viewModel.state.isProgressPayment, self.viewModel.state.payment != nil {
                PaymentView(viewModel: self.viewModel)
            }
        }
    }
}

extension Date {
    static func iso8601StringToDate(_ str: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter.date(from: str) ?? Date()
    }
    
    func getRelativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - LabelStyle 커스텀
struct CustomLabelStyle: LabelStyle {
    private let spacing: CGFloat
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
extension LabelStyle where Self == CustomLabelStyle {
    static func customLabelStyle(spacing: CGFloat) -> CustomLabelStyle {
        return CustomLabelStyle(spacing: spacing)
    }
}
