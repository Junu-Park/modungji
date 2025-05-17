//
//  Fonts.swift
//  Modungji
//
//  Created by 박준우 on 5/11/25.
//

import SwiftUI

/// Pretendard 폰트
enum PDFont {
    static var title1: Font {
        return .custom("Pretendard-Bold", fixedSize: 20)
    }
    static var body1: Font {
        return .custom("Pretendard-Medium", fixedSize: 16)
    }
    static var body2: Font {
        return .custom("Pretendard-Medium", fixedSize: 14)
    }
    static var body3: Font {
        return .custom("Pretendard-Medium", fixedSize: 13)
    }
    static var caption1: Font {
        return .custom("Pretendard-Regular", fixedSize: 12)
    }
    static var caption2: Font {
        return .custom("Pretendard-Regular", fixedSize: 10)
    }
    static var caption3: Font {
        return .custom("Pretendard-Regular", fixedSize: 8)
    }
}
