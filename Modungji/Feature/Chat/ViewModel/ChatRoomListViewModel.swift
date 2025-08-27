//
//  ChatRoomListViewModel.swift
//  Modungji
//
//  Created by 박준우 on 8/18/25.
//

import Foundation

import RealmSwift

final class ChatRoomListViewModel: ObservableObject {
    struct State {
        var chatRoomList: [ChatRoomResponseEntity] = []
        
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case fetchChatRoomList
        case tapChatRoom(opponentID: String, roomID: String)
    }
    
    @Published var state: State = State()
    private let service: ChatService
    private let pathModel: PathModel
    
    init(service: ChatService, pathModel: PathModel) {
        self.service = service
        self.pathModel = pathModel
        
        self.action(.fetchChatRoomList)
    }
    
    func action(_ action: Action) {
        switch action {
        case .tapChatRoom(let opponentID, let roomID):
            self.pathModel.push(.chat(opponentID: opponentID, roomID: roomID))
        case .fetchChatRoomList:
            self.fetchChatRoomList()
        }
    }
    
    private func fetchChatRoomList() {
        Task {
            do {
                let response = try await self.service.getChatRoomList()
                
                await MainActor.run {
                    self.state.chatRoomList = response
                }
                
                self.saveChatRoomToRealm(response)
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.chatRoomList = self.getChatRoomFromRealm()
                    
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            } catch {
                await MainActor.run {
                    self.state.chatRoomList = self.getChatRoomFromRealm()
                    
                    self.state.errorMessage = error.localizedDescription
                    self.state.showErrorAlert = true
                }
            }
        }
    }
    
    private func getChatRoomFromRealm() -> [ChatRoomResponseEntity] {
        let realm = try! Realm()
        
        return realm.objects(ChatRoomRealmDTO.self).map { self.convertRealmDTOToEntity($0) }
    }
    
    private func saveChatRoomToRealm(_ entities: [ChatRoomResponseEntity]) {
        let realm = try! Realm()
        
        try! realm.write {
            for entity in entities {
                if realm.object(ofType: ChatRoomRealmDTO.self, forPrimaryKey: entity.roomID) != nil {
                    let userDTO = convertEntityToRealmDTO(entity.userData)
                    let opponentDTO = convertEntityToRealmDTO(entity.opponentUserData)
                                    
                    realm.add(userDTO, update: .modified)
                    realm.add(opponentDTO, update: .modified)
                } else {
                    realm.add(self.convertEntityToRealmDTO(entity), update: .modified)
                }
            }
        }
    }
    
    private func convertRealmDTOToEntity(_ dto: ChatRoomRealmDTO) -> ChatRoomResponseEntity {
        return .init(
            roomID: dto.id,
            createdAt: dto.createdDate,
            updatedAt: dto.updatedDate,
            userData: self.convertRealmDTOToEntity(dto.user!),
            opponentUserData: self.convertRealmDTOToEntity(dto.opponent!),
            lastChat: {
                guard let lastChat = dto.lastChat else {
                    return nil
                }
                
                return .init(
                    chatID: lastChat.id,
                    roomID: dto.id,
                    content: lastChat.content,
                    createdAt: lastChat.date,
                    updatedAt: lastChat.date,
                    sender: self.convertRealmDTOToEntity(lastChat.sender!),
                    files: Array(lastChat.files)
                )
            }()
        )
    }
    
    private func convertEntityToRealmDTO(_ entity: ChatRoomResponseEntity) -> ChatRoomRealmDTO {
        let roomDTO = ChatRoomRealmDTO()
        roomDTO.id = entity.roomID
        roomDTO.createdDate = entity.createdAt
        roomDTO.user = self.convertEntityToRealmDTO(entity.userData)
        roomDTO.opponent = self.convertEntityToRealmDTO(entity.opponentUserData)
        
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
    
    private func convertRealmDTOToEntity(_ dto: UserRealmDTO) -> UserEntity {
        return .init(
            userID: dto.id,
            nick: dto.nick,
            introduction: dto.introduction,
            profileImage: dto.profileImage
        )
    }
}
