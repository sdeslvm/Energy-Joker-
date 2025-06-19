import SwiftUI
import Foundation

struct EnergyEntryScreen: View {
    @StateObject private var loader: EnergyWebLoader

    init(loader: EnergyWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            EnergyWebViewBox(loader: loader)
                .opacity(loader.energyState == .energyFinished ? 1 : 0.5)
            switch loader.energyState {
            case .energyProgressing(let percent):
                EnergyProgressIndicator(value: percent)
            case .energyFailure(let err):
                EnergyErrorIndicator(err: err)
            case .energyNoConnection:
                EnergyOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct EnergyProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            EnergyLoadingOverlay(energyProgress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct EnergyErrorIndicator: View {
    let err: String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct EnergyOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
