//
//  ActivateNotificationView.swift
//  CommonUI
//
//  Created by Fandy Gotama on 21/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit
import CommonUI
import L10n_swift

protocol BidRequestDialogViewDelegate: class {
    func cancelBid()
    func continueBid(price: Double?)
}

class BidRequestDialogView: UIView {

    weak var delegate: BidRequestDialogViewDelegate?

    let lblTitle: UILabel = {
        let v = UILabel()

        v.text = "booking_bid_title".l10n()
        v.font = boldH6
        v.textAlignment = .center
        v.adjustsFontSizeToFitWidth = true
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    lazy var edtPrice: CurrencyTextField = {
        let v = CurrencyTextField(defaultValue: nil)

        v.font = regularBody1
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        return v
    }()

    let lineView: UIView = {
        let v = UIView()

        v.backgroundColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    lazy var btnCancel: UIButton = {
        let v = UIButton()

        v.titleLabel?.font = regularBody1

        v.setTitle("cancel".l10n(), for: .normal)
        v.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        v.setTitleColor(UIColor.BeautyBell.gray500, for: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    lazy var btnBid: CustomButton = {
        let v = CustomButton()

        v.displayType = .primary
        v.text = "bid".l10n()

        v.titleLabel?.font = regularBody1

        v.layer.cornerRadius = 5

        v.setTitle("bid".l10n(), for: .normal)
        v.addTarget(self, action: #selector(bidTapped), for: .touchUpInside)

        v.setBackgroundColor(color: UIColor.BeautyBell.accent, forState: .normal)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true

        return v
    }()

    let blurView: BlurView = {
        let v = BlurView()

        v.alpha = 0.8

        return v
    }()

    lazy var containerView: UIView = {
        let v = UIView()

        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 5
        v.clipsToBounds = true

        v.translatesAutoresizingMaskIntoConstraints = false

        v.addSubview(lblTitle)
        v.addSubview(edtPrice)
        v.addSubview(lineView)
        v.addSubview(btnCancel)
        v.addSubview(btnBid)

        return v
    }()

    var price: Double? {
        didSet {
            edtPrice.amountPlaceholder = price
            edtPrice.amount = price
        }
    }

    var firstResponder: Bool? {
        didSet {
            guard let firstResponder = firstResponder else { return }

            if firstResponder {
                edtPrice.becomeFirstResponder()
            } else {
                edtPrice.resignFirstResponder()
            }
        }
    }

    init() {

        super.init(frame: .zero)

        self.alpha = 0.0

        self.addSubview(blurView)
        self.addSubview(containerView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        self.addGestureRecognizer(tapGesture)

        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        containerView.widthAnchor.constraint(equalToConstant: 300).isActive = true

        lblTitle.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        lblTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30).isActive = true
        lblTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true

        edtPrice.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 20).isActive = true
        edtPrice.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor).isActive = true
        edtPrice.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor).isActive = true

        lineView.leadingAnchor.constraint(equalTo: edtPrice.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: edtPrice.trailingAnchor).isActive = true
        lineView.topAnchor.constraint(equalTo: edtPrice.bottomAnchor, constant: 4).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        btnBid.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 20).isActive = true
        btnBid.leadingAnchor.constraint(equalTo: edtPrice.leadingAnchor).isActive = true
        btnBid.trailingAnchor.constraint(equalTo: edtPrice.trailingAnchor).isActive = true
        btnBid.heightAnchor.constraint(equalToConstant: 40).isActive = true

        btnCancel.topAnchor.constraint(equalTo: btnBid.bottomAnchor, constant: 10).isActive = true
        btnCancel.leadingAnchor.constraint(equalTo: edtPrice.leadingAnchor).isActive = true
        btnCancel.trailingAnchor.constraint(equalTo: edtPrice.trailingAnchor).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        containerView.bottomAnchor.constraint(equalTo: btnCancel.bottomAnchor, constant: 10).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Internal
    func show(isShow: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        if isShow {

            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.alpha = 1.0
            }, completion: { _ in
                if let finished = completion {
                    finished(true)
                }
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.alpha = 0.0
            }, completion: { _ in
                if let finished = completion {
                    finished(true)
                }
            })
        }
    }

    // MARK: - Selector
    @objc func textChanged(_ textField: UITextField) {
        btnBid.isEnabled = !(textField.text?.isEmpty == true)
    }

    @objc func hideKeyboard() {
        firstResponder = false
    }

    @objc func bidTapped() {
        firstResponder = false

        delegate?.continueBid(price: edtPrice.amount)
    }

    @objc func cancelTapped() {
        firstResponder = false

        delegate?.cancelBid()
    }
}


