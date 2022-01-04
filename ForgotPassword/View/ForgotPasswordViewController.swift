//
//  ForgotPasswordViewController.swift
//  BeautyBell
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit
import L10n_swift
import CommonUI
import ForgotPassword
import Platform
import Domain

protocol ForgotPasswordViewControllerDelegate: class {
    func resetPasswordDidSuccess()
    func resetPasswordCanceled()
}

class ForgotPasswordViewController: RxViewController, RegistrationViewControllerDelegate {
   
    let lblTitle: UILabel = {
        let v = UILabel()
        
        v.text = "problem_accessing_your_account".l10n()
        v.font = regularBody1
        v.textColor = .black
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblSubtitle: UILabel = {
        let v = UILabel()
        
        v.text = "forgot_password_message".l10n()
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textAlignment = .center
        v.numberOfLines = 0
        
        return v
    }()
    
    let edtEmail: FloatingLabelTextField = {
        let v = FloatingLabelTextField()
        
        v.showFloatingLabel = true
        v.setPlaceholder("email".l10n(), isCompulsory: false)
        v.setTitleLabel("email".l10n(), isCompulsory: false)
        v.edtText.keyboardType = .emailAddress
        v.edtText.returnKeyType = .next
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let btnReset: CustomButton = {
        let v = CustomButton()
        
        v.text = "reset_password".l10n()
        v.displayType = .primary
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblRegister: UILabel = {
        let v = UILabel()
        
        v.setTextWithLink(text: "does_not_have_account_register".l10n(), link: "register".l10n())
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = regularBody2
        v.textAlignment = .center
        
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        
        v.addSubview(lblTitle)
        v.addSubview(lblSubtitle)
        v.addSubview(edtEmail)
        v.addSubview(btnReset)
        v.addSubview(lblRegister)
        
        v.keyboardDismissMode = .interactive
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    weak var delegate: ForgotPasswordViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            lblTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            lblTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            lblTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 50),
            
            lblSubtitle.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            lblSubtitle.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            lblSubtitle.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 20),
            
            edtEmail.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            edtEmail.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            edtEmail.topAnchor.constraint(equalTo: lblSubtitle.bottomAnchor, constant: 50),
            
            btnReset.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            btnReset.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            btnReset.topAnchor.constraint(equalTo: edtEmail.bottomAnchor, constant: 15),
            
            lblRegister.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            lblRegister.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            lblRegister.topAnchor.constraint(equalTo: btnReset.bottomAnchor, constant: 50),
            
            // Set content size
            lblRegister.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "back".l10n(), style: .plain, target: self, action: nil)
    
        rxBinding()
    }
    
    // MARK: - Private
    private func rxBinding() {
        let service = ForgotPasswordCloudService<Status>()
        let useCase = UseCaseProvider(service: service, activityIndicator: activityIndicator)
        
        let viewModel = ForgotPasswordViewModel<Status>(
            email: edtEmail.edtText.rx.text.orEmpty.asDriver(),
            resetSignal: btnReset.rx.tap.asSignal(),
            useCase: useCase)
        
        viewModel.outputs.validatedEmail.drive().disposed(by: disposeBag)
        viewModel.outputs.loading.drive(btnReset.rx.toggleLoading).disposed(by: disposeBag)
        viewModel.outputs.resetEnabled.drive(btnReset.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.exception.drive(rx.exception).disposed(by: disposeBag)
        viewModel.outputs.reset.drive().disposed(by: disposeBag)
        viewModel.outputs.dismissResponder.drive(rx.endEditing).disposed(by: disposeBag)
        viewModel.outputs.failed.drive(rx.alert).disposed(by: disposeBag)
        
        viewModel.outputs.success.drive(onNext: { [weak self] login in
            guard let strongSelf = self else { return }
            
            let alert = UIAlertController(title: "reset_password_success".l10n(), message: "reset_password_success_message".l10n(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ok".l10n(), style: .default, handler: { [weak self] _ in
                self?.delegate?.resetPasswordDidSuccess()
            }))
            
            strongSelf.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        edtEmail.rx.controlEvent([.editingDidEndOnExit]).subscribe(onNext: { [weak self] _ in
            self?.btnReset.sendActions(for: .touchUpInside)
        }).disposed(by: disposeBag)
        
        lblRegister.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.presentRegistration()
        }).disposed(by: disposeBag)
        
        RxKeyboard.keyboardHeight()
            .subscribe(onNext: { [weak self] keyboardHeight in
                guard let strongSelf = self else { return }
                
                let height = keyboardHeight == 0 ? 0 : keyboardHeight
                
                strongSelf.scrollView.contentInset.bottom = height
                strongSelf.scrollView.scrollIndicatorInsets.bottom = height
                
                // Look for active responder, show field if hidden by keyboard
                for childView in strongSelf.scrollView.subviews {
                    if let textField = childView as? FloatingLabelTextField, textField.edtText.isFirstResponder {
                        var frame = strongSelf.scrollView.bounds
                        
                        frame.size.height -= keyboardHeight
                        
                        if !frame.contains(textField.frame) {
                            let point = CGPoint.init(x: 0.0, y: textField.frame.origin.y - keyboardHeight)
                            
                            strongSelf.scrollView.contentOffset = point
                        }
                        
                        break
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - RegistrationViewControllerDelegate
    func loginDidTap() {
        dismiss()
    }
    
    func registerDidSuccess() {
        dismiss()
    }
    
    // MARK: - Private
    private func dismiss() {
        navigationController?.popViewController(animated: true)
        
        navigationController?.transitionCoordinator?.animate(alongsideTransition: nil) { [weak self] _ in
            self?.delegate?.resetPasswordCanceled()
        }
    }
    
    private func presentRegistration() {
        let viewController = RegistrationViewController()
        
        viewController.title = "register".l10n()
        viewController.delegate = self
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
