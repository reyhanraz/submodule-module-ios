//
//  SearchBookingViewController.swift
//  Booking
//
//  Created by Fandy Gotama on 26/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit
import Domain
import Platform
import CommonUI
import RxSwift

public typealias TableViewDataSource = UITableViewDelegate & UITableViewDataSource & AdapterType

public protocol SearchBookingViewControllerDelegate: class {
    func searchDidDismiss()
}

public class SearchBookingViewController<U: UseCase, Source: TableViewDataSource, ServiceResponse: NewResponseListType>: RxViewController, UISearchBarDelegate, UISearchControllerDelegate
    where
    U.R == BookingListRequest,
    U.T == ServiceResponse,
    U.E == Error,
Source.Item == ServiceResponse.T {
    
    private let _cellClass: AnyClass
    private let _useCase: U
    private let _searchAfter: Int
    private let _placeholder: String?
    private let _rowHeight: CGFloat
    
    private var _dataSource: Source
    
    public weak var delegate: SearchBookingViewControllerDelegate?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var tableView: UITableView = {
        let v = UITableView()
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = _placeholder
        searchController.delegate = self
        
        let statusBarView = UIView(frame: CGRect(
            x:0, y:0,
            width: UIApplication.shared.statusBarFrame.size.width,
            height: UIApplication.shared.statusBarFrame.size.height))
        statusBarView.backgroundColor = .white
        
        searchController.view.addSubview(statusBarView)
        
        let searchField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        
        if let field = searchField {
            field.font = regularBody2
        }
        
        definesPresentationContext = true
        
        v.isSkeletonable = true
        v.separatorStyle = .none
        v.tableHeaderView = searchController.searchBar
        v.rowHeight = _rowHeight
        v.dataSource = _dataSource
        v.delegate = _dataSource
        v.keyboardDismissMode = .interactive
        
        v.register(_cellClass, forCellReuseIdentifier: _dataSource.identifier)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var _viewModel: SearchBookingViewModel = {
        return SearchBookingViewModel<ServiceResponse>(
            keyword: searchController.searchBar.rx.text.orEmpty.asObservable(),
            searchAfter: _searchAfter,
            useCase: _useCase)
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(with cellClass: AnyClass, useCase: U, dataSource: Source, searchAfter: Int = 0, placeholder: String?, rowHeight: CGFloat) {
        _cellClass = cellClass
        _dataSource = dataSource
        _useCase = useCase
        _searchAfter = searchAfter
        _placeholder = placeholder
        _rowHeight = rowHeight
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        rxBinding()
        
        _viewModel.loadSavedResults()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.isActive = true
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if navigationController?.isBeingDismissed == true {
            delegate?.searchDidDismiss()
        }
    }
    
    // MARK: - UISearchControllerDelegate
    public func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {[weak self] in
            self?.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - UISearchBarDelegate
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if _dataSource.list?.isEmpty == true {
            _viewModel.loadSavedResults()
        }
    }
    
    // MARK: - Rx Binding
    private func rxBinding() {
        //_viewModel.loading.drive(view.rx.toggleSkeletonLoading).disposed(by: disposeBag)
        
        _viewModel.result.drive(onNext: { [weak self] list in
            guard let strongSelf = self else { return }
            
            strongSelf._dataSource.list = list
            strongSelf.tableView.reloadData()
            //strongSelf.view.hideSkeleton()
            
        }).disposed(by: disposeBag)
    }
    
}

