import Foundation

enum WinCelebrationSequence {
    static func delay(for index: Int, totalCount: Int) -> TimeInterval {
        guard totalCount > 0, (0..<totalCount).contains(index) else { return 0 }
        return TimeInterval(totalCount - index - 1) * 0.18
    }
}
