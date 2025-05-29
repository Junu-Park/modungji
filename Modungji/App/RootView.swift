//
//  RootView.swift
//  Modungji
//
//  Created by 박준우 on 5/24/25.
//

import SwiftUI

import KakaoSDKAuth

struct RootView: View {
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var pathModel: PathModel
    
    var body: some View {
        NavigationStack(path: self.$pathModel.path) {
            Group {
                if self.authState.isLogin {
                    MainView()
                } else {
                    AuthView()
                        .onOpenURL { url in
                            self.handleRedirectUrl(url)
                        }
                }
            }
            .navigationDestination(for: Path.self) { path in
                path.view
            }
        }
    }
    
    private func handleRedirectUrl(_ url: URL) {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            guard AuthController.handleOpenUrl(url: url) else {
                print("유효하지 않은 리다이렉트 URL")
                return
            }
        } else {
            print("카카오톡이 아닌 다른 곳에서 리다이렉트된 URL")
        }
    }
}

extension RootView {
    @ViewBuilder
    private func tabItem(_ type: TabItemType) -> some View {
        Image(self.selectedTab == type.rawValue ? type.selectImage : type.unselectImage)
            .renderingMode(.template)
            .padding(.top, 16)
        
        Text(type.title)
            .font(PDFont.caption1)
    }
}
