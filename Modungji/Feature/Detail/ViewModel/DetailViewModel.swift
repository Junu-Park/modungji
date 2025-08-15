//
//  DetailViewModel.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import Foundation

import iamport_ios

final class DetailViewModel: ObservableObject {
    struct State {
        var isLoading: Bool = true
        var detailData: GetEstateDetailResponseEntity =
            .init(
            estateID: "",
            category: "",
            title: "",
            introduction: "",
            reservationPrice: 0,
            thumbnails: [],
            description: "",
            deposit: 0,
            monthlyRent: 0,
            builtYear: "",
            maintenanceFee: 0,
            area: 0,
            parkingCount: 0,
            floors: 0,
            options: [],
            geolocation: .init(
                latitude: 0,
                longitude: 0
            ),
            creator: .init(
                userID: "",
                nick: "",
                introduction: "",
                profileImage: ""
            ),
            isLiked: false,
            isReserved: false,
            likeCount: 0,
            isSafeEstate: false,
            isRecommended: false,
            comments: [],
            createdAt: "",
            updatedAt: "",
            address: ""
        )
        var showPayment: Bool = false
        var payment: IamportPayment?
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case getDetailData
        case tapLike
        case tapPayment
        case paymentValidation
    }
    
    @Published var state: State = State()
    private let estateID: String
    private let service: DetailService
    private let pathModel: PathModel
    
    init(estateID: String, service: DetailService, pathModel: PathModel) {
        self.estateID = estateID
        self.service = service
        self.pathModel = pathModel
        
        self.getDetailData()
    }
    
    func action(_ action: Action) {
        switch action {
        case .getDetailData:
            self.getDetailData()
        case .tapLike:
            self.tapLike()
        case .tapPayment:
            self.tapPayment()
        case .paymentValidation:
            self.paymentValidation()
        }
    }
    
    private func getDetailData() {
        Task { @MainActor in
            defer {
                self.state.isLoading = false
            }
            do {
                self.state.isLoading = true
                self.state.detailData = try await self.service.getEstateDetail(estateID: self.estateID)
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
    
    private func tapLike() {
        Task {
            do {
                let status = try await self.service.updateEstateLike(estateID: self.estateID, status: !self.state.detailData.isLiked).likeStatus
                await MainActor.run {
                    self.state.detailData.isLiked = status
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
    
    private func tapPayment() {
        
        self.state.isLoading = true
        
        Task {
            do {
                let orderResponse = try await self.service.createOrder(estateID: self.estateID, price: self.state.detailData.reservationPrice)
                
                await MainActor.run {
                    self.state.payment = IamportPayment(
                        pg: "PG.html5_inicis.makePgRawName(pgId: \"INIpayTest\")",
                        merchant_uid: orderResponse.orderCode,
                        amount: "\(orderResponse.totalPrice)"
                    )
                    .then {
                        $0.pay_method = PayMethod.card.rawValue
                        $0.name = self.state.detailData.title
                        $0.buyer_name = "박준우"
                        $0.app_scheme = "iamport"
                    }
                    
                    self.state.showPayment = true
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
    
    private func paymentValidation() {
        self.state.isLoading = false
    }
}
