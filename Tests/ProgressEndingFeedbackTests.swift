import Foundation

@main
struct ProgressEndingFeedbackTests {
    static func main() throws {
        let resourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources/story1_chapter1.json")
        let story = try JSONDecoder().decode(StoryDefinition.self, from: Data(contentsOf: resourceURL))
        let chapter = Chapter(storyItem: StoryChapterItem(
            id: story.id,
            storyNumber: 1,
            chapterNumber: 1,
            fileName: "story1_chapter1",
            storyDefinition: story,
            isUnlocked: true
        ))
        let suiteName = "ProgressEndingFeedbackTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let engine = DragDropGameEngine(
            chapter: chapter,
            progressStore: StoryProgressStore(defaults: defaults)
        )
        let approach = chapter.objects.first { $0.name == "Approach" }!

        precondition(engine.placeObject(approach, inScene: engine.scenes[0].id))
        precondition(engine.wrongAttempts == 0, "A partial path must not trigger wrong-ending feedback")
        precondition(engine.placeObject(approach, inScene: engine.scenes[1].id))
        precondition(engine.currentOutcome?.category == "progress")
        precondition(engine.wrongAttempts == 1, "A full progress ending must trigger wrong-ending feedback")

        print("ProgressEndingFeedbackTests passed")
    }
}
