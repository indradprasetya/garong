import SwiftUI

@main
struct InstantDragLifecycleTests {
    static func main() {
        var activity = InstantDragActivity()

        precondition(activity.update(isActive: true) == true)
        precondition(activity.update(isActive: true) == nil, "Repeated drag updates must not retrigger drag start")
        precondition(activity.update(isActive: false) == false)
        precondition(activity.update(isActive: false) == nil, "Repeated ending updates must not retrigger drag end")

        print("InstantDragLifecycleTests passed")
    }
}
