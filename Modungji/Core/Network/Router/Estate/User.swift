//
//  User.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum User: APIRouter {
        case validateEmail(body: ValidateEmailRequestDTO)
        case join(body: JoinRequestDTO)
        case loginWithEmail(body: LoginWithEmailRequestDTO)
        case loginWithKakao(body: LoginWithKakaoRequestDTO)
        case loginWithApple(body: LoginWithAppleRequestDTO)
        case updateDeviceToken(body: UpdateDeviceTokenRequestDTO)
        case getOtherProfile(userId: String)
        case getMyProfile
        case updateMyProfile(body: UpdateMyProfileRequestDTO)
        case uploadProfileImage
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1/users")
        }
        
        var path: String {
            switch self {
            case .validateEmail:
                return "validation/email"
            case .join:
                return "join"
            case .loginWithEmail:
                return "login"
            case .loginWithKakao:
                return "login/kakao"
            case .loginWithApple:
                return "login/apple"
            case .updateDeviceToken:
                return "deviceToken"
            case .getOtherProfile(let userId):
                return "\(userId)/profile"
            case .getMyProfile:
                return "me/profile"
            case .updateMyProfile:
                return "me/profile"
            case .uploadProfileImage:
                return "profile/image"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .validateEmail, .join, .loginWithEmail, .loginWithKakao, .loginWithApple, .uploadProfileImage:
                return .post
            case .updateDeviceToken, .updateMyProfile:
                return .put
            case .getOtherProfile, .getMyProfile:
                return .get
            }
        }
        
        var queryParameters: [String : Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var body: Encodable? {
            switch self {
            case .validateEmail(let dto):
                return dto
            case .join(let dto):
                return dto
            case .loginWithEmail(let dto):
                return dto
            case .loginWithKakao(let dto):
                return dto
            case .loginWithApple(let dto):
                return dto
            case .updateDeviceToken(let dto):
                return dto
            case .updateMyProfile(let dto):
                return dto
            case .getOtherProfile, .getMyProfile, .uploadProfileImage:
                return nil
            }
        }
        
        var headers: HTTPHeaders {
            var headers = HTTPHeaders()
            headers.add(name: "SeSACKey", value: ModungjiSecret.Estate.key)
            
            switch self.method {
            case .post, .put:
                headers.add(name: "Content-Type", value: "application/json")
            default:
                break
            }
            
            let keychainManager = KeychainManager()
            
            switch self {
            case .updateDeviceToken, .getOtherProfile, .getMyProfile,
                    .updateMyProfile:
                do {
                    let token = try keychainManager.getToken(tokenType: .accessToken)
                    headers.add(name: "Authorization", value: token)
                } catch {
                    // TODO: KeychainError 에러처리
                    print(error)
                }
            case .uploadProfileImage:
                do {
                    let token = try keychainManager.getToken(tokenType: .accessToken)
                    headers.add(name: "Authorization", value: token)
                } catch {
                    // TODO: KeychainError 에러처리
                    print(error)
                }
                headers.update(name: "Content-Type", value: "multipart/form-data")
            default:
                break
            }
            
            return headers
        }
    }
}
