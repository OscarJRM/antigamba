import Foundation
import ServiceManagement
import AppKit
import Combine

@MainActor
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    @Published public var isCompactMode: Bool {
        didSet { UserDefaults.standard.set(isCompactMode, forKey: "isCompactMode") }
    }
    
    @Published public var selectedSound: String {
        didSet {
            UserDefaults.standard.set(selectedSound, forKey: "selectedSound")
        }
    }
    
    @Published public var launchAtLogin: Bool {
        didSet {
            updateLaunchAtLogin(launchAtLogin)
        }
    }
    
    public let availableSounds = [
        "Glass",
        "Hero",
        "Ping",
        "Pop",
        "Submarine",
        "Blow",
        "Silencioso"
    ]
    
    private init() {
        self.isCompactMode = UserDefaults.standard.bool(forKey: "isCompactMode")
        self.selectedSound = UserDefaults.standard.string(forKey: "selectedSound") ?? "Glass"
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
    }
    
    public func playSound() {
        guard selectedSound != "Silencioso" else { return }
        if let sound = NSSound(named: selectedSound) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
    
    public func playPreview(soundName: String) {
        selectedSound = soundName
        guard soundName != "Silencioso" else { return }
        NSSound(named: soundName)?.play()
    }
    
    private func updateLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            print("Notice: LaunchAtLogin status change: \(error.localizedDescription)")
        }
    }
}
