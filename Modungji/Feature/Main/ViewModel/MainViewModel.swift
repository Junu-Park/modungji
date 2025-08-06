//
//  MainViewModel.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Combine

final class MainViewModel: ObservableObject {
    struct State {
        var EstateBannerList: [EstateBannerResponseEntity] = []
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
                let result = try await self.service.getEstateBanner()
                
                await MainActor.run {
                    self.state.EstateBannerList = result
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
