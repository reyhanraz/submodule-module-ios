//
//  BookingServiceView.swift
//  Booking
//
//  Created by Fandy Gotama on 31/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI

public class BookingServiceView: UIView {
    
    let lblServiceType: TwoColumnsView = {
        let v = TwoColumnsView(title: "service_type".l10n(), font: regularBody2, equalWidth: false)
    
        v.translatesAutoresizingMaskIntoConstraints = false
        v.lblText.textAlignment = .right
        
        return v
    }()
    
    let lblQuantity: TwoColumnsView = {
        let v = TwoColumnsView(title: "quantity".l10n(), font: regularBody2, equalWidth: false)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.lblText.textAlignment = .right
        
        return v
    }()
    
    let lblServiceFeeTitle: UILabel = {
        let v = UILabel()
        
        v.text = "service_fee".l10n()
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblServiceFee: CurrencyLabel = {
        let v = CurrencyLabel()
        
        v.font = regularBody2
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textAlignment = .right
        
        return v
    }()
    
    let lblNotesTitle: UILabel = {
        let v = UILabel()
        
        v.text = "note".l10n()
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblNotes: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        
        return v
    }()
    
    let noteSeparator: SeparatorView = {
        let v = SeparatorView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    public var service: Booking.BookingService? {
        didSet {
            guard let service = service else { return }
            
            setService(service)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init() {
        super.init(frame: .zero)
        
        addSubview(lblServiceType)
        addSubview(lblQuantity)
        addSubview(lblServiceFeeTitle)
        addSubview(lblServiceFee)
        addSubview(noteSeparator)
        addSubview(lblNotesTitle)
        addSubview(lblNotes)
        
        NSLayoutConstraint.activate([
            lblServiceType.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lblServiceType.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            lblServiceType.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            lblQuantity.leadingAnchor.constraint(equalTo: lblServiceType.leadingAnchor),
            lblQuantity.trailingAnchor.constraint(equalTo: lblServiceType.trailingAnchor),
            lblQuantity.topAnchor.constraint(equalTo: lblServiceType.bottomAnchor, constant: 5),
            
            lblServiceFeeTitle.leadingAnchor.constraint(equalTo: lblServiceType.leadingAnchor),
            lblServiceFeeTitle.trailingAnchor.constraint(equalTo: lblServiceType.trailingAnchor),
            lblServiceFeeTitle.topAnchor.constraint(equalTo: lblQuantity.bottomAnchor, constant: 5),
            
            lblServiceFee.leadingAnchor.constraint(equalTo: lblServiceType.leadingAnchor),
            lblServiceFee.trailingAnchor.constraint(equalTo: lblServiceType.trailingAnchor),
            lblServiceFee.topAnchor.constraint(equalTo: lblServiceFeeTitle.topAnchor),
            
            noteSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            noteSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            noteSeparator.topAnchor.constraint(equalTo: lblServiceFeeTitle.bottomAnchor, constant: 10),
            
            lblNotesTitle.leadingAnchor.constraint(equalTo: lblServiceType.leadingAnchor),
            lblNotesTitle.trailingAnchor.constraint(equalTo: lblServiceType.trailingAnchor),
            lblNotesTitle.topAnchor.constraint(equalTo: noteSeparator.bottomAnchor, constant: 10),
            
            lblNotes.leadingAnchor.constraint(equalTo: lblServiceType.leadingAnchor),
            lblNotes.trailingAnchor.constraint(equalTo: lblServiceType.trailingAnchor),
            lblNotes.topAnchor.constraint(equalTo: lblNotesTitle.bottomAnchor, constant: 5),
            
            bottomAnchor.constraint(equalTo: lblNotes.bottomAnchor, constant: 10)
        ])
    }
    
    private func setService(_ service: Booking.BookingService) {
        lblServiceType.text = service.title
        lblQuantity.text = "x_pax".l10n(args: [service.quantity])
        lblServiceFee.price = service.price
        lblNotes.text = service.notes
    }
    
    public func setCustomizeRequestService(_ service: Booking.CustomizeRequestService, notes: String?) {
        lblServiceType.text = service.title
        lblQuantity.text = "x_pax".l10n(args: [service.quantity])
        lblServiceFee.price = service.price
        lblNotes.text = notes
    }
}
