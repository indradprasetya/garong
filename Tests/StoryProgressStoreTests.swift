import Foundation

@main
struct StoryProgressStoreTests {
    static func main() throws {
        let suiteName = "StoryProgressStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let progress = [
            StoryProgressStep(
                sourceGridID: "grid_1",
                placements: [
                    StoryProgressPlacement(slotID: "slot_jojo", actionID: "action_asking"),
                    StoryProgressPlacement(slotID: "slot_rhodey", actionID: "action_approach")
                ]
            )
        ]

        let activeRun = StoryActiveRun(steps: progress, placementCount: 4, status: .playing)
        try StoryProgressStore(defaults: defaults).saveActiveRun(activeRun, for: "listen_before_helping_rhodey")
        let restored = try StoryProgressStore(defaults: defaults).state(for: "listen_before_helping_rhodey")
        precondition(restored.activeRun == activeRun, "Active run must survive store recreation")
        precondition(restored.completion == nil, "An unfinished run must not create a completion")

        let store = StoryProgressStore(defaults: defaults)
        try store.complete(storyID: "listen_before_helping_rhodey", stars: 2, placementCount: 7)
        var completed = try store.state(for: "listen_before_helping_rhodey")
        precondition(completed.activeRun == nil, "Completion must clear the active run")
        precondition(completed.completion == StoryCompletion(bestStars: 2, bestPlacementCount: 7), "Completion must save stars and placements")

        try store.saveActiveRun(activeRun, for: "listen_before_helping_rhodey")
        try store.complete(storyID: "listen_before_helping_rhodey", stars: 1, placementCount: 9)
        completed = try store.state(for: "listen_before_helping_rhodey")
        precondition(completed.completion == StoryCompletion(bestStars: 2, bestPlacementCount: 7), "A worse replay must preserve the best result")

        try store.saveActiveRun(activeRun, for: "listen_before_helping_rhodey")
        try store.clearActiveRun(storyID: "listen_before_helping_rhodey")
        completed = try store.state(for: "listen_before_helping_rhodey")
        precondition(completed.activeRun == nil, "Try Again must clear only the active run")
        precondition(completed.completion?.bestStars == 2, "Try Again must preserve the best result")

        store.resetAll()
        let emptyState = try store.state(for: "listen_before_helping_rhodey")
        precondition(emptyState == StoryProgressState(), "Full reset must clear every story")

        print("StoryProgressStoreTests passed")
    }
}
