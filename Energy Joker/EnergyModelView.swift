import WebKit
import SwiftUI

struct EnergyWebStage: UIViewRepresentable {
    @ObservedObject var viewModel: EnergyViewModel

    class Coordinator: NSObject {
        var handler: EnergyNavigationHandler
        init(handler: EnergyNavigationHandler) {
            self.handler = handler
        }
    }

    func makeCoordinator() -> Coordinator {
        let handler = EnergyNavigationHandler()
        handler.onStateChange = { [weak viewModel] state in
            viewModel?.energyStatus = state
        }
        return Coordinator(handler: handler)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = EnergyColor(rgb: "#141f2b")
        clearWebData()
        webView.navigationDelegate = context.coordinator.handler
        viewModel.attachWebView(webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        clearWebData()
    }

    private func clearWebData() {
        let types: Set<String> = [
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache
        ]
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast) {}
    }
}
