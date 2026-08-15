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

        try StoryProgressStore(defaults: defaults).save(progress, for: "listen_before_helping_rhodey")
        let restored = try StoryProgressStore(defaults: defaults).progress(for: "listen_before_helping_rhodey")
        precondition(restored == progress, "Progress must survive store recreation")

        try StoryProgressStore(defaults: defaults).save(progress, for: "rhodey_wants_to_draw")
        let store = StoryProgressStore(defaults: defaults)
        try store.reset(storyID: "listen_before_helping_rhodey")
        let resetProgress = try store.progress(for: "listen_before_helping_rhodey")
        let preservedProgress = try store.progress(for: "rhodey_wants_to_draw")
        precondition(resetProgress.isEmpty, "Story reset must clear that story")
        precondition(preservedProgress == progress, "Story reset must preserve other stories")

        store.resetAll()
        let emptyProgress = try store.progress(for: "rhodey_wants_to_draw")
        precondition(emptyProgress.isEmpty, "Full reset must clear every story")

        print("StoryProgressStoreTests passed")
    }
}
