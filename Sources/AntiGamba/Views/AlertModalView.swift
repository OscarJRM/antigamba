import SwiftUI

public struct AlertModalView: View {
    public let targetState: PostureState
    public let onStart: () -> Void
    public let onPostpone: (Int) -> Void
    public let onSkip: () -> Void
    
    public init(
        targetState: PostureState,
        onStart: @escaping () -> Void,
        onPostpone: @escaping (Int) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.targetState = targetState
        self.onStart = onStart
        self.onPostpone = onPostpone
        self.onSkip = onSkip
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Header con Iconos
            HStack(spacing: 12) {
                Text(previousEmoji)
                    .font(.system(size: 38))
                    .opacity(0.6)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.secondary)
                
                Text(targetState.emoji)
                    .font(.system(size: 48))
            }
            .padding(.top, 8)
            
            // Textos descriptivos
            VStack(spacing: 8) {
                Text(targetState.alertTitle)
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(targetState.alertMessage)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
            }
            
            Divider()
                .padding(.horizontal, 20)
            
            // Botones de acción
            VStack(spacing: 10) {
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Empezar \(targetState.actionTitle) (\(targetState.defaultDurationMinutes)m)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(targetState.accentColor)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                
                HStack(spacing: 12) {
                    Button(action: { onPostpone(5) }) {
                        Label("Posponer 5m", systemImage: "clock.arrow.circlepath")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: onSkip) {
                        Label("Saltar", systemImage: "forward.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
        .padding(24)
        .frame(width: 420)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
    }
    
    private var previousEmoji: String {
        switch targetState {
        case .standing: return PostureState.sitting.emoji
        case .moving: return PostureState.standing.emoji
        case .sitting: return PostureState.moving.emoji
        }
    }
}
