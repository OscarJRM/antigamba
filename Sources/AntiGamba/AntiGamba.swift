import SwiftUI
import AppKit

@main
struct AntiGambaApp: App {
    @StateObject private var cycleManager = CycleManager()
    
    init() {
        if CommandLine.arguments.contains("--snapshot") {
            generateSnapshots()
            exit(0)
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(cycleManager: cycleManager)
        } label: {
            Text("\(cycleManager.currentState.emoji) \(cycleManager.formattedRemainingTime)")
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
    
    @MainActor
    private func generateSnapshots() {
        let manager = CycleManager()
        
        // 1. Snapshot del Menu Bar Popover en Dark Mode
        let menuView = MenuBarView(cycleManager: manager)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.12, green: 0.13, blue: 0.16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 24, x: 0, y: 12)
            .padding(20)
            .environment(\.colorScheme, .dark)
            .preferredColorScheme(.dark)
        
        saveView(menuView, to: "assets/menubar-preview.png")
        
        // 2. Snapshot del Modal Flotante en Dark Mode
        let modalView = AlertModalView(
            targetState: .standing,
            onStart: {},
            onPostpone: { _ in },
            onSkip: {}
        )
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.12, green: 0.13, blue: 0.16))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 24, x: 0, y: 12)
        .padding(24)
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
        
        saveView(modalView, to: "assets/modal-preview.png")
        print("✔ Snapshots generados con éxito en assets/")
    }
    
    @MainActor
    private func saveView<V: View>(_ view: V, to relativePath: String) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0 // Retina 2x
        
        if let image = renderer.nsImage,
           let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            let url = URL(fileURLWithPath: relativePath)
            do {
                try pngData.write(to: url)
                print("Guardado: \(relativePath) (\(Int(image.size.width))x\(Int(image.size.height)))")
            } catch {
                print("Error guardando \(relativePath): \(error)")
            }
        } else {
            print("No se pudo renderizar la imagen para \(relativePath)")
        }
    }
}
