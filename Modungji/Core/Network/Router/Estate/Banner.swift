//
//  Banner.swift
//  Modungji
//
//  Created by 박준우 on 9/10/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum Banner: APIRouter {
        case banner
        case webView
        
        var baseURL: URL? {
            switch self {
            case .banner:
                return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1")
            case .webView:
                return URL(string: EstateRouter.baseURL)
            }
        }
        
        var path: String {
            switch self {
            case .banner:
                return "banners/main"
            case .webView:
                return "event-application"
            }
        }
        
        var method: HTTPMethod {
            return .get
        }
        
        var queryParameters: [String : Any]? {
            return nil
        }
        
        var body: Encodable? {
            return nil
        }
        
        var headers: HTTPHeaders {
            var headers = HTTPHeaders()
            headers.add(name: "SeSACKey", value: ModungjiSecret.Estate.key)
            
            let keychainManager = KeychainManager()
            
            do {
                let token = try keychainManager.get(tokenType: .accessToken)
                headers.add(name: "Authorization", value: token)
            } catch {
                print(error)
            }
            
            return headers
        }
    }
}
