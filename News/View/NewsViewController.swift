//
//  NewsViewController.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Domain
import Platform
import RxGRDB

public class NewsViewController: RxRestrictedViewController, NewsAdapterDelegate {
    
    lazy var listView: ListView<ListRequest, ListViewModel<ListRequest, List<News>>, NewsAdapter, List<News>> = {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        let cache = NewsSQLCache(dbQueue: delegate.dbQueue)
        
        let useCase = ListUseCaseProvider(service: NewsCloudService<List<News>>(),
                                               cacheService: ListCacheService<ListRequest, List<News>, NewsSQLCache>(cache: cache),
                                               cache: cache,
                                               activityIndicator: activityIndicator)
        
        let viewModel = ListViewModel(useCase: useCase)
        
        let adapter = NewsAdapter()
        
        adapter.delegate = self
        
        let layout = SeparatorCollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 75)
        
        let v = ListView<ListRequest, ListViewModel<ListRequest, List<News>>, NewsAdapter, List<News>>(
            with: NewsCell.self,
            viewModel: viewModel,
            dataSource: adapter,
            layout: layout,
            allowPullToRefresh: true)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        view.backgroundColor = .white
        
        view.addSubview(listView)
        
        NSLayoutConstraint.activate([
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        listView.collectionView.prepareSkeleton(completion: { [unowned self] done in
            view.showAnimatedSkeleton()
            
            listView.loadData(request: ListRequest(page: 1, forceReload: true))
        })
        
        rxBinding()
    }
    
    // MARK: - NewsAdapterDelegate
    func newsTapped(_ news: News) {
        let controller = NewsDetailViewController(news: news)
        
        controller.title = "news".l10n()
        controller.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Private
    private func rxBinding() {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        News.all().rx.changes(in: delegate.dbQueue).subscribe(onNext: { [weak self] _ in
            let request = ListRequest()
            
            request.ignorePaging = true
            
            self?.listView.loadData(request: request)
        }).disposed(by: disposeBag)
    }
}
