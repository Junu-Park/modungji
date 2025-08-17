//
//  Order.swift
//  Modungji
//
//  Created by 박준우 on 8/14/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum Order: APIRouter {
        case createOrder(body: CreateOrderRequestDTO)
        case getOrderHistory
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1/orders")
        }
        
        var path: String {
            return ""
        }
        
        var method: HTTPMethod {
            switch self {
            case .createOrder:
                return .post
            case .getOrderHistory:
                return .get
            }
        }
        
        var queryParameters: [String : Any]? {
            return nil
        }
        
        var body: Encodable? {
            switch self {
            case .createOrder(let dto):
                return dto
            case .getOrderHistory:
                return nil
            }
        }
        
        var headers: HTTPHeaders {
            var headers = HTTPHeaders()
            
            headers.add(name: "SeSACKey", value: ModungjiSecret.Estate.key)
            
            headers.add(name: "Content-Type", value: "application/json")
            
            do {
                let token = try KeychainManager().get(tokenType: .accessToken)
                headers.add(name: "Authorization", value: token)
            } catch {
                print(error)
            }
            
            return headers
        }
    }
}
