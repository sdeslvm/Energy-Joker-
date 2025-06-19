import SwiftUI
import WebKit

// MARK: - Протоколы и расширения

/// Протокол для создания градиентных представлений
protocol EnergyGradientProviding {
    func createEnergyGradientLayer() -> CAGradientLayer
}

// MARK: - Улучшенный контейнер с градиентом

/// Кастомный контейнер с градиентным фоном
final class EnergyGradientContainerView: UIView, EnergyGradientProviding {
    // MARK: - Приватные свойства
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Методы настройки
    
    private func setupView() {
        layer.insertSublayer(createEnergyGradientLayer(), at: 0)
    }
    
    /// Создание градиентного слоя
    func createEnergyGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#1BD8FD").cgColor,
            UIColor(hex: "#0FC9FA").cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }
    
    // MARK: - Обновление слоя
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Расширения для цветов

extension UIColor {
    /// Инициализатор цвета из HEX-строки с улучшенной обработкой
    convenience init(hex energyHexRepresentation: String) {
        let sanitizedHex = energyHexRepresentation
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()
        
        var colorValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
        
        let redComponent = CGFloat((colorValue & 0xFF0000) >> 16) / 255.0
        let greenComponent = CGFloat((colorValue & 0x00FF00) >> 8) / 255.0
        let blueComponent = CGFloat(colorValue & 0x0000FF) / 255.0
        
        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
}

// MARK: - Представление веб-вида

struct EnergyWebViewBox: UIViewRepresentable {
    // MARK: - Свойства
    
    @ObservedObject var loader: EnergyWebLoader
    
    // MARK: - Координатор
    
    func makeCoordinator() -> EnergyWebCoordinator {
        EnergyWebCoordinator { [weak loader] status in
            DispatchQueue.main.async {
                loader?.energyState = status
            }
        }
    }
    
    // MARK: - Создание представления
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = createEnergyWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        setupEnergyWebViewAppearance(webView)
        setupEnergyContainerView(with: webView)
        
        webView.navigationDelegate = context.coordinator
        loader.attachEnergyWebView { webView }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Here you can update the WKWebView as needed, e.g., reload content when the loader changes.
        // For now, this can be left empty or you can update it as per loader's energyState if needed.
    }
    
    // MARK: - Приватные методы настройки
    
    private func createEnergyWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        return configuration
    }
    
    private func setupEnergyWebViewAppearance(_ webView: WKWebView) {
        webView.backgroundColor = .clear
        webView.isOpaque = false
    }
    
    private func setupEnergyContainerView(with webView: WKWebView) {
        let containerView = EnergyGradientContainerView()
        containerView.addSubview(webView)
        
        webView.frame = containerView.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func clearEnergyWebsiteData() {
        let dataTypes: Set<String> = [
            .diskCache,
            .memoryCache,
            .cookies,
            .localStorage
        ]
        
        WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes,
            modifiedSince: .distantPast
        ) {}
    }
}

// MARK: - Расширение для типов данных

extension String {
    static let diskCache = WKWebsiteDataTypeDiskCache
    static let memoryCache = WKWebsiteDataTypeMemoryCache
    static let cookies = WKWebsiteDataTypeCookies
    static let localStorage = WKWebsiteDataTypeLocalStorage
}

