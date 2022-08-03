//
//  CheckoutViewController.swift
//  Payment
//
//  Created by Fandy Gotama on 31/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Foundation
import WebKit
import CommonUI

public protocol CheckoutViewControllerDelegate: class {
    func dismissCheckout()
    func checkoutSuccess()
    func checkoutFailed()
}

public class CheckoutViewController: RxRestrictedViewController, WKNavigationDelegate {
    private let _successURL: URL?
    private let _failedURL: URL?
    private let _url: URL
    private let _estimatedProgressKeyPath = "estimatedProgress"
    private var _isDelegateCalled = false

    public weak var delegate: CheckoutViewControllerDelegate?

    lazy var webView: WKWebView = {
        
        // Disable zoom
        let source = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";

        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        let conf = WKWebViewConfiguration()

        conf.userContentController = userContentController

        userContentController.addUserScript(script)

        let v = WKWebView(frame: .zero, configuration: conf)

        v.navigationDelegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        v.scrollView.keyboardDismissMode = .interactive
        
        return v
    }()

    lazy var btnBack: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(named: "Back", bundle: LogoView.self), style: .plain, target: self, action: #selector(goBack))
    }()

    lazy var btnForward: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(named: "Forward", bundle: LogoView.self), style: .plain, target: self, action: #selector(goForward))
    }()

    lazy var toolbar: UIToolbar = {
        let v = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))

        v.items = [btnBack, UIBarButtonItem(title: "  ", style: .plain, target: nil, action: nil), btnForward]
        v.translatesAutoresizingMaskIntoConstraints = false

        return v
    }()

    lazy var progressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .default)

        v.translatesAutoresizingMaskIntoConstraints = false
        v.trackTintColor = UIColor(white: 1, alpha: 0)
        v.progressTintColor = UIColor.BeautyBell.accent

        return v
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public init(successURL: URL?, failedURL: URL?, url: URL) {
        _successURL = successURL
        _failedURL = failedURL
        _url = url

        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: _estimatedProgressKeyPath)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        view.addSubview(toolbar)
        view.addSubview(progressView)

        view.backgroundColor = .white

        webView.addObserver(self, forKeyPath: _estimatedProgressKeyPath, options: .new, context: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "later".l10n(), style: .plain, target: self, action: #selector(dismissedController))

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 1),

            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
        ])

        webView.load(URLRequest(url: _url))
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case _estimatedProgressKeyPath?:
            let estimatedProgress = webView.estimatedProgress

            progressView.alpha = 1
            progressView.setProgress(Float(estimatedProgress), animated: true)

            if estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: {
                    finished in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, navigationAction.navigationType == WKNavigationType.other {
            if url == _successURL {
                decisionHandler(.cancel)

                if _isDelegateCalled { return }

                _isDelegateCalled = true

                delegate?.checkoutSuccess()

                return
            } else if url == _failedURL {
                decisionHandler(.cancel)

                if _isDelegateCalled { return }

                _isDelegateCalled = true

                showAlert(title: "payment_failed_title".l10n(), message: "payment_failed_message".l10n(), completion: nil, okHandler: {
                    self.delegate?.checkoutFailed()
                })

                return
            }
            
            print("TESET: \(url)")
        }

        decisionHandler(.allow)
    }

    // MARK: - Selector
    @objc func dismissedController() {
        delegate?.dismissCheckout()
    }

    @objc func goBack() {
        webView.goBack()
    }

    @objc func goForward() {
        webView.goForward()
    }

}

