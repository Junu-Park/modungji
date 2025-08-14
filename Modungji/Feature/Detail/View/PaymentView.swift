//
//  PaymentView.swift
//  Modungji
//
//  Created by 박준우 on 8/14/25.
//

import UIKit
import SwiftUI

import iamport_ios
import ModungjiSecret

struct PaymentView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PaymentViewController
    
    @ObservedObject private var viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> PaymentViewController {
        let vc = PaymentViewController(viewModel: self.viewModel)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PaymentViewController, context: Context) { }
}

final class PaymentViewController: UIViewController {
    let viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let payment = self.viewModel.state.payment else { return }
//        Iamport.shared.useNavigationButton(enable: true)
        Iamport.shared.payment(viewController: self, userCode: ModungjiSecret.Iamport.userCode, payment: payment) { response in
            guard let response else {
                self.endPayment(errorMsg: "Iamport Response is nil")
                
                return
            }
            
            if let msg = response.error_msg, let code = response.error_code {
                self.endPayment(errorMsg: "Iamport \(code) error: \(msg)")
                
                return
            }
            
            guard let isSuccess = response.success, isSuccess else {
                self.endPayment(errorMsg: "Iamport is fail")
                
                return
            }
            
            self.viewModel.action(.paymentValidation)
        }
    }
    
    private func endPayment(errorMsg: String? = nil) {
        self.viewModel.state.showPayment = false
        self.viewModel.state.isLoading = false
        
        self.viewModel.action(.paymentValidation)
        
        if let errorMsg {
            self.viewModel.state.errorMessage = errorMsg
            self.viewModel.state.showErrorAlert = true
        }
    }
}
