//
//  APIRouter.swift
//  Modungji
//
//  Created by 박준우 on 5/12/25.
//

import Foundation

import Alamofire

protocol APIRouter: URLRequestConvertible {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [String: Any]? { get }
    var body: Encodable? { get }
    var headers: HTTPHeaders { get }
}

extension APIRouter {
    func asURLRequest() throws -> URLRequest {
        
        // URL 생성
        guard let baseURL = self.baseURL else {
            throw NetworkError.invalidURL
        }
        let url = baseURL.appendingPathComponent(self.path)
        
        // URLComponent 생성
        guard var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        
        // Query Parameter 추가
        if let queryParameters = self.queryParameters, !queryParameters.isEmpty {
            urlComponent.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        // Request 생성
        guard let fullURL = urlComponent.url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: fullURL)
        
        // HTTP Method 설정
        request.httpMethod = self.method.rawValue
        
        // Header 추가
        self.headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.name)
        }
        
        // Body 추가
        if let body = self.body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError
            }
        }
        
        return request
    }
}
