//
//  SettingView.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject private var viewModel: SettingViewModel
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 1) {
            self.buildNavigationBar()
                .shapeBorderBackground(shape: .rect(cornerRadii: .init(bottomLeading: 36)), backgroundColor: .gray15, borderColor: .clear, shadowRadius: 1)
            
            VStack {
                self.buildProfileView()
                    .padding(.bottom, 12)
                
                Divider()
                
                Spacer()
            }
            .padding(20)
        }
        .ignoresSafeArea(edges: .top)
        .alert(self.viewModel.state.alertMessage, isPresented: self.$viewModel.state.showSettingViewAlert) {
            Button("확인") { }
        }
        .fullScreenCover(isPresented: self.$viewModel.state.showProfileEdit) {
            ProfileEditView(viewModel: self.viewModel)
        }
    }
    
    @ViewBuilder
    private func buildNavigationBar() -> some View {
        HStack {
            Text("설정")
                .font(PDFont.title1.bold())
            
            Spacer()
            
            Button {
                self.viewModel.action(.tapSignOut)
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .bold()
                    .fixedSize()
                    .foregroundStyle(.red.opacity(0.7))
            }
        }
        .foregroundStyle(.gray90)
        .padding(.top, self.topSafeAreaPadding)
        .padding(20)
    }
    
    @ViewBuilder
    private func buildProfileView() -> some View {
        HStack {
            URLImageView(urlString: self.viewModel.state.profileImage) {
                Circle()
                    .fill(.deepCoast)
            }
            .frame(width: 75, height: 75)
            .clipShape(.circle)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(self.viewModel.state.nickname)
                    .font(PDFont.body1)
                    .foregroundStyle(.gray100)
                
                HStack(spacing: 8) {
                    Circle()
                        .fixedSize()
                    Text("\(self.viewModel.state.authPlatform.rawValue) 로그인")
                        .font(PDFont.body2)
                        
                }
                .foregroundStyle(self.viewModel.state.authPlatform.color)
            }
            
            Spacer()
            
            Button {
                self.viewModel.action(.tapEdit)
            } label: {
                Image(systemName: "square.and.pencil")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.gray90)
            }
        }
    }
    
    @ViewBuilder
    private func buildSignOutButton() -> some View {
        Button {
            self.viewModel.action(.tapSignOut)
        } label: {
            Text("로그아웃")
                .font(PDFont.body2.bold())
                .foregroundStyle(.gray75)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .shapeBorderBackground(shape: RoundedRectangle(cornerRadius: 12), backgroundColor: .gray0, borderColor: .red.opacity(0.7))
        }
    }
}
