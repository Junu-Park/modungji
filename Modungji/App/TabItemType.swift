//
//  TabItemType.swift
//  Modungji
//
//  Created by 박준우 on 5/29/25.
//

import Foundation

enum TabItemType: Int, CaseIterable {
    case home = 0
    case chat = 1
    case setting = 2
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .chat:
            return "채팅"
        case .setting:
            return "설정"
        }
    }
    
    var selectImage: ImageResource {
        switch self {
        case .home:
            return .homeFill
        case .chat:
            return .chatFill
        case .setting:
            return .settingFill
        }
    }
    
    var unselectImage: ImageResource {
        switch self {
        case .home:
            return .homeEmpty
        case .chat:
            return .chatEmpty
        case .setting:
            return .settingEmpty
        }
    }
}
