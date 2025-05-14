//
//  EstateErrorResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 5/14/25.
//

import Foundation

struct EstateErrorResponseDTO: Decodable, Error {
    let message: String
    var statusCode: Int?
}
