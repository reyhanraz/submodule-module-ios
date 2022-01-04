//
//  NewsCell.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import RxSwift
import CommonUI
import Nuke
import SkeletonView

public class NewsCell: BaseCollectionViewCell {
    private let _disposeBag = DisposeBag()
    
    lazy var imgCover: UIImageView = {
        let v = UIImageView()
        
        v.isSkeletonable = true
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let imgDisclosure: DisclosureIndicator = {
        let v = DisclosureIndicator()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblTitle: UILabel = {
        let v = UILabel()
        
        v.text = "                                                  "
        v.isSkeletonable = true
        v.font = regularBody2
        v.numberOfLines = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblDate: UILabel = {
        let v = UILabel()
        
        v.text = "                 "
        v.isSkeletonable = true
        v.font = regularBody3
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    var news: News? {
        didSet {
            guard let news = news else { return }
            
            setNews(news)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        contentView.addSubview(imgCover)
        contentView.addSubview(lblTitle)
        contentView.addSubview(lblDate)
        contentView.addSubview(imgDisclosure)
        
        NSLayoutConstraint.activate([
            imgCover.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imgCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imgCover.widthAnchor.constraint(equalToConstant: 60),
            imgCover.heightAnchor.constraint(equalToConstant: 60),
            
            lblTitle.topAnchor.constraint(equalTo: imgCover.topAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: imgCover.trailingAnchor, constant: 15),
            lblTitle.trailingAnchor.constraint(lessThanOrEqualTo: imgDisclosure.trailingAnchor, constant: -10),
            
            lblDate.bottomAnchor.constraint(equalTo: imgCover.bottomAnchor),
            lblDate.leadingAnchor.constraint(equalTo: lblTitle.leadingAnchor),
            lblDate.trailingAnchor.constraint(lessThanOrEqualTo: lblTitle.trailingAnchor),

            imgDisclosure.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imgDisclosure.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    
    // MARK: - Private
    private func setNews(_ news: News) {
        
        lblTitle.text = news.title
        lblDate.text = news.updatedAt.toFullDate
        imgCover.loadMedia(url: news.cover.small)
    }
}
