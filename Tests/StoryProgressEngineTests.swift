import Foundation

@main
struct StoryProgressEngineTests {
    static func main() throws {
        let resourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources/story1_chapter1.json")
        let story = try JSONDecoder().decode(StoryDefinition.self, from: Data(contentsOf: resourceURL))
        precondition(story.shortTitle.en == "Let's Draw!", "Swift must decode the localized short title")
        precondition(story.completionSummary.en.hasPrefix("Rhodey needed to feel noticed"), "Swift must decode the completion summary")
        precondition(story.completionTip.id.hasPrefix("Sebelum mengajak anak"), "Swift must decode the localized completion tip")

        let item = StoryChapterItem(
            id: story.id,
            storyNumber: 1,
            chapterNumber: 1,
            fileName: "story1_chapter1",
            storyDefinition: story,
            isUnlocked: true
        )
        let chapter = Chapter(storyItem: item)
        let suiteName = "StoryProgressEngineTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = StoryProgressStore(defaults: defaults)

        let engine = DragDropGameEngine(chapter: chapter, progressStore: store)
        let approach = try require(chapter.objects.first { $0.name == "Approach" }, "Approach action")
        precondition(engine.placeObject(approach, inScene: engine.scenes[0].id), "Placement must succeed")

        let saved = try store.progress(for: story.id)
        precondition(saved == [
            StoryProgressStep(
                sourceGridID: "grid_1",
                placements: [StoryProgressPlacement(slotID: "slot_scene", actionID: "action_approach")]
            )
        ], "Engine must save the selected action")

        let restored = DragDropGameEngine(chapter: chapter, progressStore: store)
        precondition(restored.scenes[0].dropSlots[0].currentObject?.name == "Approach", "Engine must restore saved progress")

        restored.restart()
        let resetProgress = try store.progress(for: story.id)
        precondition(resetProgress.isEmpty, "Restart must clear saved story progress")

        print("StoryProgressEngineTests passed")
    }

    private static func require<T>(_ value: T?, _ name: String) throws -> T {
        guard let value else {
            throw NSError(domain: "StoryProgressEngineTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing \(name)"])
        }
        return value
    }
}
