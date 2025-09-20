//
//  UploadProfileImageResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/15/25.
//

import Foundation

struct UploadProfileImageResponseDTO: Decodable {
    let profileImage: String
    
    func convertToEntity() -> UploadProfileImageResponseEntity {
        return .init(imageURL: self.profileImage)
    }
}
