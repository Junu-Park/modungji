//
//  NetworkManager.swift
//  Modungji
//
//  Created by 박준우 on 5/11/25.
//

import Foundation

import Alamofire
import ModungjiSecret

enum ImageExtensionType: String {
    case png = "png"
    case jpeg = "jpeg"
}

struct NetworkManager {
    private let tokenRefreshManager: TokenRefreshManager = .shared
    
    /// 서버에러 -> Result<Failure>, 그 외 코드 에러  -> throw
    func requestEstate<T: Decodable>(requestURL: APIRouter, successDecodingType: T.Type) async throws -> Result<T, ErrorResponseDTO> {
        let response = await AF.request(requestURL, interceptor: self)
            .validate({ req, res, data in
                if res.statusCode == 419 {
                    return .failure(ErrorResponseDTO(message: "AccessToken is expired"))
                } else {
                    return .success(())
                }
            })
            .serializingData()
            .response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        do {
            if (200...299).contains(statusCode) {
                guard let data = response.data else {
                    let errorResponse = ErrorResponseDTO(message: "Empty Data")
                    NetworkLog.failure(url: requestURL.path, statusCode: 0, data: errorResponse)
                    return .failure(errorResponse)
                }
                
                let successResponse = try JSONDecoder().decode(T.self, from: data)
                
                NetworkLog.success(url: requestURL.path, statusCode: statusCode, data: successResponse)
                
                return .success(successResponse)
            } else {
                var errorResponse = try JSONDecoder().decode(ErrorResponseDTO.self, from: response.data!)
                errorResponse.statusCode = statusCode
                
                NetworkLog.failure(url: requestURL.path, statusCode: statusCode, data: errorResponse)
                
                return .failure(errorResponse)
            }
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func requestEstateMultiPartImage<T: Decodable>(requestURL: APIRouter, key: String, extensionType: ImageExtensionType, dataList: Data..., successDecodingType: T.Type) async throws -> Result<T, ErrorResponseDTO> {
        
        let multipartFormData = MultipartFormData()
        for data in dataList {
            multipartFormData
                .append(
                    data,
                    withName: key,
                    fileName: "\(UUID()).\(extensionType.rawValue)",
                    mimeType: "image/\(extensionType.rawValue)"
                )
        }
        
        let response = await AF.upload(multipartFormData: multipartFormData, with: requestURL, interceptor: self)
            .validate({ req, res, data in
                if res.statusCode == 419 {
                    return .failure(ErrorResponseDTO(message: "AccessToken is expired"))
                } else {
                    return .success(())
                }
            })
            .serializingData()
            .response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        do {
            if (200...299).contains(statusCode) {
                guard let data = response.data else {
                    let errorResponse = ErrorResponseDTO(message: "Empty Data")
                    NetworkLog.failure(url: requestURL.path, statusCode: 0, data: errorResponse)
                    return .failure(errorResponse)
                }
                
                let successResponse = try JSONDecoder().decode(T.self, from: data)
                
                NetworkLog.success(url: requestURL.path, statusCode: statusCode, data: successResponse)
                
                return .success(successResponse)
            } else {
                var errorResponse = try JSONDecoder().decode(ErrorResponseDTO.self, from: response.data!)
                errorResponse.statusCode = statusCode
                
                NetworkLog.failure(url: requestURL.path, statusCode: statusCode, data: errorResponse)
                
                return .failure(errorResponse)
            }
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func requestEstate(requestURL: APIRouter, isNoResponse: Bool = false) async throws -> Result<Data, ErrorResponseDTO> {
        
        let response = await AF.request(requestURL, interceptor: self)
            .validate({ req, res, data in
                if res.statusCode == 419 {
                    return .failure(ErrorResponseDTO(message: "AccessToken is expired"))
                } else {
                    return .success(())
                }
            })
            .serializingData()
            .response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        do {
            if (200...299).contains(statusCode) {
                if isNoResponse {
                    return .success(Data())
                }
                
                guard let data = response.data else {
                    let errorResponse = ErrorResponseDTO(message: "Empty Data")
                    NetworkLog.failure(url: requestURL.path, statusCode: 0, data: errorResponse)
                    return .failure(errorResponse)
                }
                
                NetworkLog.success(url: requestURL.path, statusCode: statusCode, data: data)
                
                return .success(data)
            } else {
                var errorResponse = try JSONDecoder().decode(ErrorResponseDTO.self, from: response.data!)
                errorResponse.statusCode = statusCode
                
                NetworkLog.failure(url: requestURL.path, statusCode: statusCode, data: errorResponse)
                
                return .failure(errorResponse)
            }
        } catch {
            throw NetworkError.decodingError
        }
    }
}

extension NetworkManager: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var newURLRequest = urlRequest
        
        if newURLRequest.headers.dictionary["Authorization"] != nil {
            do {
                let token = try KeychainManager().get(tokenType: .accessToken)
                
                newURLRequest.headers.update(name: "Authorization", value: token)
            } catch {
                completion(.failure(ErrorResponseDTO(message: "Authorization Token is nil")))
                return
            }
        }
        
        completion(.success(newURLRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let statusCode = request.response?.statusCode, statusCode == 419 else {
            completion(.doNotRetry)
            return
        }
        
        Task {
            let isRefreshed = await self.tokenRefreshManager.requestRefreshToken()
            
            if !isRefreshed {
                NotificationCenter.default.post(name: .expiredToken, object: nil)
            }
            completion(isRefreshed ? .retry : .doNotRetry)
        }
    }
}

extension Notification.Name {
    static let expiredToken = Self("expiredToken")
}

#if DEBUG
enum NetworkLog {
    
    private static let isPrint = true
    
    /// 네트워크 성공시 출력합니다.
    static func success<T: Decodable>(
        url: String,
        statusCode: Int,
        data: T
    ) {
        let message = """
            [✅ SUCCESS]
            - endPoint: \(url)
            - statusCode: \(statusCode)
            =====================================================
            """
        
        if isPrint {
            print(message)
            dump(data)
        }
    }
    
    /// 네트워크 로그를 출력합니다.
    static func failure<T: Decodable> (
        url: String,
        statusCode: Int,
        data: T
    ) {
        let message = """
            [❌ FAILURE]
            - endPoint: \(url)
            - statusCode: \(statusCode)
            =====================================================
            """
        
        if isPrint {
            print(message)
            dump(data)
        }
    }
}
#endif
