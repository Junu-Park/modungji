//
//  +Int.swift
//  Modungji
//
//  Created by 박준우 on 9/12/25.
//

import Foundation

extension Int {
    func convertPriceToString() -> String {
        if self >= 1000000000000 {
            return String(self / 1000000000000) + "조"
        }
        else if self >= 100000000 {
            return String(self / 100000000) + "억"
        } else if self >= 10000 {
            return String(self / 10000) + "만"
        } else {
            return "1만↓"
        }
    }
}
