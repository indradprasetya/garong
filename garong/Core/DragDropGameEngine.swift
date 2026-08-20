//
//  DragDropGameEngine.swift
//  garong
//

import Foundation

/// Core engine managing drag-and-drop gameplay state, single-item replacement, and global chained reactions.
final class DragDropGameEngine {
    private let reactionEvaluator: ReactionEvaluating
    private let completionEvaluator: CompletionEvaluator
    private let progressStore: StoryProgressStore
    private var storyRunner: StoryRunner?
    
    private(set) var chapter: Chapter
    private(set) var scenes: [GameScene]
    private(set) var availableObjects: [GameObject]
    private(set) var phase: DragDropPhase = .playing
    private(set) var currentOutcome: StoryOutcome?
    private(set) var placementCount = 0
    private(set) var starsEarned: Int?
    private(set) var bestStars: Int?
    
    init(
        chapter: Chapter,
        reactionEvaluator: ReactionEvaluating = DefaultReactionEvaluator(),
        completionEvaluator: CompletionEvaluator = CompletionEvaluator(),
        progressStore: StoryProgressStore = StoryProgressStore()
    ) {
        self.chapter = chapter
        self.scenes = chapter.scenes
        self.availableObjects = chapter.objects
        self.reactionEvaluator = reactionEvaluator
        self.completionEvaluator = completionEvaluator
        self.progressStore = progressStore
        
        if let story = chapter.storyDefinition {
            self.storyRunner = try? StoryRunner(story: story)
            restoreProgress(for: story)
        }
        
        reevaluateAllReactions()
    }
    
    /// Total number of choice slots in this chapter.
    var totalSceneCount: Int {
        if let story = chapter.storyDefinition {
            return story.choiceCount
        }
        return scenes.count
    }
    
    /// Total items currently placed across all slots.
    var placedObjectCount: Int {
        scenes.reduce(0) { $0 + $1.objectCount }
    }
    
    /// Whether all choice slots in the chapter are filled.
    var isAllScenesFilled: Bool {
        if let story = chapter.storyDefinition {
            let placedCount = scenes.flatMap(\.dropSlots).compactMap(\.currentObject).count
            return placedCount >= story.choiceCount
        }
        let choiceScenes = scenes.filter { !$0.dropSlots.isEmpty }
        return choiceScenes.allSatisfy { $0.dropSlots.allSatisfy { $0.currentObject != nil } }
    }

    /// Whether the current evaluated outcome is ideal/correct.
    var isCurrentOutcomeIdeal: Bool {
        guard let outcome = currentOutcome else { return true }
        return outcome.isIdeal
    }
    
    /// Total objects available in tray.
    var totalObjectCount: Int { chapter.objects.count }

    var maximumPlacements: Int? { chapter.storyDefinition?.maximumPlacements }

    var placementLimitMessage: String {
        chapter.storyDefinition?.placementLimitMessage.en ?? "The characters need a break."
    }

    var isCurrentOutcomeSuccessful: Bool {
        currentOutcome?.category == "success"
    }

    var placementFeedbackState: PlacementFeedbackState {
        guard phase != .needsBreak else { return .red }
        guard let thresholds = chapter.storyDefinition?.starThresholds else { return .green }
        if placementCount <= thresholds.threeStars { return .green }
        if placementCount <= thresholds.twoStars { return .yellow }
        return .orange
    }
    
    /// Place or replace an object in a specific slot within a scene.
    @discardableResult
    func placeObject(_ object: GameObject, inSlot slotID: String? = nil, inScene sceneID: UUID) -> Bool {
        guard phase == .playing else { return false }
        guard let sceneIndex = scenes.firstIndex(where: { $0.id == sceneID }) else { return false }
        guard scenes[sceneIndex].isUnlocked else { return false }

        let slotIndex: Int
        if let slotID = slotID, let index = scenes[sceneIndex].dropSlots.firstIndex(where: { $0.id == slotID }) {
            slotIndex = index
        } else if let emptyIndex = scenes[sceneIndex].dropSlots.firstIndex(where: { $0.currentObject == nil }) {
            slotIndex = emptyIndex
        } else if !scenes[sceneIndex].dropSlots.isEmpty {
            slotIndex = 0
        } else {
            return false
        }

        guard scenes[sceneIndex].dropSlots[slotIndex].currentObject?.name != object.name else { return false }
        scenes[sceneIndex].dropSlots[slotIndex].currentObject = object
        placementCount += 1
        reevaluateAllReactions()

        if isAllScenesFilled && isCurrentOutcomeSuccessful {
            completeStoryRun()
        } else if let maximumPlacements, placementCount >= maximumPlacements {
            phase = .needsBreak
            saveProgress(status: .needsBreak)
        } else {
            saveProgress()
        }
        return true
    }
    
    /// Remove an object globally from whichever slot/scene currently holds it.
    @discardableResult
    func removeObjectGlobal(_ object: GameObject) -> Bool {
        guard phase == .playing else { return false }
        var removedAny = false
        for sceneIndex in scenes.indices {
            for slotIndex in scenes[sceneIndex].dropSlots.indices {
                if scenes[sceneIndex].dropSlots[slotIndex].currentObject?.id == object.id ||
                   scenes[sceneIndex].dropSlots[slotIndex].currentObject?.name == object.name {
                    scenes[sceneIndex].dropSlots[slotIndex].currentObject = nil
                    removedAny = true
                }
            }
        }
        if removedAny {
            reevaluateAllReactions()
            saveProgress()
        }
        return removedAny
    }
    
    /// Remove an object from a specific slot or scene.
    @discardableResult
    func removeObject(_ object: GameObject, fromSlot slotID: String? = nil, fromScene sceneID: UUID) -> Bool {
        guard phase == .playing else { return false }
        guard let sceneIndex = scenes.firstIndex(where: { $0.id == sceneID }) else { return false }
        
        if let slotID = slotID, let slotIndex = scenes[sceneIndex].dropSlots.firstIndex(where: { $0.id == slotID }) {
            scenes[sceneIndex].dropSlots[slotIndex].currentObject = nil
        } else {
            for idx in scenes[sceneIndex].dropSlots.indices {
                if scenes[sceneIndex].dropSlots[idx].currentObject?.name == object.name {
                    scenes[sceneIndex].dropSlots[idx].currentObject = nil
                    break
                }
            }
        }
        
        reevaluateAllReactions()
        saveProgress()
        
        return true
    }
    
    /// Explicitly finishes the chapter and transitions to the completion result overlay.
    func finishChapter() {
        if chapter.storyDefinition == nil {
            phase = .completed
        } else if isAllScenesFilled && isCurrentOutcomeSuccessful {
            completeStoryRun()
        }
    }
    
    /// Recalculates character emotions and speech text for scenes based on current global combinations.
    func reevaluateAllReactions() {
        if let runner = storyRunner, let story = chapter.storyDefinition {
            let choiceCount = story.choiceCount
            let placedActionIDs = scenes.flatMap { scene in
                scene.dropSlots.compactMap { slot -> String? in
                    guard let obj = slot.currentObject else { return nil }
                    return story.actions.first(where: { $0.name.en == obj.name })?.id
                }
            }
            
            // Resolve full or partial outcome match to update speech bubbles immediately upon item placement!
            let activeOutcome: StoryOutcome?
            if placedActionIDs.count == choiceCount {
                activeOutcome = runner.outcome(for: placedActionIDs)
                self.currentOutcome = activeOutcome
            } else if !placedActionIDs.isEmpty {
                activeOutcome = runner.partialOutcome(matching: placedActionIDs)
                self.currentOutcome = nil
            } else {
                activeOutcome = runner.initialOutcome
                self.currentOutcome = nil
            }
            
            if let outcome = activeOutcome {
                for (index, state) in outcome.states.enumerated() {
                    if scenes.indices.contains(index) {
                        let isOutcomeGrid = scenes[index].dropSlots.isEmpty
                        let isFirstGrid = (index == 0)
                        let isCurrentActiveGrid = (index <= placedActionIDs.count)
                        let isComplete = (placedActionIDs.count == choiceCount)
                        let shouldShow = isFirstGrid || isCurrentActiveGrid || (isOutcomeGrid && isComplete)
                        
                        if shouldShow {
                            let imageNames = state.visualSlotsList.map { visualSlot in
                                let asset = visualSlot.assetID.isEmpty ? (visualSlot.characterIDs.first ?? "") : visualSlot.assetID
                                return AssetFallbackHelper.imageName(for: asset)
                            }
                            if !imageNames.isEmpty {
                                scenes[index].characterImageNames = imageNames
                            }
                            
                            if isFirstGrid || (index < placedActionIDs.count) || (isOutcomeGrid && isComplete) {
                                scenes[index].speechBubbleText = state.textBubble?.text.en
                            } else {
                                scenes[index].speechBubbleText = nil
                            }
                            
                            if isComplete {
                                if outcome.isIdeal {
                                    scenes[index].characterEmotion = .happy
                                } else if outcome.category == "retry" {
                                    scenes[index].characterEmotion = .sad
                                } else {
                                    scenes[index].characterEmotion = .calm
                                }
                            } else {
                                scenes[index].characterEmotion = .neutral
                            }
                        } else {
                            scenes[index].speechBubbleText = nil
                        }
                    }
                }
            } else {
                let newEmotions = reactionEvaluator.evaluateReactions(for: scenes)
                for (index, emotion) in newEmotions.enumerated() {
                    if scenes.indices.contains(index) {
                        scenes[index].characterEmotion = emotion
                        scenes[index].speechBubbleText = nil
                    }
                }
            }
        } else {
            let newEmotions = reactionEvaluator.evaluateReactions(for: scenes)
            for (index, emotion) in newEmotions.enumerated() {
                if scenes.indices.contains(index) {
                    scenes[index].characterEmotion = emotion
                }
            }
        }
        
        updateProgressiveUnlocking()
    }
    
    private func updateProgressiveUnlocking() {
        var isPreviousFilled = true
        for index in scenes.indices {
            if index == 0 {
                scenes[index].isUnlocked = true
            } else {
                scenes[index].isUnlocked = isPreviousFilled
            }
            let isChoiceScene = !scenes[index].dropSlots.isEmpty
            if isChoiceScene {
                let allSlotsFilled = scenes[index].dropSlots.allSatisfy { $0.currentObject != nil }
                if !allSlotsFilled {
                    isPreviousFilled = false
                }
            }
        }
    }
    
    /// Build summary result for chapter completion.
    func buildResult() -> ChapterResult {
        ChapterResult(
            chapterName: chapter.name,
            totalObjects: totalSceneCount,
            placedObjects: placedObjectCount,
            placementCount: placementCount,
            stars: starsEarned ?? 0,
            completionSummary: chapter.storyDefinition?.completionSummary.en,
            completionTip: chapter.storyDefinition?.completionTip.en,
            sceneStates: scenes.map { scene in
                ChapterResult.SceneResultEntry(
                    sceneName: scene.name,
                    objectNames: scene.dropSlots.compactMap { $0.currentObject?.name },
                    emotionName: scene.characterEmotion.displayName
                )
            }
        )
    }
    
    /// Reset the game session.
    func restart() {
        scenes = chapter.scenes.map { scene in
            var s = scene
            for idx in s.dropSlots.indices {
                s.dropSlots[idx].currentObject = nil
            }
            s.characterEmotion = .neutral
            s.speechBubbleText = nil
            return s
        }
        availableObjects = chapter.objects
        phase = .playing
        placementCount = 0
        starsEarned = nil
        if let storyID = chapter.storyDefinition?.id {
            try? progressStore.clearActiveRun(storyID: storyID)
        }
        reevaluateAllReactions()
    }

    private func restoreProgress(for story: StoryDefinition) {
        guard let state = try? progressStore.state(for: story.id) else { return }
        bestStars = state.completion?.bestStars
        guard let activeRun = state.activeRun else { return }
        placementCount = activeRun.placementCount
        phase = activeRun.status == .needsBreak ? .needsBreak : .playing
        let objectsByActionID = Dictionary(uniqueKeysWithValues: zip(story.actions.map(\.id), availableObjects))
        let gridIndexes = Dictionary(uniqueKeysWithValues: story.grids.enumerated().map { ($0.element.id, $0.offset) })

        for step in activeRun.steps {
            guard let sceneIndex = gridIndexes[step.sourceGridID], scenes.indices.contains(sceneIndex) else { continue }
            for placement in step.placements {
                guard let slotIndex = scenes[sceneIndex].dropSlots.firstIndex(where: { $0.id == placement.slotID }),
                      let object = objectsByActionID[placement.actionID] else { continue }
                scenes[sceneIndex].dropSlots[slotIndex].currentObject = object
            }
        }
    }

    private func saveProgress(status: StoryRunStatus = .playing) {
        guard let story = chapter.storyDefinition else { return }
        let actionIDsByName = Dictionary(uniqueKeysWithValues: story.actions.map { ($0.name.en, $0.id) })
        let progress = zip(story.grids, scenes).compactMap { grid, scene -> StoryProgressStep? in
            let placements = scene.dropSlots.compactMap { slot -> StoryProgressPlacement? in
                guard let name = slot.currentObject?.name, let actionID = actionIDsByName[name] else { return nil }
                return StoryProgressPlacement(slotID: slot.id, actionID: actionID)
            }
            return placements.isEmpty ? nil : StoryProgressStep(sourceGridID: grid.id, placements: placements)
        }
        try? progressStore.saveActiveRun(
            StoryActiveRun(steps: progress, placementCount: placementCount, status: status),
            for: story.id
        )
    }

    private func completeStoryRun() {
        guard let story = chapter.storyDefinition else {
            phase = .completed
            return
        }
        let stars = placementCount <= story.starThresholds.threeStars
            ? 3
            : placementCount <= story.starThresholds.twoStars ? 2 : 1
        starsEarned = stars
        bestStars = max(bestStars ?? 0, stars)
        phase = .completed
        try? progressStore.complete(storyID: story.id, stars: stars, placementCount: placementCount)
    }
}
