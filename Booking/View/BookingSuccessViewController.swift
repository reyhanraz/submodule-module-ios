//
//  BookingSuccessViewController.swift
//  BeautyBell
//
//  Created by Fandy Gotama on 13/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import CoreLocation
import Platform

public class BookingSuccessViewController: BaseViewController, BookingVenueViewDelegate {
    private let _booking: Booking
    
    let lblConfirmation: UILabel = {
        let v = UILabel()
        
        v.text = "booking_successfully_created".l10n()
        v.font = regularBody1
        v.numberOfLines = 2
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblBookingID: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let profileView: ProfileView = {
        let v = ProfileView(kind: .artisan)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblInformation: UILabel = {
        let v = UILabel()
        
        v.font = regularBody1
        v.textColor = UIColor.BeautyBell.gray500
        v.textAlignment = .center
        v.numberOfLines = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let serviceSummaryView: BookingServiceSummaryView = {
        let v = BookingServiceSummaryView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var venueView: BookingVenueView = {
        let v = BookingVenueView(userKind: .artisan)
        
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var btnFinish: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .primary
        v.text = "finish".l10n()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(finish), for: .touchUpInside)
        
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        
        v.addSubview(lblConfirmation)
        v.addSubview(lblBookingID)
        v.addSubview(profileView)
        v.addSubview(lblInformation)
        v.addSubview(serviceSummaryView)
        v.addSubview(venueView)
        v.addSubview(btnFinish)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(booking: Booking) {
        _booking = booking
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            lblConfirmation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lblConfirmation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lblConfirmation.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            
            lblBookingID.leadingAnchor.constraint(equalTo: lblConfirmation.leadingAnchor),
            lblBookingID.trailingAnchor.constraint(equalTo: lblConfirmation.trailingAnchor),
            lblBookingID.topAnchor.constraint(equalTo: lblConfirmation.bottomAnchor, constant: 5),
            
            profileView.topAnchor.constraint(equalTo: lblBookingID.bottomAnchor, constant: 20),
            profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            lblInformation.leadingAnchor.constraint(equalTo: lblConfirmation.leadingAnchor, constant: 15),
            lblInformation.trailingAnchor.constraint(equalTo: lblConfirmation.trailingAnchor, constant: -15),
            lblInformation.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 20),
            
            serviceSummaryView.leadingAnchor.constraint(equalTo: lblConfirmation.leadingAnchor),
            serviceSummaryView.trailingAnchor.constraint(equalTo: lblConfirmation.trailingAnchor),
            serviceSummaryView.topAnchor.constraint(equalTo: venueView.bottomAnchor, constant: 20),
            
            venueView.leadingAnchor.constraint(equalTo: serviceSummaryView.leadingAnchor),
            venueView.trailingAnchor.constraint(equalTo: serviceSummaryView.trailingAnchor),
            venueView.topAnchor.constraint(equalTo: lblInformation.bottomAnchor, constant: 30),
            
            btnFinish.leadingAnchor.constraint(equalTo: serviceSummaryView.leadingAnchor),
            btnFinish.trailingAnchor.constraint(equalTo: serviceSummaryView.trailingAnchor),
            btnFinish.topAnchor.constraint(equalTo: serviceSummaryView.bottomAnchor, constant: 20),
            
            scrollView.bottomAnchor.constraint(equalTo: btnFinish.bottomAnchor, constant: 20)
        ])
        
        loadData()
    }
    
    // MARK: - BookingVenueViewDelegate
    public func locationTapped(location: CLLocationCoordinate2D) {
        openMaps(name: venueView.lblVenue.lblText.text, coordinates: location)
    }
    
    // MARK: - Selector
    @objc func finish() {
//        if let id = _booking.artisan?.id, let serviceIds = _booking.bookingServices?.map({ String($0.serviceId) }).joined(separator: ",") {
//            trackEvent(name: EventNames.bookingStepFinish.rawValue, extraParams: [
//                EventParams.bookingId.rawValue: _booking.id,
//                EventParams.artisanId.rawValue: id,
//                EventParams.serviceList.rawValue: serviceIds
//            ])
//        }
//        
//        // Dismiss all presented modals
//        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    private func loadData() {
        let text = "booking_id_x".l10n(args: [String(_booking.id)])
        let attributedString = NSMutableAttributedString(string: text)
        
        let ranges = text.ranges(of: "booking_id_colon".l10n())
        
        ranges.forEach {
            attributedString.addAttributes([.foregroundColor: UIColor.BeautyBell.gray500], range: NSRange($0, in: text))
        }
        
        lblBookingID.attributedText = attributedString
//        profileView.artisan = _booking.artisan
        
        lblInformation.text = "you_will_be_contacted_x".l10n(args: [_booking.artisan?.name ?? ""])
        
        serviceSummaryView.booking = _booking
        
        venueView.booking = _booking
    }
}
