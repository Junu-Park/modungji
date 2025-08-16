//
//  TabItemType.swift
//  Modungji
//
//  Created by 박준우 on 5/29/25.
//

import Foundation

enum TabItemType: Int, CaseIterable {
    case home = 0
    case map = 1
    case chat = 2
    case setting = 3
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .map:
            return "지도"
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
        case .map:
            return .map
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
        case .map:
            return .map
        case .chat:
            return .chatFill
        case .setting:
            return .settingEmpty
        }
    }
}
