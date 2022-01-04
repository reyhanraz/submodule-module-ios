//
//  BookingStatusLabel.swift
//  Booking
//
//  Created by Fandy Gotama on 22/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Common

public class BookingStatusLabel: PaddingLabel {
    var idleText: String?
    
    public var plainType: Bool = false{
        didSet {
            if plainType{
                plainText()
            }
        }
    }
    
    public var status: Booking.Status? {
        didSet {
            guard let status = status else { return }
            
            if status == .open {
                backgroundColor = .clear
                layer.borderColor = UIColor.BeautyBell.accent.cgColor
                layer.borderWidth = 1
                textColor = UIColor.BeautyBell.accent
            } else if status == .bid {
                backgroundColor = UIColor(red: 243/255, green: 206/255, blue: 97/255, alpha: 1)
                layer.borderColor = UIColor.clear.cgColor
                textColor = .black
            } else if status == .canceledByCustomer {
                backgroundColor = UIColor.BeautyBell.gray300
                layer.borderColor = UIColor.clear.cgColor
                textColor = UIColor.BeautyBell.gray600
            } else if status == .accepted {
                backgroundColor = UIColor.BeautyBell.accent
                layer.borderColor = UIColor.clear.cgColor
                textColor = .white
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public init() {
        super.init(frame: .zero)
        
        font = regularBody4
        leftInset = 5
        rightInset = 5
        topInset = 5
        bottomInset = 5
        layer.cornerRadius = 5
        clipsToBounds = true
        adjustsFontSizeToFitWidth = true
        textAlignment = .center
        
        widthAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    public func toggleLoading(loading: Loading) {
        if loading.start {
            idleText = text
            text = loading.text
        } else {
            text = idleText
        }
    }
    
    private func plainText(){
        backgroundColor = .clear
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
        textColor = UIColor.BeautyBell.gray600
        font = regularBody2
        adjustsFontSizeToFitWidth = false
        leftInset = 0
        rightInset = 0
        textAlignment = .right
    }
}
