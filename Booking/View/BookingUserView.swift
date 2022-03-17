//
//  BookingUserView.swift
//  Booking
//
//  Created by Fandy Gotama on 22/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform

protocol BookingUserViewDelegate: class {
    func viewArtisan(artisan: Artisan)
    func acceptBid(view: BookingUserView, from artisan: Artisan)
    func showContactOptions(name: String, phone: String)
}

class BookingUserView: UIView {
    private var _kind: User.Kind
    
    weak var delegate: BookingUserViewDelegate?
    
    lazy var profileView: ProfileView = {
        let v = ProfileView(kind: _kind)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()

    lazy var lblBidPrice: UILabel = {
        let v = UILabel()

        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [profileView, lblBidPrice])

        v.axis = .vertical
        v.spacing = 7
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    lazy var btnAccept: CustomButton = {
        let v = CustomButton(height: 30)
        
        v.displayType = .primaryBorderOnly
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.text = "accept".l10n()
        v.addTarget(self, action: #selector(acceptBid), for: .touchUpInside)
        
        return v
    }()
    
    lazy var btnPhone: UIButton = {
        let v = UIButton(type: .custom)
        
        v.setImage(UIImage(named: "Phone", bundle: LogoView.self), for: .normal)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.addTarget(self, action: #selector(showContactOptions), for: .touchUpInside)
        v.alpha = 0.0
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    var artisan: Artisan? {
        didSet {
            profileView.artisan = artisan
        }
    }
    
    var customer: User? {
        didSet {
            profileView.customer = customer
        }
    }
    
    var price: Decimal? {
        didSet {
            let formatter = CurrencyFormatter()
            
            guard
                let price = price,
                let priceFormatted = formatter.format(price: price)
            else { return }

            let text = "has_bid_with_amount_x".l10n(args: [priceFormatted])
            
            let attributedString = NSMutableAttributedString(string: text, attributes: [.font: regularBody3, .foregroundColor: UIColor.BeautyBell.gray500])
            let boldFontAttribute = [NSAttributedString.Key.font: mediumBody3, .foregroundColor: UIColor.BeautyBell.accent]
            
            let range = (text as NSString).range(of: priceFormatted)
            attributedString.addAttributes(boldFontAttribute, range: range)
            
            lblBidPrice.isHidden = false
            lblBidPrice.attributedText = attributedString
        }
    }
    
    var isEnabled: Bool? {
        didSet {
            btnAccept.isEnabled = isEnabled ?? false
        }
    }
    
    var accept: Bool? {
        didSet {
            guard let accept = accept else { return }
            
            btnPhone.alpha = accept ? 1.0 : 0.0
            btnAccept.alpha = accept ? 0.0 : 1.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public init(kind: User.Kind) {
        _kind = kind
        
        super.init(frame: .zero)
        
        layer.borderColor = UIColor.BeautyBell.gray300.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewArtisan))
        
        addGestureRecognizer(tapGesture)
        
        addSubview(stackView)
        addSubview(btnAccept)
        addSubview(btnPhone)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),

            btnAccept.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            btnAccept.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            btnPhone.trailingAnchor.constraint(equalTo: btnAccept.trailingAnchor),
            btnPhone.centerYAnchor.constraint(equalTo: centerYAnchor),
            btnPhone.widthAnchor.constraint(equalToConstant: 30),
        ])
        
        let phoneHeightConstraint = btnPhone.heightAnchor.constraint(equalToConstant: 30)
        
        phoneHeightConstraint.priority = UILayoutPriority(999)
        phoneHeightConstraint.isActive = true
    }
    
    // MARK: - Selector
    @objc func acceptBid(view: BookingUserView) {
        guard let artisan = artisan else { return }
        
        delegate?.acceptBid(view: self, from: artisan)
    }
    
    @objc func viewArtisan() {
        guard let artisan = artisan else { return }
        
        delegate?.viewArtisan(artisan: artisan)
    }
    
    @objc func showContactOptions() {
        if let artisan = artisan {
            guard let phone = artisan.phone else { return }
            delegate?.showContactOptions(name: artisan.name, phone: phone)
        } else if let customer = customer {
            delegate?.showContactOptions(name: customer.name, phone: customer.phone)
        }
    }
}
