import Foundation

@main
struct NextChapterProgressTests {
    static func main() throws {
        let resourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("garong/Resources/story1_chapter2.json")
        let story = try JSONDecoder().decode(StoryDefinition.self, from: Data(contentsOf: resourceURL))
        let chapter = Chapter(storyItem: StoryChapterItem(
            id: story.id,
            storyNumber: 1,
            chapterNumber: 2,
            fileName: "story1_chapter2",
            storyDefinition: story,
            isUnlocked: true
        ))
        let suiteName = "NextChapterProgressTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = StoryProgressStore(defaults: defaults)
        let savedRun = StoryActiveRun(
            steps: [StoryProgressStep(
                sourceGridID: story.grids[0].id,
                placements: [StoryProgressPlacement(
                    slotID: story.grids[0].dropSlots![0].id,
                    actionID: story.actions[0].id
                )]
            )],
            placementCount: 1,
            status: .playing
        )
        try store.saveActiveRun(savedRun, for: story.id)

        let resumedChapter = DragDropGameEngine(chapter: chapter, progressStore: store)
        precondition(resumedChapter.placedObjectCount == 1, "Opening a chapter directly must resume its active run")

        let freshChapter = DragDropGameEngine(
            chapter: chapter,
            progressStore: store,
            resumeProgress: false
        )

        precondition(freshChapter.placedObjectCount == 0, "Next must start the destination chapter fresh")
        let state = try store.state(for: story.id)
        precondition(state.activeRun == nil, "Next must discard the destination chapter's active run")
        print("NextChapterProgressTests passed")
    }
}
