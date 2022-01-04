//
//  LocationAdapter.swift
//  Address
//
//  Created by Fandy Gotama on 29/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform
import SkeletonView

public protocol LocationAdapterDelegate: class {
    func locationTapped(_ location: Location)
}

public class LocationAdapter<C: Cache>: NSObject, UITableViewDelegate, UITableViewDataSource, AdapterType where C.R == String, C.T == Location {
    
    public typealias Item = Location
    
    public let identifier = "LocationCell"
    
    let _cache: C
    
    public var list: [Location]?
    public var loadMoreItems: (() -> Void)?
    public var showLoading: Bool?
    public var showEmpty: Bool?
    
    public weak var delegate: LocationAdapterDelegate?
    
    public init(cache: C) {
        _cache = cache
        
        super.init()
    }
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! LocationCell
        
        cell.location = list?[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let location = list?[indexPath.row] else { return }
        
         _cache.put(model: location)
        
        delegate?.locationTapped(location)
    }
}

extension LocationAdapter: SkeletonTableViewDataSource {
    
    public func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return identifier
    }
}
