//
//  Map.swift
//  Modungji
//
//  Created by 박준우 on 8/7/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension NaverRouter {
    enum Map: APIRouter {
        case reverseGeocoding(coords: String)
        case geocoding(query: String)
        
        var baseURL: URL? {
            return URL(string: NaverRouter.baseURL)
        }
        
        var path: String {
            switch self {
            case .reverseGeocoding:
                return "map-reversegeocode/v2/gc"
            case .geocoding:
                return "map-geocode/v2/geocode"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            default:
                return .get
            }
        }
        
        var queryParameters: [String : Any]? {
            switch self {
            case .reverseGeocoding(let coords):
                return [
                    "coords": coords,
                    "orders": "admcode",
                    "output": "json"
                ]
            case .geocoding(let query):
                return ["query": query]
            }
        }
        
        var body: Encodable? {
            switch self {
            default:
                return nil
            }
        }
        
        var headers: HTTPHeaders {
            var headers = HTTPHeaders()
            
            headers.add(name: "x-ncp-apigw-api-key-id", value: ModungjiSecret.Naver.clientID)
            
            headers.add(name: "x-ncp-apigw-api-key", value: ModungjiSecret.Naver.key)
            
            return headers
        }
    }
}
