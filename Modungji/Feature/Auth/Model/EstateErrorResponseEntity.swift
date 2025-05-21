//
//  EstateErrorResponseEntity.swift
//  Modungji
//
//  Created by 박준우 on 5/19/25.
//

import Foundation

struct EstateErrorResponseEntity: Error {
    let message: String
    var statusCode: Int?
}
