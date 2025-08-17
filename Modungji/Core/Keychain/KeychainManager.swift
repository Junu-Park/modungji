//
//  KeychainManager.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation
import Security

struct KeychainManager {
    
    enum TokenType: String {
        case userID
        case accessToken
        case refreshToken
        
        var query: NSMutableDictionary {
            return [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: self.rawValue
            ]
        }
    }
    
    func save(tokenType: TokenType, token: String) throws {
        let query = tokenType.query
        
        guard let encodedToken = token.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        query[kSecValueData] = encodedToken
        
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            throw KeychainError.saveFailed
        }
    }
    
    func get(tokenType: TokenType) throws(KeychainError) -> String {
        let query = tokenType.query
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = kCFBooleanTrue
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.noDataFound
            } else {
                throw KeychainError.getFailed
            }
        }
        
        guard let data = result as? Data, let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.encodingFailed
        }
        
        return token
    }
    
    func delete(tokenType: TokenType) throws(KeychainError) {
        let query = tokenType.query
        let status = SecItemDelete(query)
        
        if status != errSecSuccess {
            throw KeychainError.deleteFailed
        }
    }
}
