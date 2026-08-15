//
//  DragDropGameTests.swift
//  garong
//

import Foundation

/// Unit tests for item replacement, global chained reactions, and explicit chapter finish.
final class DragDropGameTests {
    
    @discardableResult
    static func runAllTests() -> Bool {
        print("🧪 [DragDropGameTests] Starting test suite...")
        var passedCount = 0
        var totalCount = 0
        
        func assertTest(_ name: String, _ condition: () -> Bool) {
            totalCount += 1
            if condition() {
                passedCount += 1
                print("  ✅ PASS: \(name)")
            } else {
                print("  ❌ FAIL: \(name)")
            }
        }
        
        let evaluator = DefaultReactionEvaluator()
        
        // --- Evaluator Chained Reaction Tests ---
        
        assertTest("Empty scenes → all neutral") {
            let scenes = SampleGameData.chapters[0].scenes
            let emotions = evaluator.evaluateReactions(for: scenes)
            return emotions == [.neutral, .neutral, .neutral]
        }
        
        assertTest("Chained reaction: Teddy in Scene 1, Apple in Scene 2") {
            var scenes = SampleGameData.chapters[0].scenes
            scenes[0].currentObject = SampleGameData.teddy
            scenes[1].currentObject = SampleGameData.apple
            
            let emotions = evaluator.evaluateReactions(for: scenes)
            return emotions[0] == .excited && emotions[1] == .happy && emotions[2] == .curious
        }
        
        assertTest("Chained reaction change when item replaced in Scene 1") {
            var scenes = SampleGameData.chapters[0].scenes
            scenes[0].currentObject = SampleGameData.teddy
            scenes[1].currentObject = SampleGameData.apple
            
            scenes[0].currentObject = SampleGameData.book
            let newEmotions = evaluator.evaluateReactions(for: scenes)
            return newEmotions[0] == .curious && newEmotions[1] == .excited && newEmotions[2] == .happy
        }
        
        // --- Engine Tests ---
        
        assertTest("Engine: single item placement & replacement in scene") {
            let chapter = SampleGameData.chapters[0]
            let engine = DragDropGameEngine(chapter: chapter)
            let scene1ID = engine.scenes[0].id
            
            engine.placeObject(SampleGameData.teddy, inScene: scene1ID)
            let hasTeddy = engine.scenes[0].currentObject?.name == "Teddy"
            
            engine.placeObject(SampleGameData.apple, inScene: scene1ID)
            let hasApple = engine.scenes[0].currentObject?.name == "Apple"
            
            return hasTeddy && hasApple && engine.placedObjectCount == 1
        }
        
        assertTest("Engine: placing items does NOT auto-end chapter") {
            let chapter = SampleGameData.chapters[0]
            let engine = DragDropGameEngine(chapter: chapter)
            
            engine.placeObject(SampleGameData.teddy, inScene: engine.scenes[0].id)
            engine.placeObject(SampleGameData.apple, inScene: engine.scenes[1].id)
            engine.placeObject(SampleGameData.book, inScene: engine.scenes[2].id)
            
            // Chapter remains in .playing phase so user can continue experimenting
            return engine.phase == .playing && engine.placedObjectCount == 3
        }
        
        assertTest("Engine: explicit finishChapter triggers completion") {
            let chapter = SampleGameData.chapters[0]
            let engine = DragDropGameEngine(chapter: chapter)
            
            engine.placeObject(SampleGameData.teddy, inScene: engine.scenes[0].id)
            engine.finishChapter()
            
            return engine.phase == .completed && engine.buildResult().placedObjects == 1
        }
        
        assertTest("Engine: restart resets all scenes to empty and neutral") {
            let chapter = SampleGameData.chapters[0]
            let engine = DragDropGameEngine(chapter: chapter)
            
            engine.placeObject(SampleGameData.teddy, inScene: engine.scenes[0].id)
            engine.finishChapter()
            engine.restart()
            
            return engine.phase == .playing &&
                   engine.placedObjectCount == 0 &&
                   engine.scenes.allSatisfy { $0.currentObject == nil && $0.characterEmotion == .neutral }
        }

        assertTest("Story JSON: Rhodey story loads and validates") {
            do {
                let story = try StoryLoader.load(named: "crying_to_learning")
                return story.id == "rhodey_wants_to_draw" &&
                       story.title.en == "Make Rhodey Want to Draw" &&
                       story.gridCount == 3 &&
                       story.choiceCount == 2 &&
                       story.actions.count == 3 &&
                       story.characters.count == 1 &&
                       story.outcomes.count == 9
            } catch {
                print("    Story load error: \(error)")
                return false
            }
        }

        assertTest("Story runner: ideal path makes Rhodey draw") {
            do {
                let runner = try StoryRunner(story: StoryLoader.load(named: "crying_to_learning"))
                let outcome = runner.outcome(for: ["action_get_nearby", "action_crayon"])
                return outcome?.states.flatMap(\.characterSlots).map(\.expressionID) == [
                           "rhodey_refusing",
                           "rhodey_loved",
                           "rhodey_drawing_happy"
                       ] &&
                       outcome?.finalState == "DRAWING" &&
                       outcome?.isIdeal == true
            } catch {
                print("    Story runner error: \(error)")
                return false
            }
        }

        assertTest("Story JSON: localized text and outcomes match chapter") {
            do {
                let story = try StoryLoader.load(named: "crying_to_learning")
                let categories = Dictionary(grouping: story.outcomes, by: \.category).mapValues(\.count)
                return story.actions.first(where: { $0.id == "action_toy" })?.name.id == "Mainan" &&
                       story.outcomes.first?.states.first?.textBubble?.text.en == "I don't want to draw right now." &&
                       story.outcomes.first?.states.first?.textBubble?.text.id == "Aku belum mau menggambar sekarang." &&
                       story.outcomes.allSatisfy { outcome in
                           outcome.states.allSatisfy { state in
                               (1...2).contains(state.characterSlots.count)
                           }
                       } &&
                       story.outcomes.flatMap(\.states).contains { $0.textBubble == nil } &&
                       categories["success"] == 1 &&
                       categories["progress"] == 4 &&
                       categories["retry"] == 4
            } catch {
                print("    Story content error: \(error)")
                return false
            }
        }
        
        let allPassed = passedCount == totalCount
        print("🧪 [DragDropGameTests] Result: \(passedCount)/\(totalCount) tests passed (\(allPassed ? "SUCCESS" : "FAILURE"))")
        return allPassed
    }
}
