import Foundation

@main
struct SFXPreviewThrottleTests {
    static func main() {
        var throttle = SFXPreviewThrottle(minimumInterval: 0.15)

        precondition(throttle.shouldPlay(at: 1.00))
        precondition(!throttle.shouldPlay(at: 1.10))
        precondition(throttle.shouldPlay(at: 1.15))

        print("SFXPreviewThrottleTests passed")
    }
}
