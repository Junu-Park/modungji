//
//  KeychainError.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

enum KeychainError: Error {
    case tokenEncodingFailed
    case saveTokenFailed
    case noTokenFound
    case getTokenFailed
    case deleteTokenFailed
}
