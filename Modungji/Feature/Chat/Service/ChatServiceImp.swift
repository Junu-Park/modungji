//
//  ChatServiceImp.swift
//  Modungji
//
//  Created by 박준우 on 8/16/25.
//

import UIKit

struct ChatServiceImp: ChatService {
    private let repository: ChatRepository
    
    init(repository: ChatRepository) {
        self.repository = repository
    }
    
    func createChatRoom(opponentID: String) async throws -> ChatRoomResponseEntity {
        return try await self.repository.createChatRoom(opponentID: opponentID)
    }
    
    func getChatRoomChatHistory(roomID: String, next: Date?) async throws -> [ChatResponseEntity] {
        return try await self.repository.getChatRoomChatHistory(roomID: roomID, next: next)
    }
    
    func getChatRoomList() async throws -> [ChatRoomResponseEntity] {
        return try await self.repository.getChatRoomList()
    }
    
    @discardableResult func postChat(roomID: String, content: String, photos: [UIImage], files: [URL]) async throws -> ChatResponseEntity {
        let entities: [UploadFilesRequestEntity] = try await withThrowingTaskGroup(of: UploadFilesRequestEntity.self) { group in
            var results: [UploadFilesRequestEntity] = []
            
            for photo in photos {
                group.addTask {
                    guard let data = photo.convertUIImageToJPEGData(targetSize: 1000000) else {
                        throw EstateErrorResponseEntity(message: "이미지 압축 실패")
                    }
                    let type = MultipartType.jpeg
                    return UploadFilesRequestEntity(data: data, key: "files", name: "\(roomID) \(Date().toString()).\(type.rawValue)", type: type)
                }
            }
            
            for file in files {
                group.addTask {
                    guard file.startAccessingSecurityScopedResource() else {
                        throw EstateErrorResponseEntity(message: "파일 접근 실패")
                    }
                    
                    defer {
                        file.stopAccessingSecurityScopedResource()
                    }
                    
                    let data: Data
                    
                    do {
                        data = try Data(contentsOf: file)
                        if data.count > 1000000 {
                            throw EstateErrorResponseEntity(message: "1MB 파일 용량 초과")
                        }
                    } catch let error as EstateErrorResponseEntity {
                        throw error
                    } catch {
                        throw EstateErrorResponseEntity(message: "파일 변환 실패")
                    }
                    
                    let type = try file.convertURLToMultipartType()
                    
                    return UploadFilesRequestEntity(data: data, key: "files", name: "\(roomID) \(Date().toString()).\(type.rawValue)", type: type)
                }
            }
            
            for try await entity in group {
                results.append(entity)
            }
            
            return results
        }

        let uploadFilesResponse: UploadFilesResponseEntity

        if !entities.isEmpty {
            uploadFilesResponse = try await self.repository.uploadFiles(roomID: roomID, entity: entities)
        } else {
            uploadFilesResponse = .init(files: [])
        }
        
        return try await self.repository.postChat(roomID: roomID, content: content, files: uploadFilesResponse.files)
    }
}

extension UIImage {
    func convertUIImageToJPEGData(startQuality: CGFloat = 1, targetSize: Int) -> Data? {
        var compressionQuality = startQuality
        let minimumCompression = 0.1
        
        guard var jpegData = self.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        while jpegData.count > targetSize && compressionQuality > minimumCompression {
            compressionQuality -= 0.1
            if let newJPEGData = self.jpegData(compressionQuality: compressionQuality) {
                jpegData = newJPEGData
            }
        }
        
        if jpegData.count > targetSize {
            return nil
        }
        
        return jpegData
    }
}

extension URL {
    func convertURLToMultipartType() throws -> MultipartType {
        let pathExtension = self.pathExtension.lowercased()
        
        guard let type = MultipartType(rawValue: pathExtension) else {
            throw EstateErrorResponseEntity(message: "\(pathExtension)는 지원하지 않는 타입입니다.")
        }
        
        return type
    }
}
