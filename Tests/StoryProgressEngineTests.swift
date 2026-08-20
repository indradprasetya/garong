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
        precondition(story.maximumPlacements == 8, "Swift must decode the placement limit")
        precondition(story.starThresholds == StoryStarThresholds(threeStars: 3, twoStars: 5), "Swift must decode star thresholds")
        precondition(story.placementLimitMessage.en == "Rhodey is tired. You took too long.", "Swift must decode the character-specific limit message")

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
        precondition(engine.placementFeedbackState == .green, "A new run must start green")
        let approach = try require(chapter.objects.first { $0.name == "Approach" }, "Approach action")
        precondition(engine.placeObject(approach, inScene: engine.scenes[0].id), "Placement must succeed")

        let saved = try store.state(for: story.id).activeRun
        precondition(saved == StoryActiveRun(steps: [
            StoryProgressStep(
                sourceGridID: "grid_1",
                placements: [StoryProgressPlacement(slotID: "slot_scene", actionID: "action_approach")]
            )
        ], placementCount: 1, status: .playing), "Engine must save selections and placement count")

        let restored = DragDropGameEngine(chapter: chapter, progressStore: store)
        precondition(restored.scenes[0].dropSlots[0].currentObject?.name == "Approach", "Engine must restore saved progress")
        precondition(restored.placementCount == 1, "Engine must restore placement count")

        precondition(!restored.placeObject(approach, inScene: restored.scenes[0].id), "Dropping the same action into the same slot must be ignored")
        precondition(restored.placementCount == 1, "An ignored drop must not increase placement count")

        let crayon = try require(chapter.objects.first { $0.name == "Crayon" }, "Crayon action")
        precondition(restored.placeObject(crayon, inScene: restored.scenes[1].id), "Ideal final placement must succeed")
        precondition(restored.phase == .completed, "A successful complete outcome must finish the chapter")
        precondition(restored.starsEarned == 3, "Two ideal placements must earn three stars")
        let completion = try store.state(for: story.id)
        precondition(completion.activeRun == nil, "Completed run must no longer resume")
        precondition(completion.completion == StoryCompletion(bestStars: 3, bestPlacementCount: 2), "Completed run must save its best result")

        restored.restart()
        let replayState = try store.state(for: story.id)
        precondition(replayState.activeRun == nil, "Restart must clear the active replay")
        precondition(replayState.completion?.bestStars == 3, "Restart must preserve completed stars")

        let exhausted = DragDropGameEngine(chapter: chapter, progressStore: store)
        let toy = try require(chapter.objects.first { $0.name == "Toy" }, "Toy action")
        for index in 0..<story.maximumPlacements {
            let action = index.isMultiple(of: 2) ? approach : toy
            precondition(exhausted.placeObject(action, inScene: exhausted.scenes[0].id), "Replacement \(index + 1) must be accepted")
            let expectedState: PlacementFeedbackState = switch index + 1 {
            case ...3: .green
            case ...5: .yellow
            case ...7: .orange
            default: .red
            }
            precondition(exhausted.placementFeedbackState == expectedState, "Placement \(index + 1) must be \(expectedState)")
        }
        precondition(exhausted.phase == .needsBreak, "The run must stop at the placement limit")
        precondition(exhausted.placementLimitMessage == "Rhodey is tired. You took too long.", "The break state must use the chapter character")
        let exhaustedState = try store.state(for: story.id).activeRun
        precondition(exhaustedState?.status == .needsBreak, "The exhausted state must resume after relaunch")
        precondition(exhaustedState?.placementCount == 8, "The exhausted run must save its placement count")

        let finalPlacementSuite = "StoryProgressFinalPlacementTests.\(UUID().uuidString)"
        let finalPlacementDefaults = UserDefaults(suiteName: finalPlacementSuite)!
        defer { finalPlacementDefaults.removePersistentDomain(forName: finalPlacementSuite) }
        let finalPlacementEngine = DragDropGameEngine(
            chapter: chapter,
            progressStore: StoryProgressStore(defaults: finalPlacementDefaults)
        )
        for index in 0..<7 {
            let action = index.isMultiple(of: 2) ? approach : toy
            precondition(finalPlacementEngine.placeObject(action, inScene: finalPlacementEngine.scenes[0].id))
        }
        precondition(finalPlacementEngine.placeObject(crayon, inScene: finalPlacementEngine.scenes[1].id))
        precondition(finalPlacementEngine.phase == .completed, "Success on the final allowed placement must beat the limit")
        precondition(finalPlacementEngine.placementFeedbackState == .orange, "A one-star completion must remain orange, not red")
        precondition(finalPlacementEngine.starsEarned == 1, "Success at the limit must earn one star")

        print("StoryProgressEngineTests passed")
    }

    private static func require<T>(_ value: T?, _ name: String) throws -> T {
        guard let value else {
            throw NSError(domain: "StoryProgressEngineTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing \(name)"])
        }
        return value
    }
}
