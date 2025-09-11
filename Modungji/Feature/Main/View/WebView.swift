//
//  WebView.swift
//  Modungji
//
//  Created by 박준우 on 9/10/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: MainViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        /*
         이미 초기화된 WKWebView 인스턴스는 configuration 프로퍼티가 읽기 전용이 되기 때문에
         configuration의 프로퍼티 인 userContentController에 WKUserContentController 인스턴스를 적용시키는 건 불가능하다
         그래서 아래 방법을 활용하거나,
         WKWebView 이니셜라이저 중 configuration 매개변수가 있는 이니셜라이저를 활용하기
         */
        let webView = WKWebView()
        webView.configuration.userContentController.add(self.viewModel, name: "click_attendance_button")
        webView.configuration.userContentController.add(self.viewModel, name: "complete_attendance")
        self.viewModel.action(.enrollWebView(webView: webView))
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = try! EstateRouter.Banner.webView.asURLRequest()
        
        webView.load(request)
    }
}
