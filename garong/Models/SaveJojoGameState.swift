import Foundation

struct SaveJojoGameState: Equatable {
    enum Phase: Equatable {
        case onboarding
        case aiming
        case caught
        case pulling
        case rescuing
        case won
        case lost
    }

    private(set) var phase: Phase = .onboarding
    private(set) var lives = 3
    private(set) var successfulPulls = 0

    static let pullsNeeded = 3
    static let targetRange: ClosedRange<Double> = 0.42...0.62

    mutating func dismissOnboarding() {
        guard phase == .onboarding else { return }
        phase = .aiming
    }

    @discardableResult
    mutating func throwLifebuoy(
        alignmentError: Double = 0,
        deferLoss: Bool = false
    ) -> Bool {
        guard phase == .aiming else { return false }
        if alignmentError <= 0.10 {
            phase = .caught
            return true
        }

        lives -= 1
        if lives <= 0, !deferLoss {
            phase = .lost
        }
        return false
    }

    mutating func finishFailedThrow() {
        guard phase == .aiming, lives <= 0 else { return }
        phase = .lost
    }

    mutating func beginPulling() {
        guard phase == .caught else { return }
        phase = .pulling
    }

    mutating func beginRescueTransition() {
        guard phase == .pulling else { return }
        phase = .rescuing
    }

    mutating func completeRescue() {
        guard phase == .rescuing else { return }
        successfulPulls = Self.pullsNeeded
        phase = .won
    }

    mutating func failPullAttempt() {
        guard phase == .pulling else { return }
        lives -= 1
        if lives <= 0 {
            phase = .lost
        }
    }

    @discardableResult
    mutating func pull(at markerPosition: Double) -> Bool {
        guard phase == .pulling else { return false }

        if Self.targetRange.contains(markerPosition) {
            successfulPulls += 1
            if successfulPulls >= Self.pullsNeeded {
                phase = .won
            }
            return true
        }

        lives -= 1
        if lives <= 0 {
            phase = .lost
        }
        return false
    }

    mutating func restart() {
        phase = .aiming
        lives = 3
        successfulPulls = 0
    }
}
