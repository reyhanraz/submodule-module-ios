//
//  OnboardingCell.swift
//  Onboarding
//
//  Created by Fandy Gotama on 08/11/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit
import CommonUI

protocol OnboardingCellDelegate: class {
    func primaryTapped(onboarding: Onboarding, status: OnboardingCell.Status)
    func secondaryTapped(onboarding: Onboarding, status: OnboardingCell.Status)
}

class OnboardingCell: BaseCollectionViewCell {
    
    enum Status {
        case next
        case finish
    }
    
    weak var delegate: OnboardingCellDelegate?
    
    let lblTitle: UILabel = {
        let v = UILabel()
        
        v.textAlignment = .center
        v.numberOfLines = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = regularBody1
        
        return v
    }()
    
    let lblSubtitle: UILabel = {
        let v = UILabel()
        
        v.textAlignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.numberOfLines = 5
        
        return v
    }()
    
    let imgImage: UIImageView = {
        let v = UIImageView()
        
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var btnPrimary: CustomButton = {
        let v = CustomButton()
        
        v.displayType = .primary
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "next".l10n()
        v.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        
        return v
    }()
    
    lazy var btnSecondary: UIButton = {
        let v = UIButton(type: .custom)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("skip".l10n(), for: .normal)
        v.setTitleColor(UIColor.BeautyBell.gray500, for: .normal)
        v.titleLabel?.font = regularBody2
        v.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        
        return v
    }()
    
    let stackView: UIStackView = {
        var views = [UIView]()
        
        for i in 0...9 {
            let dot = UIView()
            
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.clipsToBounds = true
            dot.backgroundColor = UIColor.BeautyBell.accent.withAlphaComponent(0.5)
            dot.layer.cornerRadius = 5
            dot.isHidden = true
            
            views.append(dot)
            
            dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
        }
        
        let v = UIStackView(arrangedSubviews: views)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.spacing = 7
        
        return v
    }()
    
    private var _status: Status = .next
    
    var data: Onboarding? {
        didSet {
            guard let onboarding = data else { return }
            
            imgImage.image = onboarding.image
            lblTitle.text = onboarding.title
            lblSubtitle.text = onboarding.subtitle
        }
    }
    
    var total: Int? {
        didSet {
            guard let total = total else { return }
            
            let onboardingTotal = total > stackView.arrangedSubviews.count ? stackView.arrangedSubviews.count : total
            
            stackView.arrangedSubviews[0..<onboardingTotal].forEach {
                $0.isHidden = false
            }
        }
    }
    
    var index: Int? {
        didSet {
            guard let index = index else { return }
            
            let onboardingIndex = index >= stackView.arrangedSubviews.count ? stackView.arrangedSubviews.count - 1 : index
            
            stackView.arrangedSubviews[0...onboardingIndex].forEach {
                $0.backgroundColor = UIColor.BeautyBell.accent
            }
        }
    }
    
    var finish: Bool? {
        didSet {
            guard let finish = finish else { return }
            
            if finish {
                _status = .finish
                
                btnPrimary.text = "register".l10n()
            } else {
                _status = .next
                
                btnPrimary.text = "next".l10n()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        contentView.backgroundColor = .white
        
        contentView.addSubview(imgImage)
        contentView.addSubview(lblTitle)
        contentView.addSubview(lblSubtitle)
        contentView.addSubview(stackView)
        contentView.addSubview(btnPrimary)
        contentView.addSubview(btnSecondary)
        
        NSLayoutConstraint.activate([
            imgImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            imgImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imgImage.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imgImage.heightAnchor.constraint(equalToConstant: 200),
            
            lblTitle.topAnchor.constraint(equalTo: imgImage.bottomAnchor, constant: 30),
            lblTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lblTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            lblSubtitle.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 20),
            lblSubtitle.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            lblSubtitle.trailingAnchor.constraint(equalTo: lblTitle.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: lblSubtitle.bottomAnchor, constant: 30),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            btnSecondary.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 20),
            btnSecondary.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            btnSecondary.widthAnchor.constraint(equalToConstant: 120),
            btnSecondary.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            btnPrimary.bottomAnchor.constraint(equalTo: btnSecondary.topAnchor, constant: -20),
            btnPrimary.widthAnchor.constraint(equalToConstant: 120),
            btnPrimary.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    // MARK: - Selector
    @objc func primaryTapped() {
        guard let onboarding = data else { return }
        
        delegate?.primaryTapped(onboarding: onboarding, status: _status)
    }
    
    @objc func secondaryTapped() {
        guard let onboarding = data else { return }
        
        delegate?.secondaryTapped(onboarding: onboarding, status: _status)
    }
}

