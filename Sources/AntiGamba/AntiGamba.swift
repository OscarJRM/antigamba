import SwiftUI

@main
struct AntiGambaApp: App {
    @StateObject private var cycleManager = CycleManager()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(cycleManager: cycleManager)
        } label: {
            Text("\(cycleManager.currentState.emoji) \(cycleManager.formattedRemainingTime)")
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}
