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
    private(set) var wrongAttempts: Int = 0
    private(set) var placementCount: Int = 0
    private(set) var starsEarned: Int?
    private(set) var bestStars: Int?
    private var lastEvaluatedActionSequence: [String] = []
    
    init(
        chapter: Chapter,
        reactionEvaluator: ReactionEvaluating = DefaultReactionEvaluator(),
        completionEvaluator: CompletionEvaluator = CompletionEvaluator(),
        progressStore: StoryProgressStore = StoryProgressStore(),
        resumeProgress: Bool = true
    ) {
        self.chapter = chapter
        self.scenes = chapter.scenes
        self.availableObjects = chapter.objects
        self.reactionEvaluator = reactionEvaluator
        self.completionEvaluator = completionEvaluator
        self.progressStore = progressStore
        
        if let story = chapter.storyDefinition {
            self.storyRunner = try? StoryRunner(story: story)
            if !resumeProgress {
                try? progressStore.clearActiveRun(storyID: story.id)
            }
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
        guard chapter.storyDefinition != nil else { return true }
        return currentOutcome?.isIdeal == true
    }

    var isCurrentOutcomeSuccessful: Bool {
        guard chapter.storyDefinition != nil else { return true }
        return currentOutcome?.category == "success"
    }
    
    /// Total objects available in tray.
    var totalObjectCount: Int { chapter.objects.count }

    var maximumPlacements: Int? { chapter.storyDefinition?.maximumPlacements }

    var placementLimitMessage: String {
        chapter.storyDefinition?.placementLimitMessage.localized(language: chapter.language)
            ?? AppLocalization.shared.text("gameplay.breakFallback", language: chapter.language)
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
        guard !scenes[sceneIndex].dropSlots.isEmpty else { return false }
        
        let targetSlotIndex: Int
        if let slotID = slotID, let foundIndex = scenes[sceneIndex].dropSlots.firstIndex(where: { $0.id == slotID }) {
            targetSlotIndex = foundIndex
        } else if let emptyIndex = scenes[sceneIndex].dropSlots.firstIndex(where: { $0.currentObject == nil }) {
            targetSlotIndex = emptyIndex
        } else if !scenes[sceneIndex].dropSlots.isEmpty {
            targetSlotIndex = 0
        } else {
            return false
        }

        guard scenes[sceneIndex].dropSlots[targetSlotIndex].currentObject?.name != object.name else { return false }
        scenes[sceneIndex].dropSlots[targetSlotIndex].currentObject = object
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
        guard chapter.storyDefinition == nil || (isAllScenesFilled && isCurrentOutcomeSuccessful) else { return }
        completeStoryRun()
    }
    
    /// Recalculates character emotions and speech text for scenes based on current global combinations.
    func reevaluateAllReactions() {
        if let runner = storyRunner, let story = chapter.storyDefinition {
            let choiceCount = story.choiceCount
            let placedActionIDs = scenes.flatMap { scene in
                scene.dropSlots.compactMap { slot -> String? in
                    guard let obj = slot.currentObject else { return nil }
                    return actionID(for: obj.name, in: story)
                }
            }
            
            // Resolve full or partial outcome match to update speech bubbles immediately upon item placement!
            let activeOutcome: StoryOutcome?
            if placedActionIDs.count == choiceCount {
                activeOutcome = runner.outcome(for: placedActionIDs)
                self.currentOutcome = activeOutcome
                if placedActionIDs != lastEvaluatedActionSequence {
                    lastEvaluatedActionSequence = placedActionIDs
                    if let activeOutcome, activeOutcome.category != "success" {
                        wrongAttempts += 1
                    }
                }
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
                            
                            scenes[index].speechBubbleText = state.textBubble?.text.localized(language: chapter.language)
                            
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
    
    var meterCharacterName: String {
        guard let story = chapter.storyDefinition else { return "rhodey" }
        let id = story.id.lowercased()
        if id.contains("jojo") {
            return "jojo"
        }
        return "rhodey"
    }

    var meterImageName: String {
        let character = meterCharacterName
        let stars = starsEarned ?? 0
        return "\(character)_\(stars)_star"
    }

    /// Build summary result for chapter completion.
    func buildResult() -> ChapterResult {
        let charName = meterCharacterName
        let stars = starsEarned ?? 0
        let image = "\(charName)_\(stars)_star"

        return ChapterResult(
            chapterName: chapter.name,
            totalObjects: totalSceneCount,
            placedObjects: placedObjectCount,
            placementCount: placementCount,
            stars: stars,
            completionSummary: chapter.storyDefinition?.completionSummary.localized(language: chapter.language),
            completionTip: chapter.storyDefinition?.completionTip.localized(language: chapter.language),
            sceneStates: scenes.map { scene in
                ChapterResult.SceneResultEntry(
                    sceneName: scene.name,
                    objectNames: scene.dropSlots.compactMap { $0.currentObject?.name },
                    emotionName: scene.characterEmotion.displayName
                )
            },
            characterName: charName.capitalized,
            meterImageName: image
        )
    }
    
    /// Reset the game session.
    func restart() {
        wrongAttempts = 0
        lastEvaluatedActionSequence = []
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
        let progress = zip(story.grids, scenes).compactMap { grid, scene -> StoryProgressStep? in
            let placements = scene.dropSlots.compactMap { slot -> StoryProgressPlacement? in
                guard let name = slot.currentObject?.name, let actionID = actionID(for: name, in: story) else { return nil }
                return StoryProgressPlacement(slotID: slot.id, actionID: actionID)
            }
            return placements.isEmpty ? nil : StoryProgressStep(sourceGridID: grid.id, placements: placements)
        }
        try? progressStore.saveActiveRun(
            StoryActiveRun(steps: progress, placementCount: placementCount, status: status),
            for: story.id
        )
    }

    private func actionID(for objectName: String, in story: StoryDefinition) -> String? {
        story.actions.first {
            $0.name.en == objectName || $0.name.id == objectName
        }?.id
    }

    private func completeStoryRun() {
        guard let story = chapter.storyDefinition else {
            phase = .completed
            return
        }
        let stars: Int
        if placementCount <= story.starThresholds.threeStars {
            stars = 3
        } else if placementCount <= story.starThresholds.twoStars {
            stars = 2
        } else {
            stars = 1
        }
        starsEarned = stars
        bestStars = max(bestStars ?? 0, stars)
        phase = .completed
        try? progressStore.complete(storyID: story.id, stars: stars, placementCount: placementCount)
    }
}
