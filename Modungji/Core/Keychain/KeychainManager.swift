//
//  KeychainManager.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation
import Security

final class KeychainManager {
    
    enum TokenType: String {
        case accessToken
        case refreshToken
        
        var query: NSMutableDictionary {
            return [
                kSecClass: kSecClassKey,
                kSecAttrLabel: self.rawValue
            ]
        }
    }
    
    static func saveToken(tokenType: TokenType, token: String) throws(KeychainError) {
        let query = tokenType.query
        
        guard let encodedToken = token.data(using: .utf8) else {
            throw KeychainError.tokenEncodingFailed
        }
        query[kSecValueData] = encodedToken
        
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            throw KeychainError.saveTokenFailed
        }
    }
    
    static func getToken(tokenType: TokenType) throws(KeychainError) -> String {
        let query = tokenType.query
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = kCFBooleanTrue
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.noTokenFound
            } else {
                throw KeychainError.getTokenFailed
            }
        }
        
        guard let data = result as? Data, let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.tokenEncodingFailed
        }
        
        return token
    }
    
    static func deleteToken(tokenType: TokenType) throws(KeychainError) {
        let query = tokenType.query
        let status = SecItemDelete(query)
        
        if status != errSecSuccess {
            throw KeychainError.deleteTokenFailed
        }
    }
}
