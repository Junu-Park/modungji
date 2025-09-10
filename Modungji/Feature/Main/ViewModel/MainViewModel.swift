//
//  MainViewModel.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Combine

final class MainViewModel: ObservableObject {
    struct State {
        var EstateBannerList: [EstateBannerEntity] = []
        var hotEstateList: [HotEstateResponseEntity] = []
        var todayEstateTopicList: [TodayEstateTopicResponseEntity] = []
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case initView
    }
    
    @Published var state: State = State()
    private var cancellables: Set<AnyCancellable> = []
    private let service: MainService
    
    init(service: MainService) {
        self.service = service
    }
    
    private func transform() {
        
    }
    
    func action(_ action: Action) {
        switch action {
        case .initView:
            self.initView()
        }
    }
    
    private func initView() {
        Task {
            do {
                async let bannerResult = self.service.getEstateBanner()
                async let hotResult = self.service.getHotEstate()
                async let topicResult = self.service.getTodayEstateTopic()
                
                let (bannerResponse, hotResponse, topicResponse) = try await (bannerResult, hotResult, topicResult)
                
                await MainActor.run {
                    self.state.EstateBannerList = bannerResponse
                    self.state.hotEstateList = hotResponse
                    self.state.todayEstateTopicList = topicResponse
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            }
        }
    }
}
