//
//  ValidationPaymentResponseDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/15/25.
//

import Foundation

struct ValidationPaymentResponseDTO: Decodable {
    let paymentID: String
    let orderItem: OrderItemDTO
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case paymentID = "payment_id"
        case orderItem = "order_item"
        case createdAt
        case updatedAt
    }
}

struct OrderItemDTO: Decodable {
    let orderID: String
    let orderCode: String
    let estate: EstateDTO
    let paidAt: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case estate
        case paidAt
        case createdAt
        case updatedAt
    }
}
