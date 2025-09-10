//
//  Estate.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

import Alamofire
import ModungjiSecret

extension EstateRouter {
    enum Estate: APIRouter {
        case getEstateDetail(estateID: String)
        case updateEstateLike(estateID: String, body: UpdateEstateLikeRequestDTO)
        case getMyEstateLike(category: EstateCategory?, next: String?, limit: Int = 5)
        case getEstateWithGeo(category: EstateCategory?, longitude: Double?, latitude: Double?, maxDistance: Int?)
        case getEstateBanner
        case getHotEstate
        case getSimilarEstate
        case getTodayEstateTopic
        
        var baseURL: URL? {
            return URL(string: EstateRouter.baseURL)?.appendingPathComponent("v1/estates")
        }
        
        var path: String {
            switch self {
            case .getEstateDetail(let estateID):
                return "\(estateID)"
            case .updateEstateLike(let estateID, _):
                return "\(estateID)/like"
            case .getMyEstateLike:
                return "likes/me"
            case .getEstateWithGeo:
                return "geolocation"
            case .getEstateBanner:
                return "today-estates"
            case .getHotEstate:
                return "hot-estates"
            case .getSimilarEstate:
                return "similar-estates"
            case .getTodayEstateTopic:
                return "today-topic"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .updateEstateLike:
                return .post
            default:
                return .get
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
        
        var body: Encodable? {
            switch self {
            case .updateEstateLike(_, let dto):
                return dto
            default:
                return nil
            }
        }
        
        var queryParameters: [String : Any]? {
            var queryParam: [String : Any] = [:]
            switch self {
            case .getMyEstateLike(let category, let next, let limit):
                if let category {
                    queryParam.updateValue(category.rawValue, forKey: "category")
                }
                if let next {
                    queryParam.updateValue(next, forKey: "next")
                }
                
                queryParam.updateValue(limit, forKey: "limit")
            case .getEstateWithGeo(let category, let longitude, let latitude, let maxDistance):
                
                if let category {
                    queryParam.updateValue(category.rawValue, forKey: "category")
                }
                if let longitude {
                    queryParam.updateValue(longitude, forKey: "longitude")
                }
                if let latitude {
                    queryParam.updateValue(latitude, forKey: "latitude")
                }
                if let maxDistance {
                    queryParam.updateValue(maxDistance, forKey: "maxDistance")
                }
            default:
                return nil
            }
            return queryParam
        }
    }
}
