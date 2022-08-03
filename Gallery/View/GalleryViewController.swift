//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Fandy Gotama on 22/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform
import Domain
import SkeletonView
import ScrollCoordinator

public protocol GalleryViewControllerDelegate: AnyObject {
    func galleryTapped(galleries: [Gallery], index: Int)
}

public class GalleryViewController: RxViewController, GalleryAdapterDelegate {
    private let _userId: String
    private let _kind: NewProfile.Kind
    private let _frame: CGRect
    
    private weak var _manager: ScrollCoordinatorManager?
    
    public weak var delegate: GalleryViewControllerDelegate?
    
    private lazy var adapter: GalleryAdapter = {
        let adapter = GalleryAdapter()
        
        adapter.delegate = self
        
        return adapter
    }()
    
    lazy var listView: NewListView<NewListRequest, NewListViewModel<NewListRequest, NewList<Gallery>>, GalleryAdapter, NewList<Gallery>> = {
        let columns = 3
        
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        let tableName = _kind == .customer ? TableNames.Gallery.customer : TableNames.Gallery.artisan
        
        let cache = GallerySQLCache(dbQueue: delegate.dbQueue, tableName: tableName)
        
        let useCase = NewListUseCaseProvider(service: GalleryCloudService<NewList<Gallery>>(),
                                               cacheService: NewListCacheService<NewListRequest, NewList<Gallery>, GallerySQLCache>(cache: cache),
                                               cache: cache,
                                               activityIndicator: activityIndicator)
        
        let viewModel = NewListViewModel(useCase: useCase)
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let marginsAndInsets = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing * CGFloat(columns - 1)
        let itemWidth = ((UIScreen.main.bounds.size.width - marginsAndInsets) / CGFloat(columns)).rounded(.down)
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let v = NewListView<NewListRequest, NewListViewModel<NewListRequest, NewList<Gallery>>, GalleryAdapter, NewList<Gallery>>(
            with: GalleryCell.self,
            viewModel: viewModel,
            dataSource: adapter,
            layout: layout,
            allowPullToRefresh: true,
            emptyTitle: "no_gallery_found".l10n(),
            emptySubtitle: "no_gallery_found_message".l10n(),
            emptyViewAlignment: _frame != .zero ? .top : .center)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(frame: CGRect = .zero, userId: String, kind: NewProfile.Kind, manager: ScrollCoordinatorManager? = nil) {
        _userId = userId
        _kind = kind
        _frame = frame
        _manager = manager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(listView)
        
        listView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        listView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        if _frame != .zero {
            listView.widthAnchor.constraint(equalToConstant: _frame.size.width).isActive = true
            listView.heightAnchor.constraint(equalToConstant: _frame.size.height).isActive = true
        } else {
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        listView.collectionView.prepareSkeleton { [unowned self] done in
            view.showAnimatedSkeleton()
            
            listView.loadData(request: NewListRequest(id: _userId, page: 1, kind: .artisan))
        }
        
        _manager?.registerScrollViewToCoordinator(scrollView: listView.collectionView)
    }
    
    // MARK: - GalleryAdapterDelegate
    func onGalleryTapped(indexPath: IndexPath, gallery: Gallery) {
        guard let galleries = adapter.list else { return }
        
        delegate?.galleryTapped(galleries: galleries, index: indexPath.row)
    }
    
    func onLongPressed(gallery: Gallery) {
        // Do Nothing
    }
}
