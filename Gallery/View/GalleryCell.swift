//
//  GalleryCell.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import RxSwift
import CommonUI
import Nuke
import NVActivityIndicatorView

public protocol GalleryCellDelegate: class {
    func onLongPressed(gallery: Gallery)
}

public class GalleryCell: BaseCollectionViewCell {
    private let _disposeBag = DisposeBag()
    
    weak var delegate: GalleryCellDelegate?
    
    let imgGallery: UIImageView = {
        let v = UIImageView()
        
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor.BeautyBell.gray200
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isSkeletonable = true
        
        return v
    }()
    
    let loadingView: NVActivityIndicatorView = {
        let v = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .white)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        return v
    }()
    
    let imgChecked: UIImageView = {
        let v = UIImageView(image: UIImage(named: "Checked", bundle: GalleryCell.self))
        
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        return v
    }()
    
    let imgReload: UIImageView = {
        let v = UIImageView(image: UIImage(named: "Reload", bundle: GalleryCell.self))
        
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        return v
    }()
    
    let lblStatus: PaddingLabel = {
        let v = PaddingLabel()
        
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.font = regularBody3
        v.textColor = .white
        v.textAlignment = .center
        v.topInset = 2
        v.bottomInset = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        return v
    }()
    
    lazy var background: UIView = {
        let v = UIView()
        
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    lazy var loadingBackground: UIView = {
        let v = UIView()
        
        v.addSubview(loadingView)
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.clipsToBounds = true
        v.layer.cornerRadius = 5
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    var gallery: Gallery? {
        didSet {
            guard let gallery = gallery else { return }
            
            setGallery(gallery)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        contentView.addSubview(imgGallery)
        contentView.addSubview(loadingBackground)
        contentView.addSubview(background)
        contentView.addSubview(lblStatus)
        contentView.addSubview(imgReload)
        contentView.addSubview(imgChecked)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        
        contentView.addGestureRecognizer(gesture)
        
        NSLayoutConstraint.activate([
            imgGallery.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imgGallery.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imgGallery.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgGallery.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingBackground.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingBackground.widthAnchor.constraint(equalToConstant: 50),
            loadingBackground.heightAnchor.constraint(equalToConstant: 50),
            
            loadingView.leadingAnchor.constraint(equalTo: loadingBackground.leadingAnchor, constant: 10),
            loadingView.trailingAnchor.constraint(equalTo: loadingBackground.trailingAnchor, constant: -10),
            loadingView.topAnchor.constraint(equalTo: loadingBackground.topAnchor, constant: 10),
            loadingView.bottomAnchor.constraint(equalTo: loadingBackground.bottomAnchor, constant: -10),
            
            lblStatus.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lblStatus.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lblStatus.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imgReload.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imgReload.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imgReload.widthAnchor.constraint(equalToConstant: 30),
            imgReload.heightAnchor.constraint(equalToConstant: 30),
            
            background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            background.topAnchor.constraint(equalTo: contentView.topAnchor),
            background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imgChecked.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imgChecked.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imgChecked.widthAnchor.constraint(equalToConstant: 20),
            imgChecked.heightAnchor.constraint(equalToConstant: 20)
            
        ])
    }
    
    // MARK: - Selector
    @objc func longPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard
            let gallery = gallery,
            gestureRecognizer.state == .began else {
            return
        }
        
        delegate?.onLongPressed(gallery: gallery)
    }
    
    // MARK: - Private
    private func setGallery(_ gallery: Gallery) {
        imgGallery.loadMedia(url: gallery.media.small)
    
        loadingView.stopAnimating()
        loadingBackground.isHidden = true
        lblStatus.isHidden = true
        background.isHidden = true
        imgChecked.isHidden = true
        imgReload.isHidden = true
        
        if gallery.uploadStatus == .uploading {
            loadingView.startAnimating()
            loadingBackground.isHidden = false
            lblStatus.isHidden = false
            lblStatus.text = "uploading...".l10n()
        } else if gallery.uploadStatus == .waiting {
            lblStatus.isHidden = false
            lblStatus.text = "waiting".l10n()
        } else if gallery.uploadStatus == .failed {
            lblStatus.isHidden = false
            lblStatus.text = "failed".l10n()
            
            imgReload.isHidden = false
            
            background.isHidden = false
            background.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        }
        
        if gallery.checked && gallery.uploadStatus == .success {
            imgChecked.isHidden = false
            
            background.isHidden = false
            background.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
}


