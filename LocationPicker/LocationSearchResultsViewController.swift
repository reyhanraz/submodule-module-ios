//
//  LocationSearchResultsViewController.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import MapKit
import CommonUI

class LocationSearchResultsViewController: UITableViewController {
    var locations: [Location] = []
    var onSelectLocation: ((Location) -> ())?
    var isShowingHistory = false
    var searchHistoryLabel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            automaticallyAdjustsScrollViewInsets = false
            tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isShowingHistory ? searchHistoryLabel : nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "LocationCell")
        
        let location = locations[indexPath.row]
        
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.address
        cell.detailTextLabel?.textColor = UIColor.BeautyBell.gray500
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectLocation?(locations[indexPath.row])
    }
}
