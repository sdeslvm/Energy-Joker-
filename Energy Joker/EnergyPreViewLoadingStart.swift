import SwiftUI

private struct EnergyProgressBarKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
}
extension EnvironmentValues {
    var energyProgress: Double {
        get { self[EnergyProgressBarKey.self] }
        set { self[EnergyProgressBarKey.self] = newValue }
    }
}

struct EnergyProgressBar: View {
    @Environment(\.energyProgress) var progress

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
           
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("Loading")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                EnergyProgressBar.Linear(progress: progress)
                    .frame(height: 12)
                    .padding(.horizontal, 40)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
        }
    }

    struct Linear: View {
        let progress: Double
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .opacity(0.2)
                        .foregroundColor(.white)
                    Rectangle()
                        .frame(width: max(0, CGFloat(min(max(progress, 0), 1)) * geo.size.width), height: geo.size.height)
                        .foregroundColor(.red)
                        .animation(.easeOut(duration: 0.3), value: progress)
                }
                .cornerRadius(6)
            }
        }
    }
}

extension View {
    func energyProgress(_ value: Double) -> some View {
        environment(\.energyProgress, value)
    }
}

#Preview {
    Text("Preview")
        .energyProgress(0.2)
        .overlay(EnergyProgressBar())
}
