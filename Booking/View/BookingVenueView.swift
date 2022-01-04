//
//  BookingVenueView.swift
//  Booking
//
//  Created by Fandy Gotama on 17/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import CoreLocation
import Platform

public protocol BookingVenueViewDelegate: class {
    func locationTapped(location: CLLocationCoordinate2D)
}

public class BookingVenueView: UIView {
    private let _userKind: User.Kind
    
    public weak var delegate: BookingVenueViewDelegate?
    
    public let lblEventName: TwoColumnsView = {
        let v = TwoColumnsView(title: "event_name".l10n(), font: regularBody2, equalWidth: false)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let eventNameSeparator: SeparatorView = {
        let v = SeparatorView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblEventDate: TwoColumnsView = {
        let v = TwoColumnsView(title: "service_time".l10n(), font: regularBody2, equalWidth: false)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let eventDateSeparator: SeparatorView = {
        let v = SeparatorView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblVenue: TwoColumnsView = {
        let v = TwoColumnsView(title: "venue".l10n(), font: regularBody2, equalWidth: false)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.lblText.textColor = UIColor.black
        
        return v
    }()
    
    public let venueSeparator: SeparatorView = {
        let v = SeparatorView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblLocationTitle: UILabel = {
        let v = UILabel()
        
        v.text = "address".l10n()
        v.font = regularBody2
        v.isSkeletonable = true
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblLocation: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.numberOfLines = 0
        v.isSkeletonable = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblAddressNoteTitle: UILabel = {
        let v = UILabel()
        
        v.text = "address_note".l10n()
        v.font = regularBody2
        v.isSkeletonable = true
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblAddressNote: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.numberOfLines = 0
        v.isSkeletonable = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblOpenInMap: UILabel = {
        let v = UILabel()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        v.font = regularBody2
        v.textColor = UIColor.systemBlue
        
        return v
    }()
    
    public let lblTitle: UILabel = {
       let v = UILabel()
        v.text = "venue_detail".l10n()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = regularH6
        v.textColor = UIColor.black
        v.isSkeletonable = true
        return v
    }()
    
    public var booking: Booking? {
        didSet {
            guard let booking = booking else { return }
            
            lblEventName.text = booking.eventName
            lblEventDate.text = booking.start.toString(format: "E dd MMM yyyy, HH:mm")
            lblVenue.text = booking.bookingAddress?.name
            lblLocation.text = booking.bookingAddress?.address
            lblOpenInMap.isHidden = !booking.showDirectionLink && _userKind == .customer
            lblAddressNote.text = booking.bookingAddress?.addressNote
            lblOpenInMap.text = _userKind == .artisan ? "check_location".l10n() : "get_direction".l10n()

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(userKind: User.Kind) {
        _userKind = userKind
        
        super.init(frame: .zero)
        
        isSkeletonable = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openInMapTapped))
        lblOpenInMap.isUserInteractionEnabled = true
        lblOpenInMap.addGestureRecognizer(tapGesture)
        addSubview(lblTitle)
        addSubview(lblEventName)
        addSubview(eventNameSeparator)
        addSubview(lblEventDate)
        addSubview(eventDateSeparator)
        addSubview(lblVenue)
        addSubview(venueSeparator)
        addSubview(lblLocationTitle)
        addSubview(lblLocation)
        addSubview(lblAddressNoteTitle)
        addSubview(lblAddressNote)
        addSubview(lblOpenInMap)
        
        NSLayoutConstraint.activate([
            lblTitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            lblTitle.trailingAnchor.constraint(equalTo: trailingAnchor),
            lblTitle.topAnchor.constraint(equalTo: topAnchor),
            
            lblEventName.leadingAnchor.constraint(equalTo: leadingAnchor),
            lblEventName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            lblEventName.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 12),
            
            eventNameSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            eventNameSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            eventNameSeparator.topAnchor.constraint(equalTo: lblEventName.bottomAnchor, constant: 7),
            
            lblEventDate.leadingAnchor.constraint(equalTo: lblEventName.leadingAnchor),
            lblEventDate.trailingAnchor.constraint(equalTo: lblEventName.trailingAnchor),
            lblEventDate.topAnchor.constraint(equalTo: eventNameSeparator.bottomAnchor, constant: 7),
            
            eventDateSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            eventDateSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            eventDateSeparator.topAnchor.constraint(equalTo: lblEventDate.bottomAnchor, constant: 7),
            
            lblVenue.leadingAnchor.constraint(equalTo: lblEventName.leadingAnchor),
            lblVenue.trailingAnchor.constraint(equalTo: lblEventName.trailingAnchor),
            lblVenue.topAnchor.constraint(equalTo: eventDateSeparator.bottomAnchor, constant: 7),
            
            venueSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            venueSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            venueSeparator.topAnchor.constraint(equalTo: lblVenue.bottomAnchor, constant: 7),
            
            lblLocationTitle.leadingAnchor.constraint(equalTo: lblEventName.leadingAnchor),
            lblLocationTitle.trailingAnchor.constraint(equalTo: lblEventName.trailingAnchor),
            lblLocationTitle.topAnchor.constraint(equalTo: venueSeparator.bottomAnchor, constant: 7),
            
            lblLocation.leadingAnchor.constraint(equalTo: lblEventName.leadingAnchor),
            lblLocation.trailingAnchor.constraint(equalTo: lblEventName.trailingAnchor),
            lblLocation.topAnchor.constraint(equalTo: lblLocationTitle.bottomAnchor, constant: 7),
            
            lblAddressNoteTitle.leadingAnchor.constraint(equalTo: lblEventName.leadingAnchor),
            lblAddressNoteTitle.trailingAnchor.constraint(equalTo: lblEventName.trailingAnchor),
            lblAddressNoteTitle.topAnchor.constraint(equalTo: lblLocation.bottomAnchor, constant: 7),
            
            lblAddressNote.leadingAnchor.constraint(equalTo: lblEventName.leadingAnchor),
            lblAddressNote.trailingAnchor.constraint(equalTo: lblEventName.trailingAnchor),
            lblAddressNote.topAnchor.constraint(equalTo: lblAddressNoteTitle.bottomAnchor, constant: 7),
            
            lblOpenInMap.leadingAnchor.constraint(equalTo: lblEventName.leadingAnchor),
            lblOpenInMap.trailingAnchor.constraint(equalTo: lblEventName.trailingAnchor),
            lblOpenInMap.topAnchor.constraint(equalTo: lblAddressNote.bottomAnchor, constant: 5),
            lblOpenInMap.heightAnchor.constraint(equalToConstant: 44),
            
            bottomAnchor.constraint(equalTo: lblOpenInMap.bottomAnchor)
        ])
    }
    
    // MARK: - Selector
    @objc func openInMapTapped() {
        guard
            let booking = booking, let latitude = booking.bookingAddress?.latitude, let longitude = booking.bookingAddress?.longitude
            else { return }

        if booking.showDirectionLink || _userKind == .artisan {
            delegate?.locationTapped(location: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0))
        }
    }
}
