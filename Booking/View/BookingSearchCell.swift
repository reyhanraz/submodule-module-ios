//
//  SearchBookingCell.swift
//  Booking
//
//  Created by Fandy Gotama on 26/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform

public class BookingSearchCell: BaseTableViewCell {
    private let _avatarSize: CGFloat = 40
    
    public let bookingView: BookingView = {
        let v = BookingView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public func setBooking(booking: Booking, kind: NewProfile.Kind) {
        bookingView.setBooking(booking: booking, kind: kind)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        isSkeletonable = true
        
        selectionStyle = .none
        
        contentView.addSubview(bookingView)
        
        NSLayoutConstraint.activate([
            bookingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bookingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bookingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            bookingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
