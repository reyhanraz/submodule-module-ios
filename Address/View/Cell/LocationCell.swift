//
//  LocationCell.swift
//  Address
//
//  Created by Fandy Gotama on 29/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI

public class LocationCell: BaseTableViewCell {
    
    let lblProvinceName: UILabel = {
        let v = UILabel()
        
        v.text = "              "
        v.isSkeletonable = true
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblDistrictName: UILabel = {
        let v = UILabel()
        
        v.text = "                           "
        v.isSkeletonable = true
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblSubDistrictName: UILabel = {
        let v = UILabel()
        
        v.text = "                                        "
        v.isSkeletonable = true
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblPostalCode: UILabel = {
        let v = UILabel()
        
        v.text = "            "
        
        v.isSkeletonable = true
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    var location: Location? {
        didSet {
            guard let location = location else { return }
            
            setLocation(location)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lblProvinceName)
        contentView.addSubview(lblDistrictName)
        contentView.addSubview(lblSubDistrictName)
        contentView.addSubview(lblPostalCode)
        
        isSkeletonable = true
        
        NSLayoutConstraint.activate([
            lblSubDistrictName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lblSubDistrictName.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            lblSubDistrictName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            lblDistrictName.leadingAnchor.constraint(equalTo: lblSubDistrictName.leadingAnchor),
            lblDistrictName.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            lblDistrictName.topAnchor.constraint(equalTo: lblSubDistrictName.bottomAnchor, constant: 10),
            
            lblProvinceName.leadingAnchor.constraint(equalTo: lblSubDistrictName.leadingAnchor),
            lblProvinceName.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            lblProvinceName.topAnchor.constraint(equalTo: lblDistrictName.bottomAnchor, constant: 10),
            
            lblPostalCode.leadingAnchor.constraint(equalTo: lblSubDistrictName.leadingAnchor),
            lblPostalCode.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            lblPostalCode.topAnchor.constraint(equalTo: lblProvinceName.bottomAnchor, constant: 10)
        ])
        
    }
    
    private func setLocation(_ location: Location) {
        lblSubDistrictName.text = "\(location.urbanVillageName), \(location.subDistrictName)"
        lblProvinceName.text = location.provinceName
        lblDistrictName.text = location.districtName
        lblPostalCode.text = location.postalCode
    }
}
