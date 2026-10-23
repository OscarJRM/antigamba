import AppKit
import SwiftUI

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
        // Reproducir sonido de atención suave del sistema
        if let sound = NSSound(named: "Glass") {
            sound.play()
        } else {
            NSSound.beep()
        }
        
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
        hostingView.frame = NSRect(x: 0, y: 0, width: 420, height: 280)
        
        if alertWindow == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 280),
                styleMask: [.borderless, .nonactivatingPanel],
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
