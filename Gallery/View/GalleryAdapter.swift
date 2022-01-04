//
//  GalleryAdapter.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Nuke
import SkeletonView

protocol GalleryAdapterDelegate: class {
    func onGalleryTapped(indexPath: IndexPath, gallery: Gallery)
    func onLongPressed(gallery: Gallery)
}

public class GalleryAdapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching, GalleryCellDelegate, AdapterType {
    
    private let _preheater = ImagePreheater(destination: .diskCache)
    
    public typealias Item = Gallery
    
    public let identifier = "GalleryCell"
    
    public var list: [Gallery]?
    public var loadMoreItems: (() -> Void)?
    public var showLoading: Bool?
    public var showEmpty: Bool?
    
    weak var delegate: GalleryAdapterDelegate?
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! GalleryCell
        
        cell.delegate = self
        cell.gallery = list?[indexPath.row]
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let loadMoreLoading = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommonUIConfig.loadMoreIdentifier, for: indexPath) as! LoadMoreLoading
            
            return loadMoreLoading
        }
        
        fatalError()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if showLoading == true {
            return CGSize(width: UIScreen.main.bounds.size.width, height: 50)
        } else {
            return CGSize.zero
        }
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let mediaList = getMediaList(from: indexPaths) {
            _preheater.startPreheating(with: mediaList)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if let mediaList = getMediaList(from: indexPaths) {
            _preheater.stopPreheating(with: mediaList)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let gallery = list?[indexPath.row] else { return }
        
        delegate?.onGalleryTapped(indexPath: indexPath, gallery: gallery)
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if (bottomEdge + CommonUIConfig.loadMoreThreshold >= scrollView.contentSize.height && scrollView.contentOffset.y > 0) {
            loadMoreItems?()
        }
    }
    
    // MARK: - GalleryCellDelegate
    public func onLongPressed(gallery: Gallery) {
        delegate?.onLongPressed(gallery: gallery)
    }
    
    // MARK: - Private
    private func getMediaList(from indexPaths: [IndexPath]) -> [URL]? {
        guard let list = list else { return nil }
        
        let feeds: [Gallery] = indexPaths.compactMap { indexPath in
            guard indexPath.row < list.count else { return nil }
            return list[indexPath.row]
        }
        
        return feeds.map { $0.media.small }
    }
}

extension GalleryAdapter: SkeletonCollectionViewDataSource {
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        if supplementaryViewIdentifierOfKind == UICollectionView.elementKindSectionFooter {
            return CommonUIConfig.loadMoreIdentifier
        }
        
        return nil
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return identifier
    }
}


