import SwiftUI

struct EnergyScreen: View {
    @StateObject var viewModel: EnergyViewModel

    init(viewModel: EnergyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            EnergyWebStage(viewModel: viewModel)
                .opacity(viewModel.energyStatus == .completed ? 1 : 0)
            overlay
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch viewModel.energyStatus {
        case .loading(let progress):
            EnergyProgressBar().energyProgress(progress)
        case .failed(let error):
            Text("Error: \(error.localizedDescription)").foregroundColor(.pink)
        case .offline:
            Text("Offline").foregroundColor(.gray)
        default:
            EmptyView()
        }
    }
}
