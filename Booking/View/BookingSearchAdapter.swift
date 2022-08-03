//
//  BookingSearchAdapter.swift
//  Booking
//
//  Created by Fandy Gotama on 26/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import SkeletonView
import Platform

public protocol BookingSearchAdapterDelegate: class {
    func searchBookingTapped(_ booking: Booking)
}

public class BookingSearchAdapter<C: Cache>: NSObject, UITableViewDelegate, UITableViewDataSource, AdapterType where C.R == BookingListRequest, C.T == Booking {
   
    public typealias Item = Booking
    
    public let identifier = "BookingCell"
    
    let _cache: C
    let _userKind: NewProfile.Kind
    
    public var list: [Booking]?
    public var loadMoreItems: (() -> Void)?
    public var showLoading: Bool?
    public var showEmpty: Bool?
    
    public weak var delegate: BookingSearchAdapterDelegate?
    
    public init(cache: C, kind: NewProfile.Kind) {
        _cache = cache
        _userKind = kind
        
        super.init()
    }
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BookingSearchCell
        
        if let booking = list?[indexPath.row] {
            cell.setBooking(booking: booking, kind: _userKind)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let booking = list?[indexPath.row] else { return }
        
//        _cache.remove(request: BookingListRequest(id: booking.id))
//        
//        _cache.put(model: booking)
//        
//        delegate?.searchBookingTapped(booking)
    }
}

extension BookingSearchAdapter: SkeletonTableViewDataSource {
    
    public func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return identifier
    }
}

