//
//  Path.swift
//  Modungji
//
//  Created by 박준우 on 5/28/25.
//

import SwiftUI

enum Path: Hashable {
    case auth
    case authWithEmail(authType: AuthWithEmailType)
    case main
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .auth:
            AuthView()
        case .authWithEmail(let authType):
            AuthWithEmailView(authType: authType)
        case .main:
            MainView()
        }
    }
}
