import SwiftUI

@main
struct AntiGambaApp: App {
    @StateObject private var cycleManager = CycleManager()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(cycleManager: cycleManager)
        } label: {
            HStack(spacing: 3) {
                Text(cycleManager.currentState.emoji)
                Text(cycleManager.formattedRemainingTime)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)
    }
}
