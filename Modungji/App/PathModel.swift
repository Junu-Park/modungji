//
//  PathModel.swift
//  Modungji
//
//  Created by 박준우 on 5/28/25.
//

import SwiftUI

final class PathModel: ObservableObject {
    @Published var path: NavigationPath = .init()
    
    func push(_ path: Path) {
        self.path.append(path)
    }
    
    func pop() {
        if !self.path.isEmpty {
            self.path.removeLast()
        }
    }
    
    func root() {
        self.path = NavigationPath()
    }
}
