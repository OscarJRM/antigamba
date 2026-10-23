import SwiftUI

public enum PostureState: String, CaseIterable, Codable, Sendable {
    case sitting
    case standing
    case moving
    
    public var emoji: String {
        switch self {
        case .sitting: return "🦐"
        case .standing: return "🧍"
        case .moving: return "🚶"
        }
    }
    
    public var title: String {
        switch self {
        case .sitting: return "Sentado"
        case .standing: return "De pie"
        case .moving: return "Moviéndote"
        }
    }
    
    public var actionTitle: String {
        switch self {
        case .sitting: return "Trabajo sentado"
        case .standing: return "Trabajo de pie"
        case .moving: return "Pausa activa"
        }
    }
    
    public var description: String {
        switch self {
        case .sitting:
            return "Enfócate en tu código o tarea sentado con buena postura."
        case .standing:
            return "Sube tu escritorio elevable y trabaja de pie."
        case .moving:
            return "Aléjate de la pantalla: camina, estira o toma agua."
        }
    }
    
    public var next: PostureState {
        switch self {
        case .sitting: return .standing
        case .standing: return .moving
        case .moving: return .sitting
        }
    }
    
    public var defaultDurationMinutes: Int {
        switch self {
        case .sitting: return 40
        case .standing: return 15
        case .moving: return 3
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .sitting: return .orange
        case .standing: return .blue
        case .moving: return .green
        }
    }
    
    public var alertTitle: String {
        switch self {
        case .standing: return "¡Momento de ponerte de pie! 🧍"
        case .moving: return "¡A despejarse y moverse! 🚶"
        case .sitting: return "¡A sentarse a trabajar! 🪑"
        }
    }
    
    public var alertMessage: String {
        switch self {
        case .standing:
            return "Llevas 40 minutos sentado. Desgámbiate, sube tu escritorio y trabaja 15 minutos parado."
        case .moving:
            return "¡Gran bloque de pie! Tómate 3 minutos para caminar, estirar la espalda o tomar agua."
        case .sitting:
            return "¡Cuerpo reactivado! Baja tu escritorio y concéntrate 40 minutos sentado."
        }
    }
}
