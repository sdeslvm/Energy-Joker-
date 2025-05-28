import Foundation

enum EnergyState: Equatable {
    case idle
    case loading(Double)
    case completed
    case failed(Error)
    case offline

    static func == (lhs: EnergyState, rhs: EnergyState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.completed, .completed), (.offline, .offline):
            return true
        case (.loading(let lp), .loading(let rp)):
            return lp == rp
        case (.failed, .failed):
            return true // Ошибки не сравниваем по содержимому
        default:
            return false
        }
    }
}

