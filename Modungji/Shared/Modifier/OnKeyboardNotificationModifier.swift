//
//  OnKeyboardNotificationModifier.swift
//  Modungji
//
//  Created by 박준우 on 8/26/25.
//

import SwiftUI

private struct OnKeyboardNotificationModifier: ViewModifier {
    let showCallback: (CGFloat) -> ()
    let hideCallback: () -> ()
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame =
                    notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                    CGRect {
                    self.showCallback(keyboardFrame.height)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                self.hideCallback()
            }
    }
}

extension View {
    func onKeyboardNotification(showCallback: @escaping (CGFloat) -> (), hideCallback: @escaping () -> ()) -> some View {
        modifier(OnKeyboardNotificationModifier(showCallback: showCallback, hideCallback: hideCallback))
    }
}
