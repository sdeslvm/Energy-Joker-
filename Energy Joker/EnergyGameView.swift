import Foundation
import SwiftUI

final class EnergyColor: UIColor {
    convenience init(rgb: String) {
        let clean = rgb.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

@ViewBuilder
func launchEnergy() -> some View {
    let viewModel = makeEnergyViewModel()
    EnergyScreen(viewModel: viewModel)
        .background(Color(EnergyColor(rgb: "#0A1FA2")))
}

private func makeEnergyViewModel() -> EnergyViewModel {
    EnergyViewModel(url: URL(string: "https://energyjoker.top/get")!)
}

struct EnergyEntry: View {
    var body: some View {
        launchEnergy()
    }
}

#Preview {
    EnergyEntry()
}
