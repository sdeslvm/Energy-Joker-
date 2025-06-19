import WebKit
import Foundation

class EnergyWebCoordinator: NSObject, WKNavigationDelegate {
    private let callback: (EnergyWebStatus) -> Void
    private var didStart = false

    init(onStatus: @escaping (EnergyWebStatus) -> Void) {
        self.callback = onStatus
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !didStart { callback(.energyProgressing(progress: 0.0)) }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        didStart = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        callback(.energyFinished)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        callback(.energyFailure(reason: error.localizedDescription))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        callback(.energyFailure(reason: error.localizedDescription))
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other && webView.url != nil {
            didStart = true
        }
        decisionHandler(.allow)
    }
}
