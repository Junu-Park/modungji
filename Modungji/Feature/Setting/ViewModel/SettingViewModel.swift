//
//  SettingViewModel.swift
//  Modungji
//
//  Created by 박준우 on 9/20/25.
//

import Combine
import _PhotosUI_SwiftUI
import UIKit

final class SettingViewModel: ObservableObject {
    struct State {
        var email: String = ""
        var nickname: String = ""
        var introduction: String = ""
        var profileImage: String = ""
        var phoneNumber: String = ""
        var authPlatform: AuthPlatformType = .email
        
        var editNickname: String?
        var editIntroduction: String?
        var photoSelection: [PhotosPickerItem] = []
        var editProfileImage: UIImage?
        var editPhoneNumber: String?
        
        var showSettingViewAlert: Bool = false
        var showEditViewAlert: Bool = false
        var alertMessage: String = ""
        var showProfileEdit: Bool = false
        var showPhotoPicker: Bool = false
    }
    @Published var state: State = .init()
    
    private let authState: AuthState
    private let service: SettingService
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(authState: AuthState, service: SettingService) {
        self.authState = authState
        self.service = service
        
        self.initData()
    }
    
    private func initData() {
        Task { @MainActor in
            do {
                let profile = try await self.service.getMyProfile()
                
                self.state.email = profile.email
                self.state.nickname = profile.nickname
                self.state.introduction = profile.introduction
                self.state.phoneNumber = profile.phoneNumber
                self.state.profileImage = profile.profileImage
                
                self.state.authPlatform = try self.service.getAuthPlatform()
                
            } catch let error as EstateErrorResponseEntity {
                self.state.alertMessage = error.message
                self.state.showSettingViewAlert = true
            } catch {
                self.state.alertMessage = error.localizedDescription
                self.state.showSettingViewAlert = true
            }
        }
    }
    
    private func loadPhotoFromSelection(_ selection: PhotosPickerItem) {
        Task { @MainActor in
            do {
                guard let data = try await selection.loadTransferable(type: Data.self) else {
                    throw EstateErrorResponseEntity(message: "")
                }
                
                self.state.editProfileImage = UIImage(data: data)
            } catch {
                self.state.alertMessage = "사진 불러오기 실패"
                self.state.showEditViewAlert = true
            }
        }
    }
    
    enum Action {
        case tapEdit
        case tapEditProfileImage
        case tapEditComplete
        case tapEditCancel
        case tapSignOut
    }
    
    func action(_ action: Action) {
        switch action {
        case .tapEdit:
            self.tapEdit()
        case .tapEditProfileImage:
            self.state.showPhotoPicker = true
        case .tapEditComplete:
            self.tapEditComplete()
        case .tapEditCancel:
            self.closeEdit()
        case .tapSignOut:
            self.tapSignOut()
        }
    }
    
    private func tapEdit() {
        self.$state.map(\.photoSelection)
            .dropFirst()
            .removeDuplicates(by: { fir, sec in
                if fir.isEmpty == sec.isEmpty, sec.isEmpty {
                    return true
                } else {
                    guard let firS = fir.first, let secS = sec.first else {
                        return false
                    }
                    
                    return firS.hashValue == secS.hashValue
                }
            })
            .sink { [weak self] selection in
                guard let item = selection.first else {
                    self?.state.editProfileImage = nil
                    return
                }
                
                self?.loadPhotoFromSelection(item)
            }
            .store(in: &self.cancellables)
        
        self.state.showProfileEdit = true
    }
    
    private func closeEdit() {
        Task { @MainActor in
            self.cancellables.removeAll(keepingCapacity: true)
            self.state.photoSelection.removeAll()
            self.state.editNickname = nil
            self.state.editIntroduction = nil
            self.state.editProfileImage = nil
            self.state.editPhoneNumber = nil
            
            self.state.showProfileEdit = false
        }
    }
    
    private func tapEditComplete() {
        Task { @MainActor in
            do {
                let response = try await self.service.updateMyProfile(nickname: self.state.editNickname, introduction: self.state.editIntroduction, phoneNumber: self.state.editPhoneNumber, profileImage: self.state.editProfileImage)
                
                self.state.introduction = response.introduction
                self.state.nickname = response.nickname
                self.state.phoneNumber = response.phoneNumber
                
                ImageCacheManager.shared.removeImage(urlString: self.state.profileImage)
                self.state.profileImage = response.profileImage
                
                self.closeEdit()
            } catch let error as EstateErrorResponseEntity {
                self.state.alertMessage = error.message
                self.state.showEditViewAlert = true
            } catch {
                self.state.alertMessage = error.localizedDescription
                self.state.showEditViewAlert = true
            }
        }
    }
    
    private func tapSignOut() {
        Task { @MainActor in
            do {
                try await self.service.signOut()
                
                self.authState.logout()
            } catch let error as EstateErrorResponseEntity {
                self.state.alertMessage = error.message
                self.state.showSettingViewAlert = true
            } catch {
                self.state.alertMessage = error.localizedDescription
                self.state.showSettingViewAlert = true
            }
        }
    }
}
