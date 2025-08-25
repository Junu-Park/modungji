//
//  ChatSocketManager.swift
//  Modungji
//
//  Created by 박준우 on 8/19/25.
//

import Foundation

import ModungjiSecret
import SocketIO

protocol ChatSocketDelegate: AnyObject {
    func didConnectSocket()
    func didDisconnectSocket()
    func didReceiveChat(chatData: ChatSocketDTO)
}

final class ChatSocketManager: ObservableObject {
    static let shared: ChatSocketManager = .init()
    
    private var manager: SocketManager!
    private weak var socket: SocketIOClient?
    weak var delegate: ChatSocketDelegate?
    
    private init() {
        self.setManager()
    }
    
    deinit {
        self.manager.disconnect()
    }
    
    private func setManager() {
        guard let url = URL(string: ModungjiSecret.Estate.baseURL) else {
            return
        }
        
        let keychainManager = KeychainManager()
        let accessToken = try? keychainManager.get(tokenType: .accessToken)
        
        guard let accessToken else {
            return
        }
        
        self.manager = SocketManager(
            socketURL: url,
            config: [
                .log(true),
                .extraHeaders(["Authorization": accessToken, "SeSACKey": ModungjiSecret.Estate.key])
            ]
        )
    }
    
    func setSocket(roomID: String) {
        self.socket = self.manager.socket(forNamespace: "/chats-\(roomID)")
        
        self.setSocketEvent()
    }
    
    private func setSocketEvent() {
        self.socket?.on(clientEvent: .connect) { [weak self] data, ack in
            guard let self else { return }
            print("Chat Socket Connect")
            self.delegate?.didConnectSocket()
        }
        
        self.socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
            guard let self else { return }
            print("Chat Socket Disconnect")
            self.delegate?.didDisconnectSocket()
        }
        
        self.socket?.on("chat") { data, ack in
            print("Chat Socket Receive")
            do {
                let chat = try self.parseChatData(data)
                print(chat)
                self.delegate?.didReceiveChat(chatData: chat)
            } catch {
                print(error)
            }
        }
    }
    
    func connectSocket() {
        self.socket?.connect()
    }
    
    func disconnectSocket() {
        self.socket?.disconnect()
        self.socket?.removeAllHandlers()
        self.socket = nil
        self.manager.disconnect()
    }
    
    private func parseChatData(_ data: [Any]) throws -> ChatSocketDTO {
        guard let chatData = data.first as? [String: Any] else { throw ErrorResponseDTO(message: "Socket Chat Data is empty") }
        
        guard let chatID = chatData["chat_id"] as? String,
              let roomID = chatData["room_id"] as? String,
              let content = chatData["content"] as? String,
              let createdAt = chatData["createdAt"] as? String,
              let updatedAt = chatData["updatedAt"] as? String,
              let sender = chatData["sender"] as? [String: Any],
              let userID = sender["user_id"] as? String,
              let nick = sender["nick"] as? String,
              let files = chatData["files"] as? [String] else {
            throw ErrorResponseDTO(message: "Socket Chat Data element is nil")
        }
        
        return .init(
            chatID: chatID,
            roomID: roomID,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt,
            files: files,
            sender: .init(nick: nick, userID: userID)
        )
    }
}

struct ChatSocketDTO {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let files: [String]
    let sender: UserSocketDTO
}

struct UserSocketDTO {
    let nick: String
    let userID: String
}
