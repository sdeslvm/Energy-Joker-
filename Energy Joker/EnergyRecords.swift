import Foundation

// MARK: - Протоколы и расширения

/// Протокол для статусов с возможностью сравнения
protocol EnergyWebStatusComparable {
    func isEquivalent(to other: Self) -> Bool
}

// MARK: - Улучшенное перечисление статусов

/// Перечисление статусов веб-соединения с расширенной функциональностью
enum EnergyWebStatus: Equatable, EnergyWebStatusComparable {
    case energyStandby
    case energyProgressing(progress: Double)
    case energyFinished
    case energyFailure(reason: String)
    case energyNoConnection
    
    // MARK: - Пользовательские методы сравнения
    
    /// Проверка эквивалентности статусов с точным сравнением
    func isEquivalent(to other: EnergyWebStatus) -> Bool {
        switch (self, other) {
        case (.energyStandby, .energyStandby), 
             (.energyFinished, .energyFinished), 
             (.energyNoConnection, .energyNoConnection):
            return true
        case let (.energyProgressing(a), .energyProgressing(b)):
            return abs(a - b) < 0.0001
        case let (.energyFailure(reasonA), .energyFailure(reasonB)):
            return reasonA == reasonB
        default:
            return false
        }
    }
    
    // MARK: - Вычисляемые свойства
    
    /// Текущий прогресс подключения
    var energyProgress: Double? {
        guard case let .energyProgressing(value) = self else { return nil }
        return value
    }
    
    /// Индикатор успешного завершения
    var isEnergySuccessful: Bool {
        switch self {
        case .energyFinished: return true
        default: return false
        }
    }
    
    /// Индикатор наличия ошибки
    var hasEnergyError: Bool {
        switch self {
        case .energyFailure, .energyNoConnection: return true
        default: return false
        }
    }
}

// MARK: - Расширения для улучшения функциональности

extension EnergyWebStatus {
    /// Безопасное извлечение причины ошибки
    var energyErrorReason: String? {
        guard case let .energyFailure(reason) = self else { return nil }
        return reason
    }
}

// MARK: - Кастомная реализация Equatable

extension EnergyWebStatus {
    static func == (lhs: EnergyWebStatus, rhs: EnergyWebStatus) -> Bool {
        lhs.isEquivalent(to: rhs)
    }
}
