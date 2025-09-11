//
//  MainViewModel.swift
//  Modungji
//
//  Created by 박준우 on 7/24/25.
//

import Combine
import WebKit

final class MainViewModel: NSObject, ObservableObject {
    struct State {
        var EstateBannerList: [EstateBannerEntity] = []
        var recentSearchList: [String] = []
        var hotEstateList: [HotEstateResponseEntity] = []
        var todayEstateTopicList: [TodayEstateTopicResponseEntity] = []
        var todayEstateBannerList: [BannerResponseEntity] = []
        var showWebView: Bool = false
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case initView
        case tapSearchBar
        case tapBanner
        case enrollWebView(webView: WKWebView)
    }
    
    @Published var state: State = State()
    private var cancellables: Set<AnyCancellable> = []
    private let service: MainService
    private weak var pathModel: PathModel?
    private weak var webView: WKWebView? = nil
    
    init(service: MainService, pathModel: PathModel) {
        self.service = service
        self.pathModel = pathModel
        
        super.init()
        
        self.initView()
    }
    
    private func transform() {
        
    }
    
    func action(_ action: Action) {
        switch action {
        case .initView:
            self.initView()
        case .tapSearchBar:
            self.pathModel?.push(.map)
        case .tapBanner:
            self.state.showWebView = true
        case .enrollWebView(let webView):
            self.webView = webView
        }
    }
    
    private func initView() {
        Task {
            do {
                async let topBannerResult = self.service.getEstateBanner()
                async let hotResult = self.service.getHotEstate()
                async let topicResult = self.service.getTodayEstateTopic()
                async let todayBannerResult = self.service.getBanner()
                
                let (bannerResponse, hotResponse, topicResponse, todayBannerResponse) = try await (topBannerResult, hotResult, topicResult, todayBannerResult)
                
                await MainActor.run {
                    self.state.EstateBannerList = bannerResponse
                    self.state.hotEstateList = hotResponse
                    self.state.todayEstateTopicList = topicResponse
                    self.state.todayEstateBannerList = todayBannerResponse
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

extension MainViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
        case "click_attendance_button":
            let accessToken = try! KeychainManager().get(tokenType: .accessToken)
            self.webView?.evaluateJavaScript ("requestAttendance('\(accessToken)')")
        case "complete_attendance":
            self.state.showWebView = false
            self.webView = nil
            
            Task {
                let msgList = String(describing: message.body).split(separator: " ").map({ String($0) })
                self.state.errorMessage = "\(msgList.last ?? "?")회차 출석체크가\n완료되었습니다!"
                self.state.showErrorAlert = true
            }
        default:
            break
        }
    }
}
