//
//  DetailViewModel.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import Foundation

final class DetailViewModel: ObservableObject {
    struct State {
        var isLoading: Bool = false
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
            options: .init(
                refrigerator: false,
                washer: false,
                airConditioner: false,
                closet: false,
                shoeRack: false,
                microwave: false,
                sink: false,
                tv: false
            ),
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
            updatedAt: ""
        )
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case getDetailData(estateID: String)
    }
    
    
    @Published var state: State = State()
    private let estateID: String
    private let service: DetailService
    private let pathModel: PathModel
    
    init(estateID: String, service: DetailService, pathModel: PathModel) {
        self.estateID = estateID
        self.service = service
        self.pathModel = pathModel
    }
    
    func action(_ action: Action) {
        switch action {
        case .getDetailData(let estateID):
            self.getDetailData(estateID: estateID)
        }
    }
    
    private func getDetailData(estateID: String) {
        Task {
            do {
                let response = try await self.service.getEstateDetail(estateID: estateID)
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
}
