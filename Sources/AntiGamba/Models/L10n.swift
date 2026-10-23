import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case english = "en"
    case spanish = "es"
    
    public var id: String { rawValue }
    
    @MainActor
    public var displayName: String {
        switch self {
        case .system: return L10n.isSpanish ? "Automático (Sistema)" : "Auto (System)"
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}

@MainActor
public enum L10n {
    public static var isSpanish: Bool {
        let lang = AppSettings.shared.selectedLanguage
        if lang == .spanish { return true }
        if lang == .english { return false }
        
        // Detección automática por sistema
        let preferred = Locale.preferredLanguages.first ?? Locale.current.identifier
        return preferred.lowercased().hasPrefix("es")
    }
    
    // Fases y Estados
    public static func title(for state: PostureState) -> String {
        switch state {
        case .sitting: return isSpanish ? "Sentado" : "Sitting"
        case .standing: return isSpanish ? "De pie" : "Standing"
        case .moving: return isSpanish ? "Moviéndote" : "Moving"
        }
    }
    
    public static func actionTitle(for state: PostureState) -> String {
        switch state {
        case .sitting: return isSpanish ? "Trabajo sentado" : "Sitting focus"
        case .standing: return isSpanish ? "Trabajo de pie" : "Standing desk"
        case .moving: return isSpanish ? "Pausa activa" : "Active break"
        }
    }
    
    public static func description(for state: PostureState) -> String {
        switch state {
        case .sitting:
            return isSpanish
                ? "Enfócate en tu código o tarea sentado con buena postura."
                : "Focus on your tasks with good, upright posture."
        case .standing:
            return isSpanish
                ? "Sube tu escritorio elevable y trabaja de pie."
                : "Raise your desk and continue working while standing."
        case .moving:
            return isSpanish
                ? "Aléjate de la pantalla: camina, estira o toma agua."
                : "Step away from the screen: stretch, hydrate, or walk."
        }
    }
    
    // Alertas Modales
    public static func alertTitle(for target: PostureState) -> String {
        switch target {
        case .standing:
            return isSpanish ? "¡Momento de ponerte de pie! 🧍" : "Time to stand up! 🧍"
        case .moving:
            return isSpanish ? "¡A despejarse y moverse! 🚶" : "Time to move & stretch! 🚶"
        case .sitting:
            return isSpanish ? "¡A sentarse a trabajar! 🪑" : "Ready to sit down! 🪑"
        }
    }
    
    public static func alertMessage(for target: PostureState) -> String {
        switch target {
        case .standing:
            return isSpanish
                ? "Llevas 40 minutos sentado. Desgámbiate, sube tu escritorio y trabaja 15 minutos parado."
                : "You've been sitting for 40 minutes. Stop shrimping, raise your desk, and work standing for 15 minutes."
        case .moving:
            return isSpanish
                ? "¡Gran bloque de pie! Tómate 3 minutos para caminar, estirar la espalda o tomar agua."
                : "Great standing block! Take 3 minutes to walk, stretch your back, or drink water."
        case .sitting:
            return isSpanish
                ? "¡Cuerpo reactivado! Baja tu escritorio y concéntrate 40 minutos sentado."
                : "Body refreshed! Lower your desk and focus on sitting work."
        }
    }
    
    public static func startAction(for target: PostureState, minutes: Int) -> String {
        let action = actionTitle(for: target)
        return isSpanish ? "Empezar \(action) (\(minutes)m)" : "Start \(action) (\(minutes)m)"
    }
    
    // Botones y Etiquetas
    public static var start: String { isSpanish ? "Iniciar" : "Start" }
    public static var pause: String { isSpanish ? "Pausar" : "Pause" }
    public static var skip: String { isSpanish ? "Saltar" : "Skip" }
    public static var postpone5m: String { isSpanish ? "Posponer 5m" : "Postpone 5m" }
    public static var cyclesToday: String { isSpanish ? "Ciclos hoy:" : "Cycles today:" }
    public static var testAlert: String { isSpanish ? "Probar Alerta" : "Test Alert" }
    public static var settings: String { isSpanish ? "Configuración" : "Settings" }
    public static var sittingLabel: String { isSpanish ? "🦐 Sentado:" : "🦐 Sitting:" }
    public static var standingLabel: String { isSpanish ? "🧍 De pie:" : "🧍 Standing:" }
    public static var movingLabel: String { isSpanish ? "🚶 Moverse:" : "🚶 Moving:" }
    public static var soundLabel: String { isSpanish ? "🔔 Sonido:" : "🔔 Alert Sound:" }
    public static var silentSound: String { isSpanish ? "Silencioso" : "Silent" }
    public static var compactMode: String { isSpanish ? "Modo compacto (solo icono)" : "Compact mode (icon only)" }
    public static var launchAtLogin: String { isSpanish ? "Iniciar con macOS" : "Launch at login" }
    public static var languageLabel: String { isSpanish ? "🌐 Idioma:" : "🌐 Language:" }
    public static var quit: String { isSpanish ? "Salir de AntiGamba" : "Quit AntiGamba" }
}
