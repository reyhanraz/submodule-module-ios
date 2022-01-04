//
//  AddressViewController.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Domain
import Platform

public class AddressViewController: RxRestrictedViewController, AddressAdapterDelegate, UpdateAddressViewControllerDelegate {
    private let _indicatorType: DisclosureIndicator.IndicatorType?
    
    public var addressTapped: ((Address) -> Void)?
    public var disclosureTapped: ((Address) -> Void)?
    
    private lazy var _dataSource: AddressAdapter = {
        let dataSource = AddressAdapter(indicatorType: _indicatorType)
        
        dataSource.delegate = self
        
        return dataSource
    }()
    
    lazy var listView: ListView<ListRequest, ListViewModel<ListRequest, Addresses>, AddressAdapter, Addresses> = {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        let cache = AddressSQLCache<ListRequest>(dbQueue: delegate.dbQueue)
        
        let useCase = ListUseCaseProvider(
            service: AddressCloudService<Addresses>(),
            cacheService: AddressCacheService<Addresses, AddressSQLCache<ListRequest>>(cache: cache),
            cache: cache,
            activityIndicator: activityIndicator)
        
        let viewModel = ListViewModel<ListRequest, Addresses>(useCase: useCase)
        
        let layout = SeparatorCollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 170)
        
        let v = ListView<ListRequest, ListViewModel<ListRequest, Addresses>, AddressAdapter, Addresses>(
            with: AddressCell.self,
            viewModel: viewModel,
            dataSource: _dataSource,
            layout: layout,
            allowPullToRefresh: true,
            emptyTitle: "no_address_found".l10n(),
            emptySubtitle: "no_address_found_message".l10n())
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var _cache: AddressSQLCache<ListRequest> = {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        return AddressSQLCache<ListRequest>(dbQueue: delegate.dbQueue)
    }()
    
    private lazy var _deleteViewModel: ViewModel<Int, Status> = {
        
        let useCase = UseCaseProvider(
            service: DeleteAddressCloudService<Status>(),
            activityIndicator: activityIndicator)
        
        return ViewModel<Int, Status>(useCase: useCase)
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(indicatorType: DisclosureIndicator.IndicatorType? = nil) {
        _indicatorType = indicatorType
        
        super.init(nibName: nil, bundle: nil)
    }
    
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
            loadData()
        })
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNew))
        
        rxBinding()
    }
    
    public override func loadData() {
        view.showAnimatedSkeleton()

        listView.loadData(request: ListRequest())
    }
    
    // MARK: - AddressAdapterDelegate
    func addressTapped(address: Address) {
        addressTapped?(address)
    }
    
    func addressDeleted(address: Address) {
        _cache.remove(model: address)
        
        _deleteViewModel.execute(request: address.id)
        
        listView.toggleEmptyView(show: _dataSource.list?.isEmpty == true)
    }
    
    func buttonDisclosureTapped(address: Address) {
        disclosureTapped?(address)
    }
    
    // MARK: - UpdateAddressViewControllerDelegate
    public func updateSuccess(address: Address) {
        listView.loadData(request: ListRequest(ignorePaging: true))
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Selector
    @objc func addNew() {
        let controller = UpdateAddressViewController()
        
        controller.title = "add".l10n()
        controller.delegate = self
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Rx Binding
    private func rxBinding() {
        _deleteViewModel.result.drive().disposed(by: disposeBag)
    }
}
