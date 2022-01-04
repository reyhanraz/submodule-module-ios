//
//  NewsDetailWebView.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import WebKit

protocol NewsDetailWebViewDelegate: class {
    func urlTapped(url: URL)
}

class NewsDetailWebView: WKWebView, WKNavigationDelegate {
    private var heightConstraint: NSLayoutConstraint!
    
    weak var delegate: NewsDetailWebViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    init() {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
        let viewPortScript = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('maximum-scale', '1.0');
            meta.setAttribute('minimum-scale', '1.0');
            meta.setAttribute('user-scalable', 'no');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        
        let script = WKUserScript(source: viewPortScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        controller.addUserScript(script)
        
        configuration.userContentController = controller
        
        super.init(frame: .zero, configuration: configuration)
        
        self.navigationDelegate = self
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
    }
    
    @discardableResult
    override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        let css = """
            <head>
            <link rel="stylesheet" type="text/css" href="Font.css">
            </head>
        """
        
        return super.loadHTMLString("\(css)\(string)", baseURL: baseURL)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (result, error) in
            if let height = result as? CGFloat {
                self?.heightConstraint.constant = height
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == WKNavigationType.linkActivated {
            decisionHandler(.cancel)
            
            delegate?.urlTapped(url: url)
            
            return
        }
        
        decisionHandler(.allow)
    }
}
