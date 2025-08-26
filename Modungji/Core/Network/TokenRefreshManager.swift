//
//  TokenRefreshManager.swift
//  Modungji
//
//  Created by 박준우 on 8/26/25.
//

import Foundation

import Alamofire

actor TokenRefreshManager {
    static let shared: TokenRefreshManager = .init()
    
    private var refreshTask: Task<Bool, Never>?
    
    private init() { }
    
    func requestRefreshToken() async -> Bool {
        if let currentTask = self.refreshTask {
            return await currentTask.value
        }
        
        let task = Task {
            return await self.refreshToken()
        }
        
        self.refreshTask = task
        
        defer {
            self.refreshTask = nil
        }
        
        return await task.value
    }
    
    private func refreshToken() async -> Bool {
        do {
            let response = await AF.request(EstateRouter.Auth.renewToken)
                .serializingData()
                .response
            
            guard let statusCode = response.response?.statusCode, (200...299).contains(statusCode), let data = response.data else {
                
                throw ErrorResponseDTO(message: "Retry 실패", statusCode: response.response?.statusCode)
            }
            
            let dto = try JSONDecoder().decode(RefreshResponseDTO.self, from: data)
            
            try KeychainManager().save(tokenType: .accessToken, token: dto.accessToken)
            try KeychainManager().save(tokenType: .refreshToken, token: dto.refreshToken)
            
            NetworkLog.success(url: EstateRouter.Auth.renewToken.path, statusCode: statusCode, data: data)
            
            return true
            
        } catch {
            if let error = error as? ErrorResponseDTO {
                NetworkLog.failure(url: EstateRouter.Auth.renewToken.path, statusCode: error.statusCode ?? 0, data: error)
            } else {
                NetworkLog.failure(url: EstateRouter.Auth.renewToken.path, statusCode: 0, data: ErrorResponseDTO(message: "Retry 실패"))
            }
            
            return false
        }
    }
    
    private func removeRefreshTask() {
        self.refreshTask = nil
    }
}
