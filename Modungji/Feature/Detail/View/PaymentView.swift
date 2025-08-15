//
//  PaymentView.swift
//  Modungji
//
//  Created by 박준우 on 8/14/25.
//

import WebKit
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

final class PaymentViewController: UIViewController, WKNavigationDelegate {
    let viewModel: DetailViewModel
    
    private lazy var wkWebView: WKWebView = {
        var wv = WKWebView()
        wv.backgroundColor = .clear
        
        return wv
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(wkWebView)
        view.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wkWebView.topAnchor.constraint(equalTo: view.topAnchor),
            wkWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func closeButtonTapped() {
        viewModel.action(.paymentValidation(iamportResponse: nil))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let payment = self.viewModel.state.payment else {
            return
        }
        
        Iamport.shared.paymentWebView(webViewMode: self.wkWebView, userCode: ModungjiSecret.Iamport.userCode, payment: payment) { [weak self] response in
            guard let self else {
                return
            }
            self.viewModel.action(.paymentValidation(iamportResponse: response))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeWebView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Iamport.shared.close()
    }
    
    private func removeWebView() {
        view.willRemoveSubview(wkWebView)
        wkWebView.stopLoading()
        wkWebView.removeFromSuperview()
        wkWebView.uiDelegate = nil
        wkWebView.navigationDelegate = nil
    }
}
