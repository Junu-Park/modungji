//
//  Chat.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum Chat: APIRouter {
        case createChatRoom(body: CreateChatRoomRequestDTO)
        case getChatRoomList
        case postChat(roomID: String, body: PostChatRequestDTO)
        case getChatHistory(roomID: String, next: String? = nil)
        case postFile(roomID: String)
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1/chats")
        }
        
        var path: String {
            switch self {
            case .createChatRoom:
                return ""
            case .getChatRoomList:
                return ""
            case .postChat(let roomID, _):
                return "\(roomID)"
            case .getChatHistory(let roomID, _):
                return "\(roomID)"
            case .postFile(let roomID):
                return "\(roomID)/files"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .createChatRoom:
                return .post
            case .getChatRoomList:
                return .get
            case .postChat:
                return .post
            case .getChatHistory:
                return .get
            case .postFile:
                return .post
            }
        }
        
        var queryParameters: [String : Any]? {
            switch self {
            case .getChatHistory(_, let next):
                guard let next else {
                    return nil
                }
                return ["next": next]
            default:
                return nil
            }
        }
        
        var body: Encodable? {
            switch self {
            case .createChatRoom(let body):
                return body
            case .postChat(_, let body):
                return body
            default:
                return nil
            }
        }
        
        var headers: HTTPHeaders {
            var headers = HTTPHeaders()
            
            headers.add(name: "SeSACKey", value: ModungjiSecret.Estate.key)
            
            switch self {
            case .postFile:
                headers.add(name: "Content-Type", value: "multipart/form-data")
            default:
                headers.add(name: "Content-Type", value: "application/json")
            }
            
            do {
                let token = try KeychainManager().getToken(tokenType: .accessToken)
                headers.add(name: "Authorization", value: token)
            } catch {
                print(error)
            }
            
            return headers
        }
    }
}
