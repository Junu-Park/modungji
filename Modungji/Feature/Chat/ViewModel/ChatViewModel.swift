//
//  ChatViewModel.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Combine
import _PhotosUI_SwiftUI

import RealmSwift

final class ChatViewModel: ObservableObject {
    struct State {
        var showLoading: Bool = false
        
        var chatRoomData: ChatRoomResponseEntity = .init(
            roomID: "",
            createdAt: .now,
            updatedAt: .now,
            userData: .init(
                userID: "",
                nick: "",
                introduction: "",
                profileImage: ""
            ),
            opponentUserData: .init(
                userID: "",
                nick: "",
                introduction: "",
                profileImage: ""
            ),
            lastChat: nil
        )
        
        var content: String = ""
        
        var chatDataList: [ChatResponseEntity] = []
        
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
        
        var photoSelection: [PhotosPickerItem] = []
        var selectedPhoto: [UIImage] = []
        var fileSelection: [URL] = []
    }
    
    enum Action {
        case sendChat
        case removePhoto(index: Int?)
        case appendFile(urls: [URL])
        case removeFile(index: Int?)
        case tapBackButton
        case disconnectSocket
        case completeInitView
    }
    
    @Published var state: State = State()
    
    private var opponentID: String = ""
    private var roomID: String = ""
    private let service: ChatService
    private let pathModel: PathModel
    private let chatSocketManager: ChatSocketManager = .shared
    private let monitorManager: NetworkMonitorManager = .shared
    private var tempRealmChatDataList: [ChatResponseEntity] = []
    private var tempSocketChatDataList: [ChatResponseEntity] = []
    private var tempServerChatDataList: [ChatResponseEntity] = []
    private let isCompleteFetchChatData: CurrentValueSubject<Bool, Never> = .init(false)
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(opponentID: String = "", roomID: String = "", service: ChatService, pathModel: PathModel) {
        self.service = service
        self.pathModel = pathModel
        self.opponentID = opponentID
        self.state.chatRoomData.opponentUserData.userID = opponentID
        self.roomID = roomID
        self.state.chatRoomData.roomID = roomID
        
        self.chatSocketManager.delegate = self
        
        self.monitorManager.startMonitor()
        
        self.transform()
        
        self.fetchChatData()
    }
    
    private func transform() {
        self.isCompleteFetchChatData
            .dropFirst()
            .filter({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                var result: [ChatResponseEntity] = []
                result.append(contentsOf: self.tempRealmChatDataList)
                result.append(contentsOf: self.tempServerChatDataList)
                result.append(contentsOf: self.tempSocketChatDataList)
                
                self.state.chatDataList.append(contentsOf: result)
                self.state.chatDataList.sort(by: { $0.createdAt < $1.createdAt })
                
                Task {
                    try await Task.sleep(for: .seconds(0.3))
                    
                    await MainActor.run {
                        self.state.showLoading = false
                    }
                }
                
                let tempResult = self.tempServerChatDataList + self.tempSocketChatDataList
                
                if !tempResult.isEmpty {
                    Task {
                        await self.saveChatToRealm(entity: tempResult)
                    }
                }
                
                self.tempRealmChatDataList.removeAll()
                self.tempServerChatDataList.removeAll()
                self.tempSocketChatDataList.removeAll()
            }
            .store(in: &self.cancellables)
        
        // PhotoPicker 선택 변경 감지
        self.$state.map(\.photoSelection)
            .dropFirst()
            .removeDuplicates { $0.count == $1.count }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.appendPhoto()
            }
            .store(in: &self.cancellables)
        
        // 네트워크 연결 해제 감지
        self.monitorManager.$isConnected
            .dropFirst()
            .removeDuplicates()
            .filter({ $0 })
            .sink { [weak self] _ in
                self?.fetchChatData()
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Action
    func action(_ action: Action) {
        switch action {
        case .sendChat:
            self.sendChat()
        case .removePhoto(let index):
            self.removePhoto(at: index)
        case .appendFile(let urls):
            self.state.fileSelection = urls
        case .removeFile(index: let index):
            self.removeFile(at: index)
        case .disconnectSocket:
            self.disconnectSocket()
        case .tapBackButton:
            self.tapBackButton()
        case .completeInitView:
            self.state.showLoading = false
        }
    }
    
    private func fetchChatData() {
        Task {
            do {
                await MainActor.run {
                    self.state.showLoading = true
                }
                
                if self.roomID != "", let roomResponse = try await self.service.getChatRoomList().first(where: { $0.roomID == self.roomID }) {
                    await MainActor.run {
                        self.state.chatRoomData = roomResponse
                    }
                } else if self.opponentID != "" {
                    let roomResponse = try await self.service.createChatRoom(opponentID: self.opponentID)
                    await MainActor.run {
                        self.state.chatRoomData = roomResponse
                    }
                    roomID = roomResponse.roomID
                } else {
                    throw EstateErrorResponseEntity(message: "채팅방/상대방을 찾을 수 없습니다.")
                }
                
                self.tempRealmChatDataList = await self.getChatFromRealm(roomID: roomID)
                
                self.chatSocketManager.setSocket(roomID: roomID)
                self.chatSocketManager.connectSocket()
                
                let getChatRoomChatHistoryResponse = try await self.service.getChatRoomChatHistory(
                    roomID: roomID,
                    next: await self.getLastChatDateFromRealm(roomID: roomID)
                )
                
                self.tempServerChatDataList.append(contentsOf: getChatRoomChatHistoryResponse)
                
                self.isCompleteFetchChatData.send(true)
                
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.isCompleteFetchChatData.send(true)
                    self.handleError(error)
                }
            } catch {
                await MainActor.run {
                    self.tempRealmChatDataList = self.getChatFromRealm(roomID: roomID)
                    
                    self.isCompleteFetchChatData.send(true)
                }
                await self.handleError(EstateErrorResponseEntity(message: "네트워크를 확인해주세요."))
            }
        }
    }
    
    private func sendChat() {
        let tempContent = self.state.content
        
        Task {
            do {
                if self.state.chatRoomData.roomID == "" {
                    throw ErrorResponseDTO(message: "RoomID is not init")
                }
                
                await MainActor.run {
                    self.state.content = ""
                }
                
                try await self.service.postChat(roomID: self.state.chatRoomData.roomID, content: tempContent, photos: self.state.selectedPhoto, files: self.state.fileSelection)
                
                self.removePhoto(at: nil)
                
            } catch let error as EstateErrorResponseEntity {
                
                await self.handleError(error)
                
                await MainActor.run {
                    self.state.content = tempContent
                }
            } catch {
                await MainActor.run {
                    self.state.content = tempContent
                }
                await self.handleError(EstateErrorResponseEntity(message: "네트워크를 확인해주세요."))
            }
        }
    }
    
    private func appendPhoto() {
        Task {
            do {
                let uiImageList = try await withThrowingTaskGroup(of: UIImage.self) { group in
                    for photo in self.state.photoSelection {
                        group.addTask {
                            if let data = try await photo.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                                return uiImage
                            } else {
                                throw ErrorResponseDTO(message: "")
                            }
                        }
                    }
                    
                    var result: [UIImage] = []
                    
                    for try await uiImage in group {
                        result.append(uiImage)
                    }
                    
                    return result
                }
                
                await MainActor.run {
                    self.state.selectedPhoto.removeAll()
                    self.state.selectedPhoto.append(contentsOf: uiImageList)
                }
                
            } catch {
                await handleError(.init(message: "사진 첨부 실패"))
            }
        }
    }
    
    private func removePhoto(at index: Int?) {
        Task {
            await MainActor.run {
                if let index {
                    guard index < self.state.selectedPhoto.count else { return }
                    self.state.selectedPhoto.remove(at: index)
                    self.state.photoSelection.remove(at: index)
                } else {
                    self.state.selectedPhoto.removeAll()
                    self.state.photoSelection.removeAll()
                }
            }
        }
    }
    
    private func appendFile(urls: [URL]) {
        self.state.fileSelection = urls
    }
    
    private func removeFile(at index: Int?) {
        if let index {
            guard index < self.state.fileSelection.count else { return }
            self.state.fileSelection.remove(at: index)
        } else {
            self.state.fileSelection.removeAll()
        }
    }
    
    private func disconnectSocket() {
        self.chatSocketManager.disconnectSocket()
    }
    
    private func tapBackButton() {
        self.monitorManager.endMonitor()
        self.pathModel.pop()
    }
    
    @MainActor
    private func handleError(_ errorEntity: EstateErrorResponseEntity) {
        self.state.errorMessage = errorEntity.message
        self.state.showErrorAlert = true
    }
    
    // MARK: - Realm
    @MainActor
    private func getChatFromRealm(roomID: String) -> [ChatResponseEntity] {
        let realm = try! Realm()
        
        guard let chatRoom = realm.object(ofType: ChatRoomRealmDTO.self, forPrimaryKey: roomID) else {
            return []
        }
        
        if let last = self.state.chatDataList.last {
            return chatRoom.chatList.filter({ $0.date > last.createdAt }).sorted(by: { $0.date > $1.date }).map { self.convertRealmDTOToEntity($0) }
        } else {
            return chatRoom.chatList.sorted(by: \.date).map { self.convertRealmDTOToEntity($0) }
        }
    }
    
    @MainActor
    private func saveChatToRealm(entity: [ChatResponseEntity]) {
        let realm = try! Realm()
        
        try! realm.write {
            let roomDTO: ChatRoomRealmDTO
            if let existingRoom = realm.object(ofType: ChatRoomRealmDTO.self, forPrimaryKey: self.state.chatRoomData.roomID) {
                roomDTO = existingRoom
            } else {
                roomDTO = ChatRoomRealmDTO()
                roomDTO.id = self.state.chatRoomData.roomID
                roomDTO.createdDate = self.state.chatRoomData.createdAt
                roomDTO.user = self.getOrCreateUser(entity: self.state.chatRoomData.opponentUserData, in: realm)
                roomDTO.opponent = self.getOrCreateUser(entity: self.state.chatRoomData.userData, in: realm)
                realm.add(roomDTO)
            }
            
            for chatEntity in entity {
                if realm.object(ofType: ChatRealmDTO.self, forPrimaryKey: chatEntity.chatID) == nil {
                    let chatDTO = ChatRealmDTO()
                    chatDTO.id = chatEntity.chatID
                    chatDTO.content = chatEntity.content
                    chatDTO.date = chatEntity.createdAt
                    chatDTO.sender = self.getOrCreateUser(entity: chatEntity.sender, in: realm)
                    chatDTO.files.append(objectsIn: chatEntity.files)
                    
                    roomDTO.chatList.append(chatDTO)
                    
                    realm.add(chatDTO)
                }
            }
        }
    }
    
    @MainActor
    private func saveChatToRealm(entity: ChatResponseEntity) {
        let realm = try! Realm()
        
        try! realm.write {
            let roomDTO: ChatRoomRealmDTO
            if let existingRoom = realm.object(ofType: ChatRoomRealmDTO.self, forPrimaryKey: self.state.chatRoomData.roomID) {
                roomDTO = existingRoom
            } else {
                roomDTO = ChatRoomRealmDTO()
                roomDTO.id = self.state.chatRoomData.roomID
                roomDTO.createdDate = self.state.chatRoomData.createdAt
                roomDTO.user = self.getOrCreateUser(entity: self.state.chatRoomData.opponentUserData, in: realm)
                roomDTO.opponent = self.getOrCreateUser(entity: self.state.chatRoomData.userData, in: realm)
                realm.add(roomDTO)
            }
            
            if realm.object(ofType: ChatRealmDTO.self, forPrimaryKey: entity.chatID) == nil {
                let chatDTO = ChatRealmDTO()
                chatDTO.id = entity.chatID
                chatDTO.content = entity.content
                chatDTO.date = entity.createdAt
                chatDTO.sender = self.getOrCreateUser(entity: entity.sender, in: realm)
                chatDTO.files.append(objectsIn: entity.files)
                
                roomDTO.chatList.append(chatDTO)
                
                realm.add(chatDTO)
            }
        }
    }
    
    private func getOrCreateUser(entity: UserEntity, in realm: Realm) -> UserRealmDTO {
        if let existingUser = realm.object(ofType: UserRealmDTO.self, forPrimaryKey: entity.userID) {
            // 기존 사용자 정보 업데이트
            existingUser.nick = entity.nick
            existingUser.profileImage = entity.profileImage
            existingUser.introduction = entity.introduction
            return existingUser
        }
        
        let userDTO = UserRealmDTO()
        userDTO.id = entity.userID
        userDTO.nick = entity.nick
        userDTO.profileImage = entity.profileImage
        userDTO.introduction = entity.introduction
        
        realm.add(userDTO)
        return userDTO
    }
    
    @MainActor
    private func getLastChatDateFromRealm(roomID: String) -> Date? {
        let realm = try! Realm()
        return realm.object(ofType: ChatRoomRealmDTO.self, forPrimaryKey: roomID)?.updatedDate
    }
    
    // MARK: - convert
    private func convertEntityToRealmDTO(_ entity: ChatRoomResponseEntity) -> ChatRoomRealmDTO {
        let roomDTO = ChatRoomRealmDTO()
        roomDTO.id = entity.roomID
        roomDTO.createdDate = entity.createdAt
        roomDTO.user = self.convertEntityToRealmDTO(entity.opponentUserData)
        roomDTO.opponent = self.convertEntityToRealmDTO(entity.userData)
        
        return roomDTO
    }
    
    private func convertEntityToRealmDTO(_ entity: ChatResponseEntity) -> ChatRealmDTO {
        let chatDTO = ChatRealmDTO()
        chatDTO.id = entity.chatID
        chatDTO.content = entity.content
        chatDTO.sender = self.convertEntityToRealmDTO(entity.sender)
        chatDTO.date = entity.createdAt
        
        return chatDTO
    }
    
    private func convertEntityToRealmDTO(_ entity: UserEntity) -> UserRealmDTO {
        let userDTO = UserRealmDTO()
        userDTO.id = entity.userID
        userDTO.nick = entity.nick
        userDTO.profileImage = entity.profileImage
        userDTO.introduction = entity.introduction
        
        return userDTO
    }
    
    private func convertSocketDTOToEntity(_ dto: ChatSocketDTO) -> ChatResponseEntity {
        return .init(
            chatID: dto.chatID,
            roomID: dto.roomID,
            content: dto.content,
            createdAt: .iso8601StringToDate(dto.createdAt),
            updatedAt: .iso8601StringToDate(dto.updatedAt),
            sender: self.convertSocketDTOToEntity(dto.sender),
            files: dto.files
        )
    }
    
    private func convertSocketDTOToEntity(_ dto: UserSocketDTO) -> UserEntity {
        return .init(
            userID: dto.userID,
            nick: dto.nick,
            introduction: "",
            profileImage: ""
        )
    }
    
    private func convertRealmDTOToEntity(_ dto: ChatRealmDTO) -> ChatResponseEntity {
        return .init(
            chatID: dto.id,
            roomID: dto.chatRoom.first!.id,
            content: dto.content,
            createdAt: dto.date,
            updatedAt: dto.date,
            sender: self.convertRealmDTOToEntity(dto.sender!),
            files: Array(dto.files)
        )
    }
    
    private func convertRealmDTOToEntity(_ dto: UserRealmDTO) -> UserEntity {
        return .init(
            userID: dto.id,
            nick: dto.nick,
            introduction: dto.introduction,
            profileImage: dto.profileImage
        )
    }
}

extension ChatViewModel: ChatSocketDelegate {
    func didConnectSocket() {
        print(#function)
    }
    
    func didDisconnectSocket() {
        print(#function)
    }
    
    func didReceiveChat(chatData: ChatSocketDTO) {
        let entity = self.convertSocketDTOToEntity(chatData)
        
        if self.isCompleteFetchChatData.value {
            Task { @MainActor in
                self.state.chatDataList.append(entity)
                self.saveChatToRealm(entity: entity)
            }
        } else {
            self.tempSocketChatDataList.append(entity)
        }
    }
}
