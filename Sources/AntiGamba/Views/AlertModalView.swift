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
            // Iconos de transición
            HStack(spacing: 14) {
                Text(previousEmoji)
                    .font(.system(size: 42))
                    .opacity(0.4)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.secondary)
                
                Text(targetState.emoji)
                    .font(.system(size: 52))
            }
            .padding(.top, 6)
            
            // Textos
            VStack(spacing: 8) {
                Text(L10n.alertTitle(for: targetState))
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(L10n.alertMessage(for: targetState))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
            }
            
            Divider()
                .opacity(0.6)
                .padding(.horizontal, 10)
            
            // Botones de acción
            VStack(spacing: 10) {
                // Botón Principal
                Button(action: onStart) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text(L10n.startAction(for: targetState, minutes: targetState.defaultDurationMinutes))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(targetState.accentColor)
                    )
                }
                .buttonStyle(.plain)
                
                // Botones Secundarios
                HStack(spacing: 12) {
                    Button(action: { onPostpone(5) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text(L10n.postpone5m)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.primary.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onSkip) {
                        HStack(spacing: 6) {
                            Image(systemName: "forward.fill")
                            Text(L10n.skip)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.primary.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(24)
        .frame(width: 400)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThickMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 30, x: 0, y: 15)
    }
    
    private var previousEmoji: String {
        switch targetState {
        case .standing: return PostureState.sitting.emoji
        case .moving: return PostureState.standing.emoji
        case .sitting: return PostureState.moving.emoji
        }
    }
}
