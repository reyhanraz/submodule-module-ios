//
//  AddressCell.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import SkeletonView
import SwipeCellKit
import Platform

public protocol AddressCellDelegate: class {
    func buttonDisclosureTapped(address: Address)
}

public class AddressCell: SwipeCollectionViewCell {

    weak var disclosureDelegate: AddressCellDelegate?
    
    let lblAddressName: UILabel = {
        let v = UILabel()
        
        v.text = "          "
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        return v
    }()
    
    let lblAddressTitle: UILabel = {
        let v = UILabel()
        
        v.text = "address".l10n()
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        return v
    }()
    
    let lblAddressDetail: UILabel = {
        let v = UILabel()
        
        v.text = "                                                      "
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        v.lineBreakMode = .byTruncatingTail
        return v
    }()
    
    let lblSubDistrictName: UILabel = {
        let v = UILabel()
        
        v.text = "                            "
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        return v
    }()
    
    let lblDistrict: UILabel = {
        let v = UILabel()
        
        v.text = "                            "
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        return v
    }()
    
    let lblPostalCode: UILabel = {
        let v = UILabel()
        
        v.text = "              "
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        return v
    }()
    
    let disclosureIndicator: DisclosureIndicator = {
        let v = DisclosureIndicator()
        
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let buttonDisclosureIndicator: DisclosureIndicator = {
        let v = DisclosureIndicator(type: .button)
        
        v.isHidden = true
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    var indicatorType: DisclosureIndicator.IndicatorType? {
        didSet {
            if indicatorType == .arrow {
                disclosureIndicator.isHidden = false
            } else if indicatorType == .button {
                buttonDisclosureIndicator.isHidden = false
            }
        }
    }
    
    var address: Address? {
        didSet {
            guard let address = address else { return }
            
            setAddress(address)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        contentView.addSubview(lblAddressName)
        contentView.addSubview(lblAddressTitle)
        contentView.addSubview(lblAddressDetail)
        contentView.addSubview(lblSubDistrictName)
        contentView.addSubview(lblDistrict)
        contentView.addSubview(lblPostalCode)
        contentView.addSubview(disclosureIndicator)
        contentView.addSubview(buttonDisclosureIndicator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(disclosureButtonTapped))
        
        buttonDisclosureIndicator.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            lblAddressName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lblAddressName.trailingAnchor.constraint(lessThanOrEqualTo: buttonDisclosureIndicator.leadingAnchor, constant: -10),
            lblAddressName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            lblAddressTitle.leadingAnchor.constraint(equalTo: lblAddressName.leadingAnchor),
            lblAddressTitle.trailingAnchor.constraint(lessThanOrEqualTo: lblAddressName.trailingAnchor),
            lblAddressTitle.topAnchor.constraint(equalTo: lblAddressName.bottomAnchor, constant: 15),
        
            lblAddressDetail.leadingAnchor.constraint(equalTo: lblAddressName.leadingAnchor),
            lblAddressDetail.trailingAnchor.constraint(lessThanOrEqualTo: lblAddressName.trailingAnchor),
            lblAddressDetail.topAnchor.constraint(equalTo: lblAddressTitle.bottomAnchor, constant: 5),
            
            lblSubDistrictName.leadingAnchor.constraint(equalTo: lblAddressName.leadingAnchor),
            lblSubDistrictName.trailingAnchor.constraint(lessThanOrEqualTo: lblAddressName.trailingAnchor),
            lblSubDistrictName.topAnchor.constraint(equalTo: lblAddressDetail.bottomAnchor, constant: 5),
            
            lblDistrict.leadingAnchor.constraint(equalTo: lblAddressName.leadingAnchor),
            lblDistrict.trailingAnchor.constraint(lessThanOrEqualTo: lblAddressName.trailingAnchor),
            lblDistrict.topAnchor.constraint(equalTo: lblSubDistrictName.bottomAnchor, constant: 5),
            
            lblPostalCode.leadingAnchor.constraint(equalTo: lblAddressName.leadingAnchor),
            lblPostalCode.trailingAnchor.constraint(lessThanOrEqualTo: lblAddressName.trailingAnchor),
            lblPostalCode.topAnchor.constraint(equalTo: lblDistrict.bottomAnchor, constant: 5),
            
            disclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            buttonDisclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            buttonDisclosureIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
    
    // MARK: - Selector
    @objc func disclosureButtonTapped() {
        guard let address = address else { return }
        
        disclosureDelegate?.buttonDisclosureTapped(address: address)
    }
    
    // MARK: - Private
    private func setAddress(_ address: Address) {
        lblAddressName.text = address.name
        lblAddressDetail.text = address.detail
//        lblSubDistrictName.text = "\(address.urbanVillageName), \(address.subDistrictName)"
//        lblDistrict.text = "\(address.districtName), \(address.provinceName)"
//        lblPostalCode.text = address.postalCode
    }
}
