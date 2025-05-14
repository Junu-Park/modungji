//
//  NetworkError.swift
//  Modungji
//
//  Created by 박준우 on 5/11/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case encodingError
}
