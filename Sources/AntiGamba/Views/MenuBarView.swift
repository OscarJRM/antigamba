import SwiftUI

public struct MenuBarView: View {
    @ObservedObject public var cycleManager: CycleManager
    @State private var showSettings = false
    
    public init(cycleManager: CycleManager) {
        self.cycleManager = cycleManager
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Text("🦐")
                        .font(.title2)
                    Text("AntiGamba")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text(cycleManager.currentState.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(cycleManager.currentState.accentColor.opacity(0.15))
                    .foregroundColor(cycleManager.currentState.accentColor)
                    .cornerRadius(6)
            }
            
            // Reloj y Progreso Central
            VStack(spacing: 8) {
                Text(cycleManager.formattedRemainingTime)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .monospacedDigit()
                
                Text(cycleManager.currentState.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28)
                
                // Barra de progreso
                ProgressView(value: cycleManager.progress)
                    .tint(cycleManager.currentState.accentColor)
                    .padding(.horizontal, 4)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(12)
            
            // Controles de Reproducción
            HStack(spacing: 12) {
                Button(action: {
                    cycleManager.togglePlayPause()
                }) {
                    Label(
                        cycleManager.isRunning ? "Pausar" : "Iniciar",
                        systemImage: cycleManager.isRunning ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(cycleManager.currentState.accentColor)
                .controlSize(.regular)
                
                Button(action: {
                    cycleManager.skipToNext()
                }) {
                    Image(systemName: "forward.fill")
                        .frame(width: 24, height: 20)
                }
                .buttonStyle(.bordered)
                .help("Saltar a la siguiente fase")
                
                Button(action: {
                    cycleManager.resetCurrentPhase()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 24, height: 20)
                }
                .buttonStyle(.bordered)
                .help("Reiniciar fase actual")
            }
            
            // Estadísticas y prueba
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Ciclos hoy: \(cycleManager.completedCyclesToday)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    cycleManager.triggerTestAlert()
                }) {
                    Label("Probar Modal", systemImage: "bell.badge")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            
            Divider()
            
            // Ajustes de duración
            DisclosureGroup("⚙️ Configurar minutos", isExpanded: $showSettings) {
                VStack(spacing: 8) {
                    HStack {
                        Text("🦐 Sentado:")
                            .font(.caption)
                        Spacer()
                        Stepper("\(cycleManager.sittingMinutes) min", value: $cycleManager.sittingMinutes, in: 5...90, step: 5)
                            .font(.caption)
                    }
                    HStack {
                        Text("🧍 De pie:")
                            .font(.caption)
                        Spacer()
                        Stepper("\(cycleManager.standingMinutes) min", value: $cycleManager.standingMinutes, in: 1...60, step: 1)
                            .font(.caption)
                    }
                    HStack {
                        Text("🚶 Moverse:")
                            .font(.caption)
                        Spacer()
                        Stepper("\(cycleManager.movingMinutes) min", value: $cycleManager.movingMinutes, in: 1...30, step: 1)
                            .font(.caption)
                    }
                }
                .padding(.top, 6)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Divider()
            
            // Salir
            Button(role: .destructive, action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("Salir de AntiGamba")
                }
                .font(.caption)
                .foregroundColor(.red.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
        }
        .padding(16)
        .frame(width: 300)
    }
}
