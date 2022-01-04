//
//  BookingReviewView.swift
//  Booking
//
//  Created by Reyhan Rifqi Azzami on 06/12/21.
//  Copyright © 2021 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import CommonUI

public class BookingReviewView: UIView {
    let lblReview: UILabel = {
        let v = UILabel()
        
        v.text = "review".l10n()
        v.isSkeletonable = true
        v.font = regularH6
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let separatorView: SeparatorView = {
        let v = SeparatorView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let edtComment: UILabel = {
        let v = UILabel()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = regularBody2
        v.numberOfLines = 0
        return v
    }()
    
    let ratingView: RatingWithCounter = {
        let v = RatingWithCounter(ratingSize: 20, font: regularBody2)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public var review: Booking.Review? {
        didSet {
            guard let review = review else {
                return
            }
            ratingView.rating = Double(review.rating)
            edtComment.text = review.comment
        }
    }
    
    public init(){
        super.init(frame: .zero)
        
        isSkeletonable = true
        addSubview(lblReview)
        addSubview(separatorView)
        addSubview(ratingView)
        addSubview(edtComment)
        
        layer.borderColor = UIColor.BeautyBell.gray300.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            lblReview.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            lblReview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lblReview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            separatorView.topAnchor.constraint(equalTo: lblReview.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            
            ratingView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            ratingView.leadingAnchor.constraint(equalTo: lblReview.leadingAnchor),
            
            edtComment.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 10),
            edtComment.leadingAnchor.constraint(equalTo: lblReview.leadingAnchor),
            edtComment.trailingAnchor.constraint(equalTo: lblReview.trailingAnchor),
            
            bottomAnchor.constraint(equalTo: edtComment.bottomAnchor, constant: 10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
