//
//  OnChangeModifier.swift
//  Modungji
//
//  Created by 박준우 on 5/23/25.
//

import SwiftUI

private struct OnChangeModifier<T: Equatable>: ViewModifier {
    let value: T
    let action: (T) -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: self.value) { oldValue, newValue in
                    action(newValue)
                }
        } else {
            content
                .onChange(of: self.value) { newValue in
                    action(newValue)
                }
        }
    }
}

private struct OnOptionalChangeModifier<T: Equatable>: ViewModifier {
    let value: T?
    let action: (T?) -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: self.value) { oldValue, newValue in
                    action(newValue)
                }
        } else {
            content
                .onChange(of: self.value) { newValue in
                    action(newValue)
                }
        }
    }
}

extension View {
    func customOnChange<T: Equatable>(value: T?, action: @escaping ((T?) -> Void)) -> some View {
        self.modifier(OnOptionalChangeModifier(value: value, action: action))
    }
    func customOnChange<T: Equatable>(value: T, action: @escaping ((T) -> Void)) -> some View {
        self.modifier(OnChangeModifier(value: value, action: action))
    }
}
