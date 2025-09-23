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
                    VStack(spacing: 0) {
                        TabView(selection: self.$pathModel.selectedTab) {
                            self.pathModel.build(.main)
                                .tag(0)
                                
                            self.pathModel.build(.chatRoomList)
                                .tag(1)
                            
                            self.pathModel.build(.setting)
                                .tag(2)
                        }
                        
                        self.buildCustomTabBar()
                            .shapeBorderBackground(shape: .rect(cornerRadii: .init(topLeading: 28, topTrailing: 28)), backgroundColor: .gray15, borderColor: .clear, shadowRadius: 1)
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .background(.gray0)
                } else {
                    self.pathModel.build(.auth)
                        .onOpenURL { url in
                            self.handleRedirectUrl(url)
                        }
                        .onAppear {
                            self.pathModel.selectedTab = 0
                        }
                }
            }
            .navigationDestination(for: PathType.self) { path in
                self.pathModel.build(path)
            }
        }
        .onAppear {
            self.pathModel.authWithAuto()
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
        UITabBar.appearance().isHidden = true
    }
}

extension RootView {
    @ViewBuilder
    private func buildCustomTabBar() -> some View {
        HStack {
            Spacer()
            self.tabItem(.home)
            Spacer()
            self.tabItem(.chat)
            Spacer()
            self.tabItem(.setting)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, self.bottomSafeAreaPadding)
    }
    
    @ViewBuilder
    private func tabItem(_ type: TabItemType) -> some View {
        Button {
            self.pathModel.selectedTab = type.rawValue
        } label: {
            VStack(spacing: 4) {
                Image(self.pathModel.selectedTab == type.rawValue ? type.selectImage : type.unselectImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                
                Text(type.title)
                    .font(PDFont.caption1)
            }
            .foregroundStyle(self.pathModel.selectedTab == type.rawValue ? .gray90 : .gray45)
            .padding(.vertical, 4)
            .padding(.horizontal, 28)
        }
    }
}
