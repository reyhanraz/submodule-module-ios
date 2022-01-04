//
//  AddressAdapter.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import SkeletonView
import SwipeCellKit
import Platform

protocol AddressAdapterDelegate: class {
    func addressTapped(address: Address)
    func addressDeleted(address: Address)
    func buttonDisclosureTapped(address: Address)
}

public class AddressAdapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, AdapterType, SwipeCollectionViewCellDelegate, AddressCellDelegate {
    
    public typealias Item = Address
    
    public let identifier = "AddressCell"
    
    private let _indicatorType: DisclosureIndicator.IndicatorType?
    
    public var list: [Address]?
    public var loadMoreItems: (() -> Void)?
    public var showLoading: Bool?
    public var showEmpty: Bool?
    
    weak var delegate: AddressAdapterDelegate?
    
    public init(indicatorType: DisclosureIndicator.IndicatorType?) {
        _indicatorType = indicatorType
        
        super.init()
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! AddressCell
        
        cell.delegate = self
        cell.disclosureDelegate = self
        cell.address = list?[indexPath.row]
        cell.indicatorType = _indicatorType
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let address = list?[indexPath.row] else { return }
        
        delegate?.addressTapped(address: address)
    }
    
    // MARK: - SwipeCollectionViewCellDelegate
    public func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let address = list?[indexPath.row], orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "delete".l10n()) { (action, indexPath) in
            collectionView.performBatchUpdates({
                self.list?.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }, completion: { _ in
                self.delegate?.addressDeleted(address: address)
            })
        }
        
        deleteAction.image = UIImage(named: "Trash", bundle: PaddingLabel.self)
        
        return [deleteAction]
    }
    
    // MARK: - AddressCellDelegate
    public func buttonDisclosureTapped(address: Address) {
        delegate?.buttonDisclosureTapped(address: address)
    }
}

extension AddressAdapter: SkeletonCollectionViewDataSource {
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return identifier
    }
}



