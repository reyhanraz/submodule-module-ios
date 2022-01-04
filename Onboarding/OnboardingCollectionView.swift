//
//  OnboardingCollectionView.swift
//  Onboarding
//
//  Created by Fandy Gotama on 08/11/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit

protocol OnboardingCollectionViewDelegate: class {
    func primaryTapped(status: OnboardingCell.Status)
    func secondaryTapped(status: OnboardingCell.Status)
}

class OnboardingCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, OnboardingCellDelegate {
    private let _onboardings: [Onboarding]
    
    let reuseIdentifier = "OnboardingCell"
    
    weak var delegate: OnboardingCollectionViewDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let topAreaInsets: CGFloat
        let bottomAreaInsets: CGFloat
        
        if #available(iOS 11.0, *) {
            topAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            bottomAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            topAreaInsets = 0
            bottomAreaInsets = 0
        }
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - topAreaInsets - bottomAreaInsets)
        
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        v.delegate = self
        v.dataSource = self
        v.register(OnboardingCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        v.isPagingEnabled = true
        v.showsHorizontalScrollIndicator = false
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    init(onboardings: [Onboarding]) {
        _onboardings = onboardings
        
        super.init(frame: .zero)
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - UICollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _onboardings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OnboardingCell
        
        cell.data = _onboardings[indexPath.row]
        cell.total = _onboardings.count
        cell.index = indexPath.row
        cell.finish = _onboardings.count - 1 == indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - OnboardingCellDelegate
    func primaryTapped(onboarding: Onboarding, status: OnboardingCell.Status) {
        delegate?.primaryTapped(status: status)
        
        if status == .next, let index = _onboardings.firstIndex(where: {onboarding.title == $0.title }) {
            collectionView.scrollToItem(at: IndexPath(row: index + 1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func secondaryTapped(onboarding: Onboarding, status: OnboardingCell.Status) {
        delegate?.secondaryTapped(status: status)
    }
}

