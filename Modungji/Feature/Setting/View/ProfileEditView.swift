//
//  ProfileEditView.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject private var viewModel: SettingViewModel
    
    private var isEditing: Bool {
        !(self.viewModel.state.editNickname?.isEmpty ?? true) ||
        !(self.viewModel.state.editPhoneNumber?.isEmpty ?? true) ||
        !(self.viewModel.state.editIntroduction?.isEmpty ?? true) ||
        !(self.viewModel.state.editProfileImage == nil)
    }
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                VStack {
                    LabeledContent {
                        Text(self.viewModel.state.email)
                            .foregroundStyle(.gray100)
                            .font(PDFont.body1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Text("이메일")
                    }
                }
                
                self.buildProfileImageButton()
                
                self.buildTextField(title: "닉네임", placeholder: self.viewModel.state.nickname, text: .init(get: {
                    self.viewModel.state.editNickname ?? ""
                }, set: { new in
                    self.viewModel.state.editNickname = new
                }))
                
                self.buildTextField(title: "소개", placeholder: self.viewModel.state.introduction, text: .init(get: {
                    self.viewModel.state.editIntroduction ?? ""
                }, set: { new in
                    self.viewModel.state.editIntroduction = new
                }))
                
                self.buildTextField(title: "전화번호", placeholder: self.viewModel.state.phoneNumber, text: .init(get: {
                    self.viewModel.state.editPhoneNumber ?? ""
                }, set: { new in
                    self.viewModel.state.editPhoneNumber = new
                }))
                
                Spacer()
            }
            .alert(self.viewModel.state.alertMessage, isPresented: self.$viewModel.state.showEditViewAlert) {
                Button("확인") { }
            }
            .tint(.gray100)
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.viewModel.action(.tapEditCancel)
                    } label: {
                        Text("취소")
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        self.viewModel.action(.tapEditComplete)
                    } label: {
                        Text("수정")
                            .foregroundStyle(isEditing ? .deepCoast : .gray45)
                    }
                    .disabled(!isEditing)
                }
            }
            .photosPicker(isPresented: self.$viewModel.state.showPhotoPicker, selection: self.$viewModel.state.photoSelection, maxSelectionCount: 1)
        }
    }
    
    @ViewBuilder
    private func buildProfileImageButton() -> some View {
        Button {
            self.viewModel.action(.tapEditProfileImage)
        } label: {
            Group {
                if let image = self.viewModel.state.editProfileImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(.circle)
                } else {
                    URLImageView(urlString: self.viewModel.state.profileImage) {
                        Circle()
                            .fill(.deepCoast)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
                }
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(.gray100)
                    .padding(4)
                    .shapeBorderBackground(shape: .circle, backgroundColor: .gray0, borderColor: .gray100)
                    .offset(x: -5, y: 5)
            }
        }
    }
    
    @ViewBuilder
    private func buildTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        LabeledContent {
            TextField("", text: text, prompt: Text(placeholder), axis: title == "소개" ? .vertical : .horizontal)
                .keyboardType(title == "전화번호" ? .phonePad : .default)
            .padding(8)
            .frame(minWidth: 50)
            .lineLimit(1...5)
            .background(alignment: .bottom) {
                Rectangle().foregroundStyle(.gray100).frame(height: 1)
            }
        } label: {
            Text(title)
        }
    }
}
