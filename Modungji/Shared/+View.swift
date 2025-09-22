//
//  +View.swift
//  Modungji
//
//  Created by 박준우 on 9/22/25.
//

import SwiftUI

extension View {
    var topSafeAreaPadding: CGFloat {
        var safeAreaBottom: CGFloat = 0
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
            safeAreaBottom = window.safeAreaInsets.top
        }
        
        return safeAreaBottom
    }
    
    var bottomSafeAreaPadding: CGFloat {
        var safeAreaBottom: CGFloat = 0
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
            safeAreaBottom = window.safeAreaInsets.bottom
        }
        
        return safeAreaBottom
    }
}
