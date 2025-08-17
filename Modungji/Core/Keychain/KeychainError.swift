//
//  KeychainError.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

enum KeychainError: Error {
    case encodingFailed
    case saveFailed
    case noDataFound
    case getFailed
    case deleteFailed
}
