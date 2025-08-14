//
//  CreateOrderRequestDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/14/25.
//

import Foundation

struct CreateOrderRequestDTO: Encodable {
    let estate_id: String
    let total_price: Int
}
