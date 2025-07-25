//
//  Image.swift
//  Modungji
//
//  Created by 박준우 on 7/25/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum Image: APIRouter {
        case image(urlString: String)
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1")
        }
        
        var path: String {
            switch self {
            case .image(let urlString):
                return urlString
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
                let token = try keychainManager.getToken(tokenType: .accessToken)
                headers.add(name: "Authorization", value: token)
            } catch {
                print(error)
            }
            
            return headers
        }
    }
}
