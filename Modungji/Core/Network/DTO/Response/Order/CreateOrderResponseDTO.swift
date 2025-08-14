//
//  CreateOrderResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/14/25.
//

import Foundation

struct CreateOrderResponseDTO: Decodable {
    let orderID: String
    let orderCode: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt
        case updatedAt
    }
}
