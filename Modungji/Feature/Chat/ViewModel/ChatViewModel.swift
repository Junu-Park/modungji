//
//  ChatViewModel.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Combine
import Foundation

import RealmSwift

final class ChatViewModel: ObservableObject {
    struct State {
        var isLoadingData: Bool = false
        
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
        var files: [String] = []
        
        var chatDataList: [ChatResponseEntity] = []
        
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case initView
        case sendChat
        case appendImage
        case disconnectSocket
    }
    
    @Published var state: State = State()
    
    private let opponentID: String
    private let service: ChatService
    private let chatSocketManager: ChatSocketManager = .shared
    private var tempRealmChatDataList: [ChatResponseEntity] = []
    private var tempSocketChatDataList: [ChatResponseEntity] = []
    private var tempServerChatDataList: [ChatResponseEntity] = []
    private var cancellables: Set<AnyCancellable> = .init()
    
    init(opponentID: String, chatRoomData: ChatRoomResponseEntity? = nil, service: ChatService) {
        self.service = service
        self.opponentID = opponentID
        self.state.chatRoomData = chatRoomData ?? .init(
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
        
        self.transform()
        
        self.initView()
        
        self.chatSocketManager.delegate = self
    }
    
    private func transform() {
        self.$state.map(\.isLoadingData)
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                if !value {
                    var allChats: [ChatResponseEntity] = []
                    allChats.append(contentsOf: self.tempRealmChatDataList)
                    allChats.append(contentsOf: self.tempServerChatDataList)
                    allChats.append(contentsOf: self.tempSocketChatDataList)
                    
                    let uniqueChats = Dictionary(grouping: allChats, by: \.chatID)
                        .compactMap { $0.value.first }
                        .sorted { $0.createdAt < $1.createdAt }
                    
                    self.state.chatDataList = uniqueChats
                    
                    let newChats = self.tempServerChatDataList + self.tempSocketChatDataList
                    if !newChats.isEmpty {
                        Task {
                            await self.saveChatToRealm(entity: newChats)
                        }
                    }
                    
                    self.tempRealmChatDataList.removeAll()
                    self.tempServerChatDataList.removeAll()
                    self.tempSocketChatDataList.removeAll()
                }
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Action
    func action(_ action: Action) {
        switch action {
        case .initView:
            self.initView()
        case .sendChat:
            self.sendChat()
        case .appendImage:
            print("appendImage")
        case .disconnectSocket:
            self.disconnectSocket()
        }
    }
    
    private func initView() {
        Task {
            do {
                let roomID: String
                
                if self.state.chatRoomData.roomID != "" {
                    roomID = self.state.chatRoomData.roomID
                } else {
                    let createChatRoomResponse = try await self.service.createChatRoom(opponentID: self.opponentID)
                    await MainActor.run {
                        self.state.chatRoomData = createChatRoomResponse
                    }
                    roomID = createChatRoomResponse.roomID
                }
                
                await MainActor.run {
                    self.state.isLoadingData = true
                }
                
                self.tempRealmChatDataList = await self.getChatFromRealm(roomID: roomID)
                
                self.chatSocketManager.setSocket(roomID: roomID)
                self.chatSocketManager.connectSocket()
                
                let getChatRoomChatHistoryResponse = try await self.service.getChatRoomChatHistory(
                    roomID: roomID,
                    next: await self.getLastChatDateFromRealm(roomID: roomID)
                )
                
                self.tempServerChatDataList.append(contentsOf: getChatRoomChatHistoryResponse)
                await MainActor.run {
                    self.state.isLoadingData = false
                }
                
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.isLoadingData = false
                    self.handleError(error)
                }
            } catch {
                await MainActor.run {
                    self.state.isLoadingData = false
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
                
                try await self.service.postChat(roomID: self.state.chatRoomData.roomID, content: tempContent, files: [])
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
    
    private func disconnectSocket() {
        self.chatSocketManager.disconnectSocket()
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
        
        return chatRoom.chatList
            .sorted(by: \.date)
            .map { self.convertRealmDTOToEntity($0) }
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
        
        if self.state.isLoadingData {
            self.tempSocketChatDataList.append(entity)
        } else {
            Task { @MainActor in
                self.state.chatDataList.append(entity)
                self.saveChatToRealm(entity: entity)
            }
        }
    }
}
