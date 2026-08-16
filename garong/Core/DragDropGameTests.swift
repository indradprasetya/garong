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
                let story = try StoryLoader.load(named: "story1_chapter1")
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

        assertTest("Story runner: ideal path for story1_chapter1") {
            do {
                let story = try StoryLoader.load(named: "story1_chapter1")
                let runner = try StoryRunner(story: story)
                let outcome = runner.outcome(for: ["action_approach", "action_crayon"])
                return outcome != nil &&
                       outcome?.isIdeal == true
            } catch {
                print("    Story runner error: \(error)")
                return false
            }
        }

        assertTest("Story runner: multi-slot drop zones for story2_chapter3") {
            do {
                let story = try StoryLoader.load(named: "story2_chapter3")
                let item = StoryChapterItem(id: "s2c3", storyNumber: 2, chapterNumber: 3, fileName: "story2_chapter3", storyDefinition: story, isUnlocked: true)
                let chapter = Chapter(storyItem: item)
                let engine = DragDropGameEngine(chapter: chapter)
                
                return engine.totalSceneCount == 5 &&
                       engine.scenes[0].dropSlots.count == 2 &&
                       engine.scenes[1].dropSlots.count == 2 &&
                       engine.scenes[2].dropSlots.count == 1 &&
                       engine.scenes[3].dropSlots.count == 0
            } catch {
                print("    Multi-slot story load error: \(error)")
                return false
            }
        }

        assertTest("Story JSON: all 6 chapter JSON files load and validate") {
            let files = [
                "story1_chapter1", "story1_chapter2", "story1_chapter3",
                "story2_chapter1", "story2_chapter2", "story2_chapter3"
            ]
            do {
                for file in files {
                    let story = try StoryLoader.load(named: file)
                    let runner = try StoryRunner(story: story)
                    guard !story.actions.isEmpty, !story.outcomes.isEmpty, runner.outcome(for: Array(repeating: story.actions.first!.id, count: story.choiceCount)) != nil else {
                        return false
                    }
                }
                return true
            } catch {
                print("    All stories load error: \(error)")
                return false
            }
        }
        
        let allPassed = passedCount == totalCount
        print("🧪 [DragDropGameTests] Result: \(passedCount)/\(totalCount) tests passed (\(allPassed ? "SUCCESS" : "FAILURE"))")
        return allPassed
    }
}
