//
//  +UINavigationController.swift
//  Modungji
//
//  Created by 박준우 on 8/31/25.
//

import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeBackGesture()
    }
    
    private func setupSwipeBackGesture() {
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Root view controller가 아닐 때만 swipe back 허용
        guard viewControllers.count > 1 else { return false }
        
        // 현재 push/pop 애니메이션이 진행 중이면 비활성화
        guard !isBeingPresented && !isBeingDismissed else { return false }
        
        return true
    }
}
