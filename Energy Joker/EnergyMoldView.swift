import SwiftUI
import Combine
import WebKit

// MARK: - Протоколы

/// Протокол для управления состоянием веб-загрузки
protocol EnergyWebLoadable: AnyObject {
    var energyState: EnergyWebStatus { get set }
    func setEnergyConnectivity(_ available: Bool)
}

/// Протокол для мониторинга прогресса загрузки
protocol EnergyProgressMonitoring {
    func observeEnergyProgression()
    func monitor(_ webView: WKWebView)
}

// MARK: - Основной загрузчик веб-представления

/// Класс для управления загрузкой и состоянием веб-представления
final class EnergyWebLoader: NSObject, ObservableObject, EnergyWebLoadable, EnergyProgressMonitoring {
    // MARK: - Свойства
    
    @Published var energyState: EnergyWebStatus = .energyStandby
    
    let energyResource: URL
    private var energyCancellables = Set<AnyCancellable>()
    private var energyProgressPublisher = PassthroughSubject<Double, Never>()
    private var energyWebViewProvider: (() -> WKWebView)?
    
    // MARK: - Инициализация
    
    init(energyResourceURL: URL) {
        self.energyResource = energyResourceURL
        super.init()
        observeEnergyProgression()
    }
    
    // MARK: - Публичные методы
    
    /// Привязка веб-представления к загрузчику
    func attachEnergyWebView(factory: @escaping () -> WKWebView) {
        energyWebViewProvider = factory
        triggerEnergyLoad()
    }
    
    /// Установка доступности подключения
    func setEnergyConnectivity(_ available: Bool) {
        switch (available, energyState) {
        case (true, .energyNoConnection):
            triggerEnergyLoad()
        case (false, _):
            energyState = .energyNoConnection
        default:
            break
        }
    }
    
    // MARK: - Приватные методы загрузки
    
    /// Запуск загрузки веб-представления
    private func triggerEnergyLoad() {
        guard let webView = energyWebViewProvider?() else { return }
        
        let request = URLRequest(url: energyResource, timeoutInterval: 12)
        energyState = .energyProgressing(progress: 0)
        
        webView.navigationDelegate = self
        webView.load(request)
        monitor(webView)
    }
    
    // MARK: - Методы мониторинга
    
    /// Наблюдение за прогрессом загрузки
    func observeEnergyProgression() {
        energyProgressPublisher
            .removeDuplicates()
            .sink { [weak self] progress in
                guard let self else { return }
                self.energyState = progress < 1.0 ? .energyProgressing(progress: progress) : .energyFinished
            }
            .store(in: &energyCancellables)
    }
    
    /// Мониторинг прогресса веб-представления
    func monitor(_ webView: WKWebView) {
        webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] progress in
                self?.energyProgressPublisher.send(progress)
            }
            .store(in: &energyCancellables)
    }
}

// MARK: - Расширение для обработки навигации

extension EnergyWebLoader: WKNavigationDelegate {
    /// Обработка ошибок при навигации
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleEnergyNavigationError(error)
    }
    
    /// Обработка ошибок при provisional навигации
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleEnergyNavigationError(error)
    }
    
    // MARK: - Приватные методы обработки ошибок
    
    /// Обобщенный метод обработки ошибок навигации
    private func handleEnergyNavigationError(_ error: Error) {
        energyState = .energyFailure(reason: error.localizedDescription)
    }
}

// MARK: - Расширения для улучшения функциональности

extension EnergyWebLoader {
    /// Создание загрузчика с безопасным URL
    convenience init?(energyURLString: String) {
        guard let url = URL(string: energyURLString) else { return nil }
        self.init(energyResourceURL: url)
    }
}
