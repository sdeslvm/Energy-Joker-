import WebKit

class EnergyNavigationHandler: NSObject, WKNavigationDelegate {
    var onStateChange: ((EnergyState) -> Void)?

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onStateChange?(.loading(0.0))
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {}

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onStateChange?(.completed)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onStateChange?(.failed(error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onStateChange?(.failed(error))
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
