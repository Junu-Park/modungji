//
//  InjectDependencyModifier.swift
//  Modungji
//
//  Created by 박준우 on 5/24/25.
//

import SwiftUI

private struct InjectDependencyModifier: ViewModifier {
    let diContainer: DIContainer
    let authState: AuthState = AuthState()
    let pathModel: PathModel = PathModel()
    
    func body(content: Content) -> some View {
        content
            .environment(\.DIContainer, self.diContainer)
            .environmentObject(self.authState)
            .environmentObject(self.pathModel)
            .environmentObject(
                AuthViewModel(
                    service: self.diContainer.service.authService,
                    authState: self.authState
                )
            )
            .environmentObject(
                AuthWithEmailViewModel(
                    service: self.diContainer.service.authService,
                    authState: self.authState
                )
            )
    }
}

extension View {
    func injectDependency(_ diContainer: DIContainer) -> some View {
        modifier(InjectDependencyModifier(diContainer: diContainer))
    }
}
