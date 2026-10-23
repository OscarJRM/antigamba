import SwiftUI

public struct MenuBarView: View {
    @ObservedObject public var cycleManager: CycleManager
    @ObservedObject private var settings = AppSettings.shared
    @State private var showSettings = false
    
    public init(cycleManager: CycleManager) {
        self.cycleManager = cycleManager
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Text("🦐")
                        .font(.system(size: 22))
                    Text("AntiGamba")
                        .font(.system(size: 15, weight: .bold))
                }
                
                Spacer()
                
                // Badge de estado con indicador luminoso
                HStack(spacing: 5) {
                    Circle()
                        .fill(cycleManager.currentState.accentColor)
                        .frame(width: 7, height: 7)
                    Text(L10n.title(for: cycleManager.currentState))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                )
            }
            
            // Tarjeta de Tiempo y Progreso
            VStack(spacing: 10) {
                Text(cycleManager.formattedRemainingTime)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                
                Text(L10n.description(for: cycleManager.currentState))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)
                
                // Barra de progreso personalizada
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(cycleManager.currentState.accentColor)
                            .frame(width: geometry.size.width * CGFloat(cycleManager.progress), height: 6)
                            .animation(.linear(duration: 0.5), value: cycleManager.progress)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.primary.opacity(0.05))
            )
            
            // Botones Principales
            HStack(spacing: 10) {
                // Iniciar / Pausar
                Button(action: {
                    cycleManager.togglePlayPause()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: cycleManager.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text(cycleManager.isRunning ? L10n.pause : L10n.start)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(cycleManager.currentState.accentColor)
                    )
                }
                .buttonStyle(.plain)
                
                // Siguiente Fase (Skip)
                Button(action: {
                    cycleManager.skipToNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.primary.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .help(L10n.skip)
                
                // Reiniciar
                Button(action: {
                    cycleManager.resetCurrentPhase()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.primary.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Métricas y Botón Probar Modal
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text(L10n.cyclesToday)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("\(cycleManager.completedCyclesToday)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    cycleManager.triggerTestAlert()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 10))
                        Text(L10n.testAlert)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.08))
                    )
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .opacity(0.6)
            
            // Configuración
            DisclosureGroup("⚙️ \(L10n.settings)", isExpanded: $showSettings) {
                VStack(spacing: 12) {
                    // Duraciones
                    VStack(spacing: 8) {
                        HStack {
                            Text(L10n.sittingLabel)
                            Spacer()
                            Stepper("\(cycleManager.sittingMinutes) min", value: $cycleManager.sittingMinutes, in: 5...90, step: 5)
                        }
                        HStack {
                            Text(L10n.standingLabel)
                            Spacer()
                            Stepper("\(cycleManager.standingMinutes) min", value: $cycleManager.standingMinutes, in: 1...60, step: 1)
                        }
                        HStack {
                            Text(L10n.movingLabel)
                            Spacer()
                            Stepper("\(cycleManager.movingMinutes) min", value: $cycleManager.movingMinutes, in: 1...30, step: 1)
                        }
                    }
                    
                    Divider().opacity(0.4)
                    
                    // Selector de idioma
                    HStack {
                        Text(L10n.languageLabel)
                        Spacer()
                        Picker("", selection: $settings.selectedLanguage) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 140)
                    }
                    
                    // Selector de sonido
                    HStack {
                        Text(L10n.soundLabel)
                        Spacer()
                        Picker("", selection: Binding(
                            get: { settings.selectedSound },
                            set: { settings.playPreview(soundName: $0) }
                        )) {
                            ForEach(settings.availableSounds, id: \.self) { sound in
                                Text(sound == "Silencioso" ? L10n.silentSound : sound).tag(sound)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                    }
                    
                    // Modo compacto
                    Toggle(L10n.compactMode, isOn: $settings.isCompactMode)
                    
                    // Iniciar al encender
                    Toggle(L10n.launchAtLogin, isOn: $settings.launchAtLogin)
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.secondary)
            
            Divider()
                .opacity(0.6)
            
            // Salir de la app
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                        .font(.system(size: 11, weight: .semibold))
                    Text(L10n.quit)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.red.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(width: 320)
    }
}
