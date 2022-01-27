//
//  BookingServiceSummaryView.swift
//  Booking
//
//  Created by Fandy Gotama on 17/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI

public class BookingServiceSummaryView: UIView {
    
    let lblServiceDetail: UILabel = {
        let v = UILabel()
        
        v.text = "service_detail".l10n()
        v.font = regularH6
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let topServiceSeparatorView: SeparatorView = {
        let v = SeparatorView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let stackView: UIStackView = {
        let v = UIStackView()
        
        v.axis = .vertical
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblTotalBookingFeesTitle: UILabel = {
        let v = UILabel()
        
        v.isSkeletonable = true
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "total_booking_fees".l10n()
        
        return v
    }()
    
    let lblTotalBookingFees: CurrencyLabel = {
        let v = CurrencyLabel()
        
        v.text = "   "
        v.isSkeletonable = true
        v.font = regularBody1
        v.textColor = UIColor.BeautyBell.accent
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.textAlignment = .right
        
        return v
    }()

    let lblPaymentStatus: UILabel = {
        let v = UILabel()

        v.text = "    "
        v.font = regularBody2
        v.isSkeletonable = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textAlignment = .right

        return v
    }()

    public var booking: Booking? {
        didSet {
            guard let booking = booking else { return }
    
//            booking.bookingServices?.forEach {
//                let v = BookingServiceView()
//                let separator = SeparatorView()
//                
//                separator.translatesAutoresizingMaskIntoConstraints = false
//                
//                v.translatesAutoresizingMaskIntoConstraints = false
//                v.service = $0
//                
//                stackView.addArrangedSubview(v)
//                stackView.addArrangedSubview(separator)
//            }
//            
//            booking.customizeRequestServices?.forEach {
//                let v = BookingServiceView()
//                let separator = SeparatorView()
//                
//                separator.translatesAutoresizingMaskIntoConstraints = false
//                
//                v.translatesAutoresizingMaskIntoConstraints = false
//                v.setCustomizeRequestService($0, notes: booking.notes)
//                
//                stackView.addArrangedSubview(v)
//                stackView.addArrangedSubview(separator)
//            }
//            
//            lblTotalBookingFees.price = booking.totalPrice
//            lblPaymentStatus.text = booking.paymentStatusName
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init() {
        super.init(frame: .zero)
    
        isSkeletonable = true
        
        addSubview(lblServiceDetail)
        addSubview(topServiceSeparatorView)
        addSubview(stackView)
        addSubview(lblTotalBookingFeesTitle)
        addSubview(lblTotalBookingFees)
        addSubview(lblPaymentStatus)

        layer.cornerRadius = 10
        layer.borderColor = UIColor.BeautyBell.gray300.cgColor
        layer.borderWidth = 1
        
        clipsToBounds = true
        
        NSLayoutConstraint.activate([
            lblServiceDetail.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lblServiceDetail.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            lblServiceDetail.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            topServiceSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topServiceSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topServiceSeparatorView.topAnchor.constraint(equalTo: lblServiceDetail.bottomAnchor, constant: 10),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topServiceSeparatorView.bottomAnchor),
            
            lblTotalBookingFeesTitle.leadingAnchor.constraint(equalTo: lblServiceDetail.leadingAnchor),
            lblTotalBookingFeesTitle.trailingAnchor.constraint(equalTo: lblServiceDetail.trailingAnchor),
            lblTotalBookingFeesTitle.centerYAnchor.constraint(equalTo: lblTotalBookingFees.centerYAnchor),
            
            lblTotalBookingFees.leadingAnchor.constraint(equalTo: lblServiceDetail.leadingAnchor),
            lblTotalBookingFees.trailingAnchor.constraint(equalTo: lblServiceDetail.trailingAnchor),
            lblTotalBookingFees.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),

            lblPaymentStatus.topAnchor.constraint(equalTo: lblTotalBookingFees.bottomAnchor, constant: 5),
            lblPaymentStatus.trailingAnchor.constraint(equalTo: lblTotalBookingFees.trailingAnchor),

            bottomAnchor.constraint(equalTo: lblPaymentStatus.bottomAnchor, constant: 10)
        ])
    }
    
}
