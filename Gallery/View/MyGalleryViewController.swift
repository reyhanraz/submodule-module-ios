//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit
import CommonUI
import FittedSheets
import Upload
import Domain
import Platform
import Lightbox
import ServiceWrapper

public class MyGalleryViewController: RxRestrictedViewController, PickMediaOptionsViewControllerDelegate, GalleryAdapterDelegate {
    private let _preference = ArtisanPreference()
    
    private let _request = ListRequest(page: 1, forceReload: false)
    
    private var _uploadQueue = [Gallery]()
    private var _isMultiselect = false
    
    private lazy var adapter: GalleryAdapter = {
        let adapter = GalleryAdapter()
        
        adapter.delegate = self
        
        return adapter
    }()
    
    private let _cache: GallerySQLCache = {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        return GallerySQLCache(dbQueue: delegate.dbQueue, tableName: TableNames.Gallery.own)
    }()
    
    //TODO: Adjust With New UploadViewModel
//    private lazy var _uploadViewModel: UploadMediaViewModel<UploadMediaRequest, GalleryUploadConfirmed> = {
//
//        let useCase = UseCaseProvider(
//            service: UploadCloudService<GalleryUploadConfirmed>(),
//            activityIndicator: activityIndicator)
//
//        return UploadMediaViewModel<UploadMediaRequest, GalleryUploadConfirmed>(useCase: useCase)
//
//    }()
    
    private lazy var _deleteViewModel: ViewModel<[Int], Status> = {
        let useCase = UseCaseProvider(
            service: DeleteGalleryCloudService<Status>(),
            activityIndicator: activityIndicator)
        
        return ViewModel<[Int], Status>(useCase: useCase)
    }()
    
    lazy var btnDelete: UIBarButtonItem = {
        let v = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMediaList))
    
        return v
    }()
    
    lazy var btnCancel: UIBarButtonItem = {
        let v = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelMultiselect))
    
        return v
    }()
    
    lazy var btnCamera: UIBarButtonItem = {
        let v = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(pickImage))
        
        return v
    }()
    
    lazy var listView: ListView<ListRequest, ListViewModel<ListRequest, List<Gallery>>, GalleryAdapter, List<Gallery>> = {
        let columns = 3
        
        let useCase = ListUseCaseProvider(service: GalleryCloudService<List<Gallery>>(),
                                               cacheService: ListCacheService<ListRequest, List<Gallery>, GallerySQLCache>(cache: _cache),
                                               cache: _cache,
                                               activityIndicator: activityIndicator)
        
        let viewModel = ListViewModel(useCase: useCase)
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let marginsAndInsets = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing * CGFloat(columns - 1)
        let itemWidth = ((UIScreen.main.bounds.size.width - marginsAndInsets) / CGFloat(columns)).rounded(.down)
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let v = ListView<ListRequest, ListViewModel<ListRequest, List<Gallery>>, GalleryAdapter, List<Gallery>>(
            with: GalleryCell.self,
            viewModel: viewModel,
            dataSource: adapter,
            layout: layout,
            allowPullToRefresh: true,
            emptyTitle: "no_my_gallery_found".l10n(),
            emptySubtitle: "no_my_gallery_found_message".l10n())
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(listView)
    
        view.isSkeletonable = true
        view.backgroundColor = .white
                
        navigationItem.rightBarButtonItem = btnCamera
        
        rxBinding()
        
        NSLayoutConstraint.activate([
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        listView.collectionView.prepareSkeleton(completion: { [unowned self] done in
            loadData()
        })
        
        removeCacheFiles()
    }
    
    override public func loadData() {
        view.showAnimatedSkeleton()

        _request.id = _preference.user?.id
        _request.timestamp = Date().timeIntervalSince1970
        
        listView.loadData(request: _request)
    }
    
    // MARK: - PickMediaOptionsViewControllerDelegate
    public func pickerFinished(url: URL) {
        listView.toggleEmptyView(show: false)
        
        dismiss(animated: true, completion: nil)
        
        let gallery = Gallery(media: Media(url: url, servingURL: nil), mediaCoverURL: nil, uploadStatus: .waiting)
        
        _uploadQueue.append(gallery)
        
        adapter.list?.insert(gallery, at: 0)
        listView.collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
        
        //TODO: Upload Gallery
        
    }

    public func cameraDidTap() {
        // Do Nothing
    }

    func onGalleryTapped(indexPath: IndexPath, gallery: Gallery) {
        if _isMultiselect {
            onLongPressed(gallery: gallery)
        } else {
            if gallery.uploadStatus == .failed {
                gallery.uploadStatus = .waiting
                
                listView.collectionView.reloadItems(at: [indexPath])
                
                //TODO: Upload Gallery
                
            } else {
                guard let lightboxImages = adapter.list?.map({ LightboxImage(imageURL: $0.media.original) }) else { return }
                
                let controller = LightboxController(images: lightboxImages, startIndex: indexPath.row)
                
                controller.dynamicBackground = true
                controller.modalPresentationStyle = .fullScreen
                
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func onLongPressed(gallery: Gallery) {
        guard let position = adapter.list?.firstIndex(where: { $0.id == gallery.id }) else { return }
        
        _isMultiselect = true
        
        gallery.checked = !gallery.checked
        
        listView.collectionView.reloadItems(at: [IndexPath(row: position, section: 0)])
        
        navigationItem.setRightBarButtonItems([btnDelete, btnCancel], animated: true)
    }
    
    // MARK: - Selector
    @objc func longPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .began {
            return
        }
        
        let point = gestureRecognizer.location(in: listView)
        
        if let indexPath = listView.collectionView.indexPathForItem(at: point), let list = adapter.list, indexPath.row < list.count {
            let gallery = list[indexPath.row]
            
            gallery.checked = !gallery.checked
            
            listView.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    @objc func pickImage() {
        let controller = PickMediaOptionsViewController()
        
        controller.delegate = self
        
        let sheet = SheetViewController(controller: controller, sizes: [.fixed(150)])
        
        present(sheet, animated: false, completion: nil)
    }
    
    @objc func deleteMediaList() {
        let indexPaths = adapter.list?.enumerated().filter { $0.element.checked }.map { IndexPath(row: $0.offset, section: 0) }
        
        if let indexPaths = indexPaths {
            var ids = [Int]()
            
            adapter.list?.filter { $0.checked }.forEach {
                _cache.remove(model: $0)
                
                ids.append($0.id)
            }
            
            adapter.list?.removeAll(where: { $0.checked })
            
            listView.collectionView.deleteItems(at: indexPaths)
            
            if adapter.list?.isEmpty == true {
                listView.toggleEmptyView(show: true)
                cancelMultiselect()
            }
            
            _deleteViewModel.execute(request: ids)
            
        }
    }
    
    @objc func cancelMultiselect() {
        navigationItem.setRightBarButtonItems([btnCamera], animated: true)
        
        let indexPaths = adapter.list?.enumerated().filter { $0.element.checked }.map { IndexPath(row: $0.offset, section: 0) }
        
        if let indexPaths = indexPaths {
            adapter.list?.filter { $0.checked }.forEach {
                $0.checked = false
            }
            
            listView.collectionView.reloadItems(at: indexPaths)
        }
        
        _isMultiselect = false
    }
    
    // MARK: - Private
    private func rxBinding() {
        _deleteViewModel.result.drive().disposed(by: disposeBag)
        
        //TODO: Adjust With New UploadViewModel
//        _uploadViewModel.upload.drive().disposed(by: disposeBag)
//
//        _uploadViewModel.loading.drive(onNext: { [weak self] (request, loading) in
//            guard
//                let strongSelf = self,
//                let gallery = strongSelf.adapter.list?.first(where: { $0.media.url == request.url }),
//                let index = strongSelf.adapter.list?.firstIndex(where: { $0.media.url == request.url })
//                else { return }
//
//            gallery.uploadStatus = .uploading
//
//            strongSelf.listView.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
//
//        }).disposed(by: disposeBag)
//
//        _uploadViewModel.exception.drive(onNext: { [weak self] (request, error) in
//            guard
//                let strongSelf = self,
//                let gallery = strongSelf.adapter.list?.first(where: { $0.media.url == request.url }),
//                let index = strongSelf.adapter.list?.firstIndex(where: { $0.media.url == request.url })
//                else { return }
//
//            gallery.uploadStatus = .failed
//
//            strongSelf.listView.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
//
//        }).disposed(by: disposeBag)
//
//        _uploadViewModel.success.drive(onNext: { [weak self] (request, confirmed) in
//            guard
//                let strongSelf = self,
//                let index = strongSelf.adapter.list?.firstIndex(where: { $0.media.url == request.url })
//                else { return }
//            let uploaded = confirmed.data
//
//            let gallery = Gallery(
//                userId: uploaded.userId,
//                folder: uploaded.folder,
//                key: uploaded.key,
//                media: uploaded.media,
//                mediaCoverURL: nil,
//                format: uploaded.format,
//                type: uploaded.type,
//                id: uploaded.id,
//                uploadStatus: .success,
//                createdAt: Date(),
//                updatedAt: Date(),
//                paging: Paging(currentPage: 1, limitPerPage: PlatformConfig.defaultLimit, totalPage: 1))
//
//            strongSelf._uploadQueue.removeAll(where: { $0.media.url == request.url })
//
//            strongSelf.adapter.list?[index] = gallery
//
//            strongSelf.listView.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
//
//            strongSelf._cache.put(model: gallery)
//
//        }).disposed(by: disposeBag)
    }
}

