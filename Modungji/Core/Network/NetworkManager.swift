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
    /// 서버에러 -> Result<Failure>, 그 외 코드 에러  -> throw
    static func requestEstate<T: Decodable>(requestURL: APIRouter, successDecodingType: T.Type) async throws -> Result<T, EstateErrorResponseDTO> {
        
        let response = await AF.request(requestURL)
            .serializingData()
            .response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        do {
            if (200...299).contains(statusCode) {
                let successResponse = try JSONDecoder().decode(T.self, from: response.data!)
                return .success(successResponse)
            } else {
                var errorResponse = try JSONDecoder().decode(EstateErrorResponseDTO.self, from: response.data!)
                errorResponse.statusCode = statusCode
                return .failure(errorResponse)
            }
        } catch {
            throw NetworkError.decodingError
        }
    }
}

