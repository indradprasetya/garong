import SwiftUI

@main
struct InstantDragLifecycleTests {
    static func main() {
        var activity = InstantDragActivity()

        precondition(activity.update(isActive: true) == true)
        precondition(activity.update(isActive: true) == nil, "Repeated drag updates must not retrigger drag start")
        precondition(activity.update(isActive: false) == nil, "Gesture handoff must not end the drag UI")
        precondition(activity.update(isActive: true) == true, "The next drag gesture must start normally")

        print("InstantDragLifecycleTests passed")
    }
}
