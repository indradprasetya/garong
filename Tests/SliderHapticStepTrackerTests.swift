import Foundation

@main
struct SliderHapticStepTrackerTests {
    static func main() {
        var tracker = SliderHapticStepTracker(stepCount: 20)

        precondition(tracker.shouldTrigger(for: 0.10))
        precondition(!tracker.shouldTrigger(for: 0.14))
        precondition(tracker.shouldTrigger(for: 0.15))
        precondition(!tracker.shouldTrigger(for: 0.19))
        precondition(tracker.shouldTrigger(for: 0.14))

        tracker.reset()
        precondition(tracker.shouldTrigger(for: 0.14))

        print("SliderHapticStepTrackerTests passed")
    }
}
