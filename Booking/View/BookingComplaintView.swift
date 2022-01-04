//
//  BookingComplaintView.swift
//  Booking
//
//  Created by Reyhan Rifqi Azzami on 06/12/21.
//  Copyright © 2021 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import CommonUI

public class BookingComplaintView: UIView {
    let lblTitle: UILabel = {
        let v = UILabel()
        
        v.text = "complaint".l10n()
        v.font = regularH6
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblReason: UILabel = {
        let v = UILabel()
        
        v.text = "reason".l10n()
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var edtReason: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        return v
    }()
    
    let separatorView: SeparatorView = {
        let v = SeparatorView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public var complaint: Booking.Complaint? {
        didSet {
            guard let complaint = complaint else {
                return
            }
            edtReason.text = complaint.complaint
        }
    }
    
    public init(){
        super.init(frame: .zero)
        
        addSubview(lblTitle)
        addSubview(separatorView)
        addSubview(lblReason)
        addSubview(edtReason)
        
        layer.borderColor = UIColor.BeautyBell.gray300.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            lblTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lblTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            lblTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            separatorView.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            lblReason.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            lblReason.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            lblReason.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            
            edtReason.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            edtReason.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            edtReason.topAnchor.constraint(equalTo: lblReason.bottomAnchor, constant: 8),
            
            bottomAnchor.constraint(equalTo: edtReason.bottomAnchor, constant: 10),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
