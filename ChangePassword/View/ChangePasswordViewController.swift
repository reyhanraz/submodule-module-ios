//
//  ChangePasswordViewController.swift
//  ChangePassword
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform
import Domain

public protocol ChangePasswordViewControllerDelegate: class {
    func changePasswordSuccess()
}

public class ChangePasswordViewController: RxViewController {
    
    public weak var delegate: ChangePasswordViewControllerDelegate?
    
    let edtCurrentPassword: LabelTextField = {
        let v = LabelTextField(title: "current_password".l10n(), keyboardType: .default, isSecureText: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let edtNewPassword: LabelTextField = {
        let v = LabelTextField(title: "new_password".l10n(), keyboardType: .default, isSecureText: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let edtConfirmNewPassword: LabelTextField = {
        let v = LabelTextField(title: "confirm_new_password".l10n(), keyboardType: .default, isSecureText: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let btnChangePassword: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .primary
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "change_password".l10n()
        
        return v
    }()
    
    let lblInformation: UILabel = {
        let v = UILabel()
        
        v.font = regularBody3
        v.textColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        
        v.addSubview(edtCurrentPassword)
        v.addSubview(edtNewPassword)
        v.addSubview(edtConfirmNewPassword)
        v.addSubview(btnChangePassword)
        v.addSubview(lblInformation)
        
        v.keyboardDismissMode = .interactive
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            edtCurrentPassword.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            edtCurrentPassword.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            edtCurrentPassword.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            
            edtNewPassword.leadingAnchor.constraint(equalTo: edtCurrentPassword.leadingAnchor),
            edtNewPassword.trailingAnchor.constraint(equalTo: edtCurrentPassword.trailingAnchor),
            edtNewPassword.topAnchor.constraint(equalTo: edtCurrentPassword.bottomAnchor, constant: 10),
            
            edtConfirmNewPassword.leadingAnchor.constraint(equalTo: edtCurrentPassword.leadingAnchor),
            edtConfirmNewPassword.trailingAnchor.constraint(equalTo: edtCurrentPassword.trailingAnchor),
            edtConfirmNewPassword.topAnchor.constraint(equalTo: edtNewPassword.bottomAnchor, constant: 10),
            
            lblInformation.leadingAnchor.constraint(equalTo: edtCurrentPassword.leadingAnchor, constant: 10),
            lblInformation.trailingAnchor.constraint(equalTo: edtCurrentPassword.trailingAnchor, constant: -10),
            lblInformation.topAnchor.constraint(equalTo: edtConfirmNewPassword.bottomAnchor, constant: 10),
            
            btnChangePassword.leadingAnchor.constraint(equalTo: edtCurrentPassword.leadingAnchor, constant: 10),
            btnChangePassword.trailingAnchor.constraint(equalTo: edtCurrentPassword.trailingAnchor, constant: -10),
            btnChangePassword.topAnchor.constraint(equalTo: lblInformation.bottomAnchor, constant: 30),
            
            scrollView.bottomAnchor.constraint(equalTo: btnChangePassword.bottomAnchor, constant: 10)
        ])
        
        rxBinding()
    }
    
    // MARK: - Private
    private func rxBinding() {
        let service = ChangePasswordCloudService<Status>()
        let useCase = UseCaseProvider(service: service, activityIndicator: activityIndicator)
        
        let viewModel = ChangePasswordViewModel<Status>(
            password: edtCurrentPassword.edtText.rx.text.orEmpty.asDriver(),
            newPassword: edtNewPassword.edtText.rx.text.orEmpty.asDriver(),
            newPasswordConfirmation: edtConfirmNewPassword.edtText.rx.text.orEmpty.asDriver(),
            changeSignal: btnChangePassword.rx.tap.asSignal(),
            useCase: useCase)
        
        viewModel.changeEnabled.drive(btnChangePassword.rx.isEnabled).disposed(by: disposeBag)
        viewModel.loading.drive(btnChangePassword.rx.toggleLoading).disposed(by: disposeBag)
        viewModel.dismissResponder.drive(rx.endEditing).disposed(by: disposeBag)
        viewModel.failed.drive(rx.alert).disposed(by: disposeBag)
        viewModel.exception.drive(rx.exception).disposed(by: disposeBag)
        viewModel.change.drive().disposed(by: disposeBag)
        
        viewModel.validatedNewPassword.drive(edtNewPassword.rx.validationResult).disposed(by: disposeBag)
        viewModel.validatedPasswordConfirmation.drive(edtConfirmNewPassword.rx.validationResult).disposed(by: disposeBag)
        
        viewModel.unauthorized.drive(onNext: { [weak self] _ in
            self?.showAlert(title: "update_password_failed".l10n(), message: "update_password_failed_message".l10n())
        }).disposed(by: disposeBag)
        
        viewModel.success.drive(onNext: { [weak self] _ in
            self?.showAlert(title: "update_password_success".l10n(), message: "update_password_success_message".l10n(), completion: nil) {
                self?.delegate?.changePasswordSuccess()
            }
        }).disposed(by: disposeBag)
        
        RxKeyboard.keyboardHeight()
            .subscribe(onNext: { [weak self] keyboardHeight in
                guard let strongSelf = self else { return }
                
                let height = keyboardHeight == 0 ? 0 : keyboardHeight
                
                strongSelf.scrollView.contentInset.bottom = height
                strongSelf.scrollView.scrollIndicatorInsets.bottom = height
                
                // Look for active responder, show field if hidden by keyboard
                for childView in strongSelf.scrollView.subviews {
                    if let textField = childView as? LabelTextField, textField.isFirstResponder {
                        var frame = strongSelf.scrollView.bounds
                        
                        frame.size.height -= keyboardHeight + strongSelf.scrollView.frame.origin.y
                        
                        if !frame.contains(textField.frame) {
                            let point = CGPoint.init(x: 0.0, y: textField.frame.origin.y - keyboardHeight + strongSelf.scrollView.frame.origin.y)
                            
                            strongSelf.scrollView.contentOffset = point
                        }
                        
                        break
                    }
                }
            }).disposed(by: disposeBag)
    }
}
