import Foundation
import SwiftUI
import WebKit

// MARK: - Протоколы

/// Протокол для состояний загрузки с расширенной функциональностью
protocol EnergyWebLoadStateRepresentable {
    var type: EnergyWebLoadState.EnergyStateType { get }
    var percent: Double? { get }
    var error: String? { get }
    
    func isEqual(to other: Self) -> Bool
}

// MARK: - Улучшенная структура состояния загрузки

/// Структура для представления состояний веб-загрузки
struct EnergyWebLoadState: Equatable, EnergyWebLoadStateRepresentable {
    // MARK: - Перечисление типов состояний
    
    /// Типы состояний загрузки с порядковым номером
    enum EnergyStateType: Int, CaseIterable {
        case energyIdle = 0
        case energyProgress
        case energySuccess
        case energyError
        case energyOffline
        
        /// Человекочитаемое описание состояния
        var energyDescription: String {
            switch self {
            case .energyIdle: return "Ожидание"
            case .energyProgress: return "Загрузка"
            case .energySuccess: return "Успешно"
            case .energyError: return "Ошибка"
            case .energyOffline: return "Нет подключения"
            }
        }
    }
    
    // MARK: - Свойства
    
    let type: EnergyStateType
    let percent: Double?
    let error: String?
    
    // MARK: - Статические конструкторы
    
    /// Создание состояния простоя
    static func energyIdle() -> EnergyWebLoadState {
        EnergyWebLoadState(type: .energyIdle, percent: nil, error: nil)
    }
    
    /// Создание состояния прогресса
    static func energyProgress(_ percent: Double) -> EnergyWebLoadState {
        EnergyWebLoadState(type: .energyProgress, percent: percent, error: nil)
    }
    
    /// Создание состояния успеха
    static func energySuccess() -> EnergyWebLoadState {
        EnergyWebLoadState(type: .energySuccess, percent: nil, error: nil)
    }
    
    /// Создание состояния ошибки
    static func energyError(_ err: String) -> EnergyWebLoadState {
        EnergyWebLoadState(type: .energyError, percent: nil, error: err)
    }
    
    /// Создание состояния отсутствия подключения
    static func energyOffline() -> EnergyWebLoadState {
        EnergyWebLoadState(type: .energyOffline, percent: nil, error: nil)
    }
    
    // MARK: - Методы сравнения
    
    /// Пользовательская реализация сравнения
    func isEqual(to other: EnergyWebLoadState) -> Bool {
        guard type == other.type else { return false }
        
        switch type {
        case .energyProgress:
            return percent == other.percent
        case .energyError:
            return error == other.error
        default:
            return true
        }
    }
    
    // MARK: - Реализация Equatable
    
    static func == (lhs: EnergyWebLoadState, rhs: EnergyWebLoadState) -> Bool {
        lhs.isEqual(to: rhs)
    }
}

// MARK: - Расширения для улучшения функциональности

extension EnergyWebLoadState {
    /// Проверка текущего состояния
    var isEnergyLoading: Bool {
        type == .energyProgress
    }
    
    /// Проверка успешного состояния
    var isEnergySuccessful: Bool {
        type == .energySuccess
    }
    
    /// Проверка состояния ошибки
    var hasEnergyError: Bool {
        type == .energyError
    }
}

// MARK: - Расширение для отладки

extension EnergyWebLoadState: CustomStringConvertible {
    var description: String {
        switch type {
        case .energyProgress:
            return "\(type.energyDescription) (\(percent?.formatted() ?? "0")%)"
        case .energyError:
            return "\(type.energyDescription) (\(error ?? "Неизвестная ошибка"))"
        default:
            return "Состояние: \(type.energyDescription)"
        }
    }
}

