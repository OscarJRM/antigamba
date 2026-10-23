import Foundation
import SwiftUI
import Combine

@MainActor
public final class CycleManager: ObservableObject {
    @Published public var currentState: PostureState = .sitting
    @Published public var remainingSeconds: Int = 40 * 60
    @Published public var totalSeconds: Int = 40 * 60
    @Published public var isRunning: Bool = false
    @Published public var completedCyclesToday: Int = 0
    
    // Duraciones configurables (en minutos)
    @Published public var sittingMinutes: Int = 40 {
        didSet { if currentState == .sitting && !isRunning { resetCurrentPhase() } }
    }
    @Published public var standingMinutes: Int = 15 {
        didSet { if currentState == .standing && !isRunning { resetCurrentPhase() } }
    }
    @Published public var movingMinutes: Int = 3 {
        didSet { if currentState == .moving && !isRunning { resetCurrentPhase() } }
    }
    
    private var timer: Timer?
    
    public init() {
        resetCurrentPhase()
    }
    
    public var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        let elapsed = totalSeconds - remainingSeconds
        return min(max(Double(elapsed) / Double(totalSeconds), 0), 1)
    }
    
    public func start() {
        guard !isRunning else { return }
        isRunning = true
        scheduleTimer()
    }
    
    public func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    public func togglePlayPause() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }
    
    public func skipToNext() {
        pause()
        transitionTo(state: currentState.next, autoStart: isRunning)
    }
    
    public func postpone(minutes: Int) {
        remainingSeconds += minutes * 60
        totalSeconds += minutes * 60
        start()
    }
    
    public func resetCurrentPhase() {
        pause()
        let minutes: Int
        switch currentState {
        case .sitting: minutes = sittingMinutes
        case .standing: minutes = standingMinutes
        case .moving: minutes = movingMinutes
        }
        totalSeconds = max(minutes, 1) * 60
        remainingSeconds = totalSeconds
    }
    
    public func transitionTo(state: PostureState, autoStart: Bool = true) {
        pause()
        if currentState == .moving && state == .sitting {
            completedCyclesToday += 1
        }
        currentState = state
        resetCurrentPhase()
        if autoStart {
            start()
        }
    }
    
    public func triggerTestAlert() {
        pause()
        OverlayManager.shared.showAlert(
            for: currentState.next,
            onStart: { [weak self] in
                guard let self = self else { return }
                self.transitionTo(state: self.currentState.next, autoStart: true)
            },
            onPostpone: { [weak self] minutes in
                self?.postpone(minutes: minutes)
            },
            onSkip: { [weak self] in
                guard let self = self else { return }
                self.transitionTo(state: self.currentState.next.next, autoStart: true)
            }
        )
    }
    
    private func scheduleTimer() {
        timer?.invalidate()
        let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        self.timer = newTimer
    }
    
    private func tick() {
        guard isRunning else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            handlePhaseCompleted()
        }
    }
    
    private func handlePhaseCompleted() {
        pause()
        let nextState = currentState.next
        
        OverlayManager.shared.showAlert(
            for: nextState,
            onStart: { [weak self] in
                guard let self = self else { return }
                self.transitionTo(state: nextState, autoStart: true)
            },
            onPostpone: { [weak self] minutes in
                self?.postpone(minutes: minutes)
            },
            onSkip: { [weak self] in
                guard let self = self else { return }
                self.transitionTo(state: nextState.next, autoStart: true)
            }
        )
    }
}
