import AppKit
import SwiftUI

private final class KeyPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
public final class OverlayManager {
    public static let shared = OverlayManager()
    
    private var alertWindow: NSPanel?
    
    private init() {}
    
    public func showAlert(
        for targetState: PostureState,
        onStart: @escaping () -> Void,
        onPostpone: @escaping (Int) -> Void,
        onSkip: @escaping () -> Void
    ) {
        // Reproducir sonido según configuración del usuario
        AppSettings.shared.playSound()
        
        let modalView = AlertModalView(
            targetState: targetState,
            onStart: { [weak self] in
                self?.dismiss()
                onStart()
            },
            onPostpone: { [weak self] minutes in
                self?.dismiss()
                onPostpone(minutes)
            },
            onSkip: { [weak self] in
                self?.dismiss()
                onSkip()
            }
        )
        
        let hostingView = NSHostingView(rootView: modalView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 400, height: 270)
        
        if alertWindow == nil {
            let panel = KeyPanel(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 270),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.isMovableByWindowBackground = true
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            self.alertWindow = panel
        }
        
        guard let window = alertWindow else { return }
        window.contentView = hostingView
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    public func dismiss() {
        alertWindow?.orderOut(nil)
    }
}
