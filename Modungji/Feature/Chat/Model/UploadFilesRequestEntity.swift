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
}
