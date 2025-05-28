//
//  ShapeBorderBackgroundModifier.swift
//  Modungji
//
//  Created by 박준우 on 5/28/25.
//

import SwiftUI

private struct ShapeBorderBackgroundModifier<T: InsettableShape>: ViewModifier {
    let shape: T
    let backgroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(self.borderColor, in: shape.stroke(lineWidth: self.borderWidth))
            .background(self.backgroundColor, in: shape)
    }
}

extension View {
    func shapeBorderBackground<T: InsettableShape>(
        shape: T,
        backgroundColor: Color,
        borderColor: Color,
        borderWidth: CGFloat = 1
    ) -> some View {
        modifier(
            ShapeBorderBackgroundModifier(
                shape: shape,
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                borderWidth: borderWidth
            )
        )
    }
}
