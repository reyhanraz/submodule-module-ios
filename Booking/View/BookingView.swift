//
//  BookingView.swift
//  Booking
//
//  Created by Fandy Gotama on 26/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform

public class BookingView: UIView {
    
    private let _avatarSize: CGFloat = 40
    
    public lazy var lblBookingStatus: UILabel = {
        let v = UILabel()
        
        v.text = "            "
        v.font = regularBody1
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return v
    }()
    
    public lazy var lblBookingID: UILabel = {
        let v = UILabel()

        v.text = "                   "
        v.isSkeletonable = true
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.textAlignment = .right
        
        return v
    }()
    
    public let lblBookingTime: TwoColumnsView = {
        let v = TwoColumnsView(title: "service_time".l10n(), font: regularBody2, equalWidth: false)
        
        v.isSkeletonable = true
        v.lblText.textAlignment = .right
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblEventName: TwoColumnsView = {
        let v = TwoColumnsView(title: "event_name".l10n(), font: regularBody2, equalWidth: false)
        
        v.isSkeletonable = true
        v.lblText.textAlignment = .right
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblServiceType: TwoColumnsView = {
        let v = TwoColumnsView(title: "service_type".l10n(), font: regularBody2, equalWidth: false)
        
        v.isSkeletonable = true
        v.lblText.textAlignment = .right
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lblTotalBookingFeesTitle: UILabel = {
        let v = UILabel()
        
        v.isSkeletonable = true
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "total_booking_fees".l10n()
        
        return v
    }()
    
    public let lblTotalBookingFees: CurrencyLabel = {
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

    public let lblPaymentStatus: UILabel = {
        let v = UILabel()

        v.text = "          "
        v.font = regularBody2
        v.isSkeletonable = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.textAlignment = .right

        return v
    }()

    public lazy var imgAvatar: UIImageView = {
        let v = UIImageView(image: UIImage(named: "Avatar", bundle: LogoView.self))
        
        v.isSkeletonable = true
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = _avatarSize / 2
        v.clipsToBounds = true
        
        return v
    }()
    
    public let lblName: UILabel = {
        let v = UILabel()
        
        v.text = "                          "
        v.isSkeletonable = true
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let statusSeparatorView: SeparatorView = {
        let v = SeparatorView(height: 1)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let imgBadge: UIImageView = {
        let v = UIImageView()

        v.isSkeletonable = true
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let ratingView: RatingWithCounter = {
        let v = RatingWithCounter()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public let lineView: UIView = {
        let v = UIView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()

    public lazy var nameContainer: UIStackView = {
        let v = UIStackView(arrangedSubviews: [imgBadge, lblName])
        
        v.isSkeletonable = true
        v.axis = .horizontal
        v.spacing = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()

    public lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [nameContainer, ratingView])
        
        v.isSkeletonable = true
        v.axis = .vertical
        v.spacing = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public func setBooking(booking: Booking, kind: User.Kind) {
        
        lineView.backgroundColor = booking.status.color
        statusSeparatorView.backgroundColor = lineView.backgroundColor
        
        layer.borderColor = lineView.backgroundColor?.cgColor
        
        lblBookingStatus.textColor = lineView.backgroundColor
        lblEventName.text = booking.eventName
        lblBookingID.text = booking.invoice
        lblBookingTime.text = booking.start.toString(format: "E dd MMM yyyy, HH:mm")
        lblServiceType.text = booking.serviceTypes
        lblPaymentStatus.text = booking.paymentStatusName

        if booking.status == .bid && booking.hasBid {
            let text = booking.bookingStatus
            let attributedString = NSMutableAttributedString(string: text)
            
            let ranges = text.ranges(of: "by_you".l10n())
            
            ranges.forEach {
                attributedString.addAttributes([.foregroundColor: UIColor.BeautyBell.gray500, .font: regularBody2], range: NSRange($0, in: text))
            }
            
            lblBookingStatus.attributedText = attributedString
        } else {
            lblBookingStatus.text = booking.bookingStatus
        }

        if kind == .artisan {
            if booking.artisan == nil {
                lblName.isHidden = true
                imgAvatar.isHidden = true
                ratingView.isHidden = true
            } else {
                lblName.isHidden = false
                imgAvatar.isHidden = false
                ratingView.isHidden = false
                
                lblName.text = booking.artisan?.name
                imgAvatar.loadMedia(url: booking.artisan?.avatar?.small, failure: UIImage(named: "Avatar", bundle: LogoView.self))
                ratingView.rating = booking.artisan?.reviewRating
            }
            
            imgBadge.image = booking.artisan?.badgeImage
            imgBadge.isHidden = imgBadge.image == nil
        } else {
            lblName.text = booking.customer.name
            imgBadge.isHidden = true
            imgAvatar.loadMedia(url: booking.customer.avatar?.small, failure: UIImage(named: "Avatar", bundle: LogoView.self))
            ratingView.isHidden = true
        }
        
        lblTotalBookingFees.price = booking.totalPrice
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        let detailSeparatorView = SeparatorView(color: UIColor.BeautyBell.gray300)
        detailSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(lineView)
        addSubview(lblBookingStatus)
        addSubview(lblBookingID)
        addSubview(statusSeparatorView)
        addSubview(lblBookingTime)
        addSubview(lblEventName)
        addSubview(lblServiceType)
        addSubview(imgAvatar)
        addSubview(stackView)
        addSubview(detailSeparatorView)
        addSubview(lblTotalBookingFeesTitle)
        addSubview(lblTotalBookingFees)
        addSubview(lblPaymentStatus)

        layer.cornerRadius = 5
        layer.borderWidth = 1
        
        clipsToBounds = true

        let imgLevelWidthConstraint = imgBadge.widthAnchor.constraint(equalToConstant: 20)
        imgLevelWidthConstraint.priority = UILayoutPriority(999)
        imgLevelWidthConstraint.isActive = true

        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.bottomAnchor.constraint(equalTo: statusSeparatorView.topAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 5),
            
            lblBookingStatus.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            lblBookingStatus.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            lblBookingStatus.trailingAnchor.constraint(equalTo: lblBookingID.leadingAnchor, constant: -10),
            
            lblBookingID.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            lblBookingID.centerYAnchor.constraint(equalTo: lblBookingStatus.centerYAnchor),
            
            statusSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            statusSeparatorView.topAnchor.constraint(equalTo: lblBookingStatus.bottomAnchor, constant: 10),
            
            lblBookingTime.leadingAnchor.constraint(equalTo: lblBookingStatus.leadingAnchor),
            lblBookingTime.trailingAnchor.constraint(equalTo: lblBookingID.trailingAnchor),
            lblBookingTime.topAnchor.constraint(equalTo: lblEventName.bottomAnchor, constant: 5),
            
            lblEventName.leadingAnchor.constraint(equalTo: lblBookingTime.leadingAnchor),
            lblEventName.trailingAnchor.constraint(equalTo: lblBookingTime.trailingAnchor),
            lblEventName.topAnchor.constraint(equalTo: statusSeparatorView.bottomAnchor, constant: 19),
            
            lblServiceType.leadingAnchor.constraint(equalTo: lblBookingTime.leadingAnchor),
            lblServiceType.trailingAnchor.constraint(equalTo: lblBookingTime.trailingAnchor),
            lblServiceType.topAnchor.constraint(equalTo: lblBookingTime.bottomAnchor, constant: 5),
            
            imgAvatar.leadingAnchor.constraint(equalTo: lblBookingTime.leadingAnchor),
            imgAvatar.topAnchor.constraint(equalTo: lblServiceType.bottomAnchor, constant: 15),
            imgAvatar.widthAnchor.constraint(equalToConstant: _avatarSize),
            imgAvatar.heightAnchor.constraint(equalToConstant: _avatarSize),
            
            stackView.leadingAnchor.constraint(equalTo: imgAvatar.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -15),
            stackView.centerYAnchor.constraint(equalTo: imgAvatar.centerYAnchor),
            
            lblName.topAnchor.constraint(equalTo: nameContainer.topAnchor),
            lblName.bottomAnchor.constraint(equalTo: nameContainer.bottomAnchor),
            
            imgBadge.centerYAnchor.constraint(equalTo: lblName.centerYAnchor),
            imgBadge.heightAnchor.constraint(equalToConstant: 20),
            
            detailSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailSeparatorView.topAnchor.constraint(equalTo: imgAvatar.bottomAnchor, constant: 15),
            
            lblTotalBookingFeesTitle.leadingAnchor.constraint(equalTo: lblBookingTime.leadingAnchor),
            lblTotalBookingFeesTitle.centerYAnchor.constraint(equalTo: lblTotalBookingFees.centerYAnchor),
            lblTotalBookingFeesTitle.trailingAnchor.constraint(equalTo: lblTotalBookingFees.leadingAnchor, constant: -10),
            
            lblTotalBookingFees.trailingAnchor.constraint(equalTo: lblBookingTime.trailingAnchor),
            lblTotalBookingFees.topAnchor.constraint(equalTo: detailSeparatorView.bottomAnchor, constant: 10),

            lblPaymentStatus.topAnchor.constraint(equalTo: lblTotalBookingFees.bottomAnchor, constant: 5),
            lblPaymentStatus.trailingAnchor.constraint(equalTo: lblTotalBookingFees.trailingAnchor),
        ])
    }
}
