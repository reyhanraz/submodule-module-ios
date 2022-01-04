//
//  NotificationAdapter.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import SkeletonView
import SwipeCellKit
import Platform

public protocol NotificationAdapterDelegate: class {
    func notificationTapped(notification: Notification)
    func notificationDeleted(notification: Notification)
}

public class NotificationAdapter: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SwipeCollectionViewCellDelegate, AdapterType {
    
    public typealias Item = Notification
    
    public let identifier = "NotificationCell"
    
    public var list: [Notification]?
    public var loadMoreItems: (() -> Void)?
    public var showLoading: Bool?
    public var showEmpty: Bool?
    
    public weak var delegate: NotificationAdapterDelegate?
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! NotificationCell
        
        cell.notification = list?[indexPath.row]
        cell.delegate = self

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let loadMoreLoading = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommonUIConfig.loadMoreIdentifier, for: indexPath) as! LoadMoreLoading
            
            return loadMoreLoading
        }
        
        fatalError()
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if (bottomEdge + CommonUIConfig.loadMoreThreshold >= scrollView.contentSize.height && scrollView.contentOffset.y > 0) {
            loadMoreItems?()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let notification = list?[indexPath.row] else { return }
        
        delegate?.notificationTapped(notification: notification)
    }

    // MARK: - SwipeCollectionViewCellDelegate
    public func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let notification = list?[indexPath.row], orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
            collectionView.performBatchUpdates({
                self.list?.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }, completion: { _ in
                self.delegate?.notificationDeleted(notification: notification)
            })
        }

        deleteAction.image = UIImage(named: "Trash", bundle: PaddingLabel.self)

        return [deleteAction]
    }

}

extension NotificationAdapter: SkeletonCollectionViewDataSource {
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        if supplementaryViewIdentifierOfKind == UICollectionView.elementKindSectionFooter {
            return CommonUIConfig.loadMoreIdentifier
        }
        
        return nil
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return identifier
    }
}
