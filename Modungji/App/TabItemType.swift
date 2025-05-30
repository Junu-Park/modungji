//
//  TabItemType.swift
//  Modungji
//
//  Created by 박준우 on 5/29/25.
//

import Foundation

enum TabItemType: Int, CaseIterable {
    case home = 0
    case interestEstate = 1
    case setting = 2
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .interestEstate:
            return "관심매물"
        case .setting:
            return "설정"
        }
    }
    
    var selectImage: ImageResource {
        switch self {
        case .home:
            return .homeFill
        case .interestEstate:
            return .interestFill
        case .setting:
            return .settingFill
        }
    }
    
    var unselectImage: ImageResource {
        switch self {
        case .home:
            return .homeEmpty
        case .interestEstate:
            return .interestEmpty
        case .setting:
            return .settingEmpty
        }
    }
}
