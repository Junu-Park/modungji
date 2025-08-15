//
//  Payment.swift
//  Modungji
//
//  Created by 박준우 on 8/15/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum Payment: APIRouter {
        case validatePayment(body: ValidationPaymentRequestDTO)
        case getPaymentReceipt(orderCode: String)
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1/payments")
        }
        
        var path: String {
            switch self {
            case .validatePayment:
                return ""
            case .getPaymentReceipt(let orderCode):
                return "\(orderCode)"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .validatePayment:
                return .post
            case .getPaymentReceipt(let orderCode):
                return .get
            }
        }
        
        var queryParameters: [String : Any]? {
            return nil
        }
        
        var body: Encodable? {
            switch self {
            case .validatePayment(let body):
                return body
            case .getPaymentReceipt:
                return nil
            }
        }
        
        var headers: HTTPHeaders {
            var headers = HTTPHeaders()
            
            headers.add(name: "SeSACKey", value: ModungjiSecret.Estate.key)
            
            headers.add(name: "Content-Type", value: "application/json")
            
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
