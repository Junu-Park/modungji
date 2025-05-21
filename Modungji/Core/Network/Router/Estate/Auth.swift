//
//  Auth.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum Auth: APIRouter {
        case renewToken
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1/auth")
        }
        
        var path: String {
            switch self {
            case .renewToken:
                return "refresh"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .renewToken:
                return .get
            }
        }
        
        var queryParameters: [String : Any]? {
            switch self {
            case .renewToken:
                return nil
            }
        }
        
        var body: Encodable? {
            switch self {
            case .renewToken:
                return nil
            }
        }
        
        var headers: HTTPHeaders {
            var headers = HTTPHeaders()
            headers.add(name: "SeSACKey", value: ModungjiSecret.Estate.key)
            
            switch self {
            case .renewToken:
                let keychainManager = KeychainManager()
                do {
                    let accessToken = try keychainManager.getToken(tokenType: .accessToken)
                    headers.add(name: "Authorization", value: accessToken)
                    
                    let refreshToken = try keychainManager.getToken(tokenType: .refreshToken)
                    headers.add(name: "RefreshToken", value: refreshToken)
                } catch {
                    // TODO: KeychainError 에러처리
                    print(error)
                }
            }
            
            return headers
        }
    }
}
