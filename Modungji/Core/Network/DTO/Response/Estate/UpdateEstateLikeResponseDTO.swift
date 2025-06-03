//
//  UpdateEstateLikeResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 6/3/25.
//

import Foundation

struct UpdateEstateLikeResponseDTO: Decodable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}
