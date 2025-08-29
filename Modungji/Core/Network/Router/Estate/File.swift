//
//  File.swift
//  Modungji
//
//  Created by 박준우 on 7/25/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum File: APIRouter {
        case file(urlString: String)
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1")
        }
        
        var path: String {
            switch self {
            case .file(let urlString):
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
                let token = try keychainManager.get(tokenType: .accessToken)
                headers.add(name: "Authorization", value: token)
            } catch {
                print(error)
            }
            
            return headers
        }
    }
}
