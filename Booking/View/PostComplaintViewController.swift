//
//  PostComplaintViewController.swift
//  Booking
//
//  Created by Fandy Gotama on 11/01/21.
//  Copyright © 2021 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit
import CommonUI
import Platform
import Domain
import ServiceWrapper

protocol PostComplaintViewControllerDelegate: class {
    func complaintDidSend(id: Int, reason: String)
}

class PostComplaintViewController: RxViewController {
    
    weak var delegate: PostComplaintViewControllerDelegate?
    private var _viewModel: PostComplaintViewModel<Status>?
    
    private let _id: Int
    
    let lblTitle: UILabel = {
        let v = UILabel()
        
        v.text = "complain".l10n()
        v.font = boldH6
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var edtReason: LabelTextField = {
        let v = LabelTextField(
            title: "reason".l10n(),
            multiline: true,
            placeholder: "please_state_your_reason_here".l10n(),
            margins: 0,
            maxText: 300)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var btnSend: CustomButton = {
        let v = CustomButton()
        
        v.text = "send".l10n()
        v.isEnabled = false
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return v
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(id: Int) {
        _id = id
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(lblTitle)
        view.addSubview(edtReason)
        view.addSubview(btnSend)
        
        NSLayoutConstraint.activate([
            lblTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lblTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            edtReason.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            edtReason.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            edtReason.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 20),
            
            btnSend.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            btnSend.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            btnSend.topAnchor.constraint(equalTo: edtReason.bottomAnchor, constant: 20)
        ])
        
        rxBinding()
    }
    
    // MARK: - Private
    private func rxBinding() {
        let service = PostComplaintCloudService<Status>()
        let useCase = UseCaseProvider(service: service, activityIndicator: activityIndicator)
        
        let viewModel = PostComplaintViewModel<Status>(
            bookingId: _id,
            reason: (edtReason.edtTextView.textView.rx.text.orEmpty.asDriver(), 15, 300),
            useCase: useCase)
        
        viewModel.outputs.validatedReason.drive(edtReason.rx.validationResult).disposed(by: disposeBag)
        viewModel.outputs.loading.drive(btnSend.rx.toggleLoading).disposed(by: disposeBag)
        viewModel.outputs.sendEnabled.drive(btnSend.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.exception.drive(rx.exception).disposed(by: disposeBag)
        viewModel.outputs.send.drive().disposed(by: disposeBag)
        viewModel.outputs.dismissResponder.drive(rx.endEditing).disposed(by: disposeBag)
        viewModel.outputs.failed.drive(rx.alert).disposed(by: disposeBag)
        
        viewModel.outputs.success.drive(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            let alert = UIAlertController(title: "send_complaint_success".l10n(), message: "send_complaint_success_message".l10n(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ok".l10n(), style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                strongSelf.delegate?.complaintDidSend(id: strongSelf._id, reason: strongSelf.edtReason.text ?? "")
            }))
            
            strongSelf.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        _viewModel = viewModel
        
        edtReason.rx.controlEvent([.editingDidEndOnExit]).subscribe(onNext: { [weak self] _ in
            self?.btnSend.sendActions(for: .touchUpInside)
        }).disposed(by: disposeBag)
    }
    
    @objc private func sendTapped(){
        let reason = edtReason.edtTextView.textView.text ?? ""
        if reason.isEmpty{
            edtReason.toggleError(message: "complaint_reason_is_empty_validation".l10n())
        }else{
            _viewModel?.submit()
        }
    }
}
