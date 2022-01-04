//
//  NewsDetailViewController.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Domain
import Platform
import WebKit
import Lightbox

public class NewsDetailViewController: RxRestrictedViewController, NewsDetailWebViewDelegate {
    private let _news: News?
    
    private var _showNavigationWhenDisappear = true
    
    private var _popRecognizer: InteractivePopRecognizer?
    
    let imgCover: UIImageView = {
        let v = UIImageView()
        
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        
        return v
    }()
    
    let lblDate: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray500
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    let lblTitle: UILabel = {
        let v = UILabel()
        
        v.font = regularBody2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        
        return v
    }()
    
    let lblSummary: UILabel = {
        let v = UILabel()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        v.font = regularBody2
        v.textColor = UIColor.BeautyBell.gray700
        
        return v
    }()
    
    lazy var webView: NewsDetailWebView = {
        let v = NewsDetailWebView()
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0.0
        v.delegate = self
        
        return v
    }()
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        
        v.addSubview(lblDate)
        v.addSubview(lblTitle)
        v.addSubview(imgCover)
        v.addSubview(lblSummary)
        v.addSubview(webView)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private lazy var _getViewModel: ViewModel<ListRequest, NewsDetail> = {
        let delegate = UIApplication.shared.delegate as! AppDelegateType
        
        let cache = NewsSQLCache(dbQueue: delegate.dbQueue)
        
        let useCase = NewsDetailUseCaseProvider(
            service: NewsCloudService<NewsDetail>(),
            cache: cache,
            activityIndicator: activityIndicator)
        
        return ViewModel<ListRequest, NewsDetail>(useCase: useCase)
        
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    public init(news: News) {
        _news = news
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(coverTapped))
        
        imgCover.addGestureRecognizer(gesture)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            
            lblDate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            lblDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            lblDate.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            
            lblTitle.leadingAnchor.constraint(equalTo: lblDate.leadingAnchor),
            lblTitle.trailingAnchor.constraint(equalTo: lblDate.trailingAnchor),
            lblTitle.topAnchor.constraint(equalTo: lblDate.bottomAnchor, constant: 15),
            
            imgCover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imgCover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imgCover.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 15),
            imgCover.heightAnchor.constraint(equalToConstant: 200),
            
            webView.leadingAnchor.constraint(equalTo: lblDate.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: lblDate.trailingAnchor),
            webView.topAnchor.constraint(equalTo: imgCover.bottomAnchor, constant: 15),
            
            lblSummary.leadingAnchor.constraint(equalTo: lblDate.leadingAnchor),
            lblSummary.trailingAnchor.constraint(equalTo: lblDate.trailingAnchor),
            lblSummary.topAnchor.constraint(equalTo: imgCover.bottomAnchor, constant: 15),
            
            lblSummary.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor),
            
            webView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
        
        let id: Int
        
        if let news = _news {
            id = news.id
            
            setDetail(news)
        } else {
            id = 0
        }
        
        rxBinding()
        
        if _news?.content == nil {
            _getViewModel.execute(request: ListRequest(id: id))
        }
        
    }
    
    // MARK: - Selector
    @objc func coverTapped() {
        guard let news = _news else { return }
        
        let image = LightboxImage(imageURL: news.cover.large, text: "\(news.title)\n\n\(news.summary)")
        
        let controller = LightboxController(images: [image])
        
        controller.dynamicBackground = true
        controller.modalPresentationStyle = .fullScreen
        
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - NewsDetailWebViewDelegate
    func urlTapped(url: URL) {
        let controller = WebViewController(url: url)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - RxBinding
    private func rxBinding() {
        _getViewModel.result.drive(onNext: { [weak self] news in
            guard
                let strongSelf = self,
                let content = news.1.data?.news.content
                else { return }
            
            strongSelf.loadContent(content)
            
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Private
    private func setDetail(_ news: News) {
        lblDate.text = news.updatedAt.toFullDate
        lblTitle.text = news.title
        lblSummary.text = news.summary
        imgCover.loadMedia(url: news.cover.medium)
        
        if let content = news.content {
            loadContent(content)
        }
    }
    
    private func loadContent(_ content: String) {
        let bundle = Bundle(for: NewsDetailViewController.self)
        let path = bundle.path(forResource: "Font", ofType: "css")
        
        let baseURL = URL(fileURLWithPath: path!)
        
        webView.loadHTMLString(content, baseURL: baseURL)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.webView.alpha = 1.0
        }, completion: nil)
    }
}
