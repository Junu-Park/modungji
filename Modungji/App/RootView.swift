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
    
    init() {
        setTabBarAppearance()
    }
    
    var body: some View {
        NavigationStack(path: self.$pathModel.path) {
            Group {
                if self.authState.isLogin {
                    TabView(selection: self.$pathModel.selectedTab) {
                        self.pathModel.build(.main)
                            .tabItem {
                                self.tabItem(.home)
                            }
                            .tag(0)
                        
                        self.pathModel.build(.chatRoomList)
                            .tabItem {
                                self.tabItem(.chat)
                            }
                            .tag(1)
                        
                        Text("설정")
                            .tabItem {
                                self.tabItem(.setting)
                            }
                            .tag(2)
                    }
                } else {
                    self.pathModel.build(.auth)
                        .onOpenURL { url in
                            self.handleRedirectUrl(url)
                        }
                }
            }
            .navigationDestination(for: PathType.self) { path in
                self.pathModel.build(path)
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
    
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        let font = UIFont(name: "Pretendard-Regular", size: 12)!
        
        // 선택 상태
        appearance.stackedLayoutAppearance.selected.iconColor = .gray90
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.font: font, .foregroundColor: UIColor.gray90]
        
        // 미선택 상태
        appearance.stackedLayoutAppearance.normal.iconColor = .gray45
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.font: font, .foregroundColor: UIColor.gray45]
        
        // 배경
        appearance.backgroundColor = .gray0
        
        // 경계선
        appearance.shadowColor = .separator.withAlphaComponent(0.2)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension RootView {
    @ViewBuilder
    private func tabItem(_ type: TabItemType) -> some View {
        Image(self.pathModel.selectedTab == type.rawValue ? type.selectImage : type.unselectImage)
            .renderingMode(.template)
            .padding(.top, 16)
        
        Text(type.title)
            .font(PDFont.caption1)
    }
}
