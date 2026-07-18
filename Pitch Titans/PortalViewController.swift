import UIKit
import WebKit

final class PortalViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let address: String
    private let contentView: WKWebView
    private let loadingView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var isInitialLoad = true

    init(address: String) {
        self.address = address
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        contentView = WKWebView(frame: .zero, configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .allButUpsideDown
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureContent()
        configureLoading()
        loadAddress()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsUpdateOfSupportedInterfaceOrientations()
        view.window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .allButUpsideDown)) { _ in }
    }

    private func configureContent() {
        contentView.navigationDelegate = self
        contentView.uiDelegate = self
        contentView.scrollView.contentInsetAdjustmentBehavior = .never
        contentView.allowsBackForwardNavigationGestures = true
        contentView.isOpaque = false
        contentView.backgroundColor = .black
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureLoading() {
        loadingView.backgroundColor = .black
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(activityIndicator)
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }

    private func loadAddress() {
        guard let link = URL(string: address) else { return }
        var request = URLRequest(url: link)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        contentView.load(request)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard isInitialLoad else { return }
        isInitialLoad = false
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            self.loadingView.alpha = 0
        } completion: { _ in
            self.loadingView.removeFromSuperview()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideInitialLoaderIfNeeded()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideInitialLoaderIfNeeded()
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    private func hideInitialLoaderIfNeeded() {
        guard isInitialLoad else { return }
        isInitialLoad = false
        activityIndicator.stopAnimating()
        loadingView.removeFromSuperview()
    }
}
