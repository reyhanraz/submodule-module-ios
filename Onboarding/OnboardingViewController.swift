//
//  OnboardingViewController.swift
//  Onboarding
//
//  Created by Fandy Gotama on 08/11/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit
import CommonUI

public protocol OnboardingViewControllerDelegate: class {
    func dismiss()
    func register()
    func login()
}

public class OnboardingViewController: BaseViewController, OnboardingCollectionViewDelegate {
    
    private let _onboardings: [Onboarding]
    
    lazy var onboardingView: OnboardingCollectionView = {
        let v = OnboardingCollectionView(onboardings: _onboardings)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        
        return v
    }()
    
    public weak var delegate: OnboardingViewControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(onboardings: [Onboarding]) {
        _onboardings = onboardings
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(onboardingView)
        
        NSLayoutConstraint.activate([
            onboardingView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ])
    }
    
    // MARK: - OnboardingCollectionViewDelegate
    func primaryTapped(status: OnboardingCell.Status) {
        if status == .finish {
            delegate?.register()
        }
    }
    
    func secondaryTapped(status: OnboardingCell.Status) {
        delegate?.dismiss()
    }
}

