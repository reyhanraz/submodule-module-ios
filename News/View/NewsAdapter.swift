//
//  NewsAdapter.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import SkeletonView

protocol NewsAdapterDelegate: class {
    func newsTapped(_ news: News)
}

class NewsAdapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, AdapterType {
    
    typealias Item = News
    
    let identifier = "NewsCell"
    
    var list: [News]?
    var loadMoreItems: (() -> Void)?
    var showLoading: Bool?
    var showEmpty: Bool?
    
    weak var delegate: NewsAdapterDelegate?
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! NewsCell
        
        cell.news = list?[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let loadMoreLoading = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommonUIConfig.loadMoreIdentifier, for: indexPath) as! LoadMoreLoading
            
            return loadMoreLoading
        }
        
        fatalError()
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let news = list?[indexPath.row] else { return }
        
        delegate?.newsTapped(news)
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if (bottomEdge + CommonUIConfig.loadMoreThreshold >= scrollView.contentSize.height && scrollView.contentOffset.y > 0) {
            loadMoreItems?()
        }
    }
}

extension NewsAdapter: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        if supplementaryViewIdentifierOfKind == UICollectionView.elementKindSectionFooter {
            return CommonUIConfig.loadMoreIdentifier
        }
        
        return nil
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return identifier
    }
}


