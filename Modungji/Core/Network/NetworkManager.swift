//
//  NetworkManager.swift
//  Modungji
//
//  Created by 박준우 on 5/11/25.
//

import Foundation

import Alamofire

struct NetworkManager {
    
    // TODO: 토큰 Interceptor 기능 넣기
    /// 서버에러 -> Result<Failure>, 그 외 코드 에러  -> throw
    func requestEstate<T: Decodable>(requestURL: APIRouter, successDecodingType: T.Type) async throws -> Result<T, ErrorResponseDTO> {
        
        let response = await AF.request(requestURL)
            .serializingData()
            .response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        do {
            if (200...299).contains(statusCode) {
                let successResponse = try JSONDecoder().decode(T.self, from: response.data!)
                
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
    
    func requestEstateMultiPart<T: Decodable>(requestURL: APIRouter, imageData: Data, successDecodingType: T.Type) async throws -> Result<T, ErrorResponseDTO> {
        
        let multipartFormData = MultipartFormData()
        multipartFormData.append(imageData, withName: "profileImage.png")
        
        let response = await AF.upload(multipartFormData: multipartFormData, with: requestURL)
            .serializingData()
            .response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        do {
            if (200...299).contains(statusCode) {
                let successResponse = try JSONDecoder().decode(T.self, from: response.data!)
                
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
}

#if DEBUG
private enum NetworkLog {
    
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
