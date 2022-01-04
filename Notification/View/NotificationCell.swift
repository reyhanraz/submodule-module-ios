//
//  NotificationCell.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import CommonUI
import SwipeCellKit

class NotificationCell: SwipeCollectionViewCell {
    private let _avatarSize: CGFloat = 40
    
    let imgIcon: UIImageView = {
        let v = UIImageView()
        
        v.isSkeletonable = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblName: UILabel = {
        let v = UILabel()
        
        v.text = "                                "
        v.isSkeletonable = true
        v.numberOfLines = 2
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblDescription: UILabel = {
        let v = UILabel()
        
        v.text = " "
        v.font = regularBody3
        v.isSkeletonable = true
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        
        return v
    }()
    
    let lblDate: UILabel = {
        let v = UILabel()
        
        v.text = "                 "
        v.font = regularBody3
        v.isSkeletonable = true
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return v
    }()
    
    let indicator: DisclosureIndicator = {
        let v = DisclosureIndicator()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let separatorView: SeparatorView = {
        let v = SeparatorView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        
        width.isActive = true
        
        return width
    }()
    
    var notification: Notification? {
        didSet {
            guard let data = notification else { return }
            
            setData(data)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        contentView.addSubview(imgIcon)
        contentView.addSubview(lblName)
        contentView.addSubview(lblDescription)
        contentView.addSubview(lblDate)
        contentView.addSubview(indicator)
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            imgIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imgIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imgIcon.widthAnchor.constraint(equalToConstant: 30),
            imgIcon.heightAnchor.constraint(equalToConstant: 30),
            
            lblName.leadingAnchor.constraint(equalTo: imgIcon.trailingAnchor, constant: 15),
            lblName.trailingAnchor.constraint(lessThanOrEqualTo: lblDate.leadingAnchor, constant: -10),
            lblName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            lblDate.trailingAnchor.constraint(equalTo: indicator.leadingAnchor, constant: -10),
            lblDate.topAnchor.constraint(equalTo: lblName.topAnchor),
            
            lblDescription.leadingAnchor.constraint(equalTo: lblName.leadingAnchor),
            lblDescription.trailingAnchor.constraint(equalTo: indicator.leadingAnchor, constant: -10),
            lblDescription.topAnchor.constraint(equalTo: lblName.bottomAnchor, constant: 5),
            
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            indicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: lblDescription.bottomAnchor, constant: 10),
            
            contentView.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor),
        ])
        
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
    
    // MARK: - Private
    private func setData(_ data: Notification) {
        if let icon = data.icon {
            imgIcon.loadMedia(url: icon)
        } else {
            imgIcon.image = nil
        }
        
        lblName.text = data.title
        lblDescription.text = data.body
        lblDate.text = data.createdAt.toString(format: "dd MMM, HH:mm")
        
        if data.status == .unread {
            contentView.backgroundColor = UIColor.BeautyBell.accent.withAlphaComponent(0.05)
        } else {
            contentView.backgroundColor = nil
        }
    }
}

