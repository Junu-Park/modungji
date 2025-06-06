//
//  InjectDependencyModifier.swift
//  Modungji
//
//  Created by 박준우 on 5/24/25.
//

import SwiftUI

private struct InjectDependencyModifier: ViewModifier {
    let diContainer: DIContainer
    let pathModel: PathModel
    
    init(diContainer: DIContainer) {
        self.diContainer = diContainer
        self.pathModel = PathModel(diContainer: self.diContainer)
    }
    
    func body(content: Content) -> some View {
        content
            .environmentObject(self.pathModel)
            .environmentObject(self.diContainer.state.authState)
            
    }
}

extension View {
    func injectDependency(_ diContainer: DIContainer) -> some View {
        modifier(InjectDependencyModifier(diContainer: diContainer))
    }
}
