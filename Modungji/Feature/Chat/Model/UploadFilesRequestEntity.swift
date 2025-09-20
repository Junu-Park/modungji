//
//  UploadFilesRequestEntity.swift
//  Modungji
//
//  Created by 박준우 on 8/31/25.
//

import Foundation

struct UploadFilesRequestEntity {
    let data: Data
    let key: String
    let name: String
    let type: MultipartType
    
    func convertToDTO() -> UploadFilesRequestDTO {
        return .init(data: self.data, key: self.key, name: self.name, type: self.type.typeString)
    }
}
