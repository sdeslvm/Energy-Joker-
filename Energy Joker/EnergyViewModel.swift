import WebKit
import SwiftUI
import Combine

final class EnergyViewModel: NSObject, ObservableObject {
    @Published var energyStatus: EnergyState = .idle
    let url: URL
    private var webView: WKWebView?
    private var progressCancellable: AnyCancellable?

    init(url: URL) {
        self.url = url
        super.init()
    }

    func attachWebView(_ webView: WKWebView) {
        self.webView = webView
        webView.navigationDelegate = self
        observeProgress(webView)
        reloadContent()
    }

    func reloadContent() {
        guard let webView = webView else { return }
        
        DispatchQueue.main.async {
            self.energyStatus = .loading(0)
        }
        
        let request = URLRequest(url: url, timeoutInterval: 15)
        webView.load(request)
    }
    
    func setConnection(isOnline: Bool) {
        if isOnline {
            if energyStatus == .offline { reloadContent() }
        } else {
            energyStatus = .offline
        }
    }

    private func observeProgress(_ webView: WKWebView) {
        progressCancellable = webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                guard let self else { return }
                if progress < 1.0 {
                    self.energyStatus = .loading(progress)
                } else {
                    self.energyStatus = .completed
                }
            }
    }
}

extension EnergyViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        energyStatus = .failed(error)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        energyStatus = .failed(error)
    }
}
