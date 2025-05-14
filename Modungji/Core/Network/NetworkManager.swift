//
//  NetworkManager.swift
//  Modungji
//
//  Created by 박준우 on 5/11/25.
//

import Foundation

import Alamofire

final class NetworkManager {
    
    // TODO: 토큰 Interceptor 기능 넣기
    static func requestEstate<T: Decodable>(requestURL: URLRequestConvertible, successDecodingType: T.Type) async -> Result<T, EstateErrorResponseDTO> {
        
        return await withCheckedContinuation { continuation in
            AF.request(requestURL)
                .responseData { response in
                    if let statusCode = response.response?.statusCode, let data = response.data {
                        do {
                            if (200...299).contains(statusCode) {
                                let successResponse = try JSONDecoder().decode(T.self, from: data)
                                continuation.resume(returning: .success(successResponse))
                            } else {
                                var errorResponse = try JSONDecoder().decode(EstateErrorResponseDTO.self, from: data)
                                errorResponse.statusCode = statusCode
                                continuation.resume(returning: .failure(errorResponse))
                            }
                        } catch {
                            let errorResponse = EstateErrorResponseDTO(message: "DecodingError")
                            continuation.resume(returning: .failure(errorResponse))
                        }
                    } else {
                        let errorResponse = EstateErrorResponseDTO(message: "UnknownError")
                        continuation.resume(returning: .failure(errorResponse))
                    }
                }
        }
    }
}

