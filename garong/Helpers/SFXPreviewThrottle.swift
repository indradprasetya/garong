import Foundation

struct SFXPreviewThrottle {
    let minimumInterval: TimeInterval
    private var lastPlayedAt: TimeInterval?

    init(minimumInterval: TimeInterval) {
        self.minimumInterval = minimumInterval
    }

    mutating func shouldPlay(at timestamp: TimeInterval) -> Bool {
        guard let lastPlayedAt else {
            self.lastPlayedAt = timestamp
            return true
        }
        guard timestamp >= lastPlayedAt + minimumInterval else { return false }

        self.lastPlayedAt = timestamp
        return true
    }
}
