import Foundation

@main
struct WinCelebrationSequenceTests {
    static func main() {
        precondition(WinCelebrationSequence.delay(for: 2, totalCount: 3) == 0)
        precondition(abs(WinCelebrationSequence.delay(for: 1, totalCount: 3) - 0.18) < 0.001)
        precondition(abs(WinCelebrationSequence.delay(for: 0, totalCount: 3) - 0.36) < 0.001)

        print("WinCelebrationSequenceTests passed")
    }
}
