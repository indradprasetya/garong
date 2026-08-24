//
//  DragDropGameViewModel.swift
//  garong
//

import SwiftUI
import Combine

/// Observable ViewModel for the drag-and-drop gameplay.
final class DragDropGameViewModel: ObservableObject {
    @Published private(set) var scenes: [GameScene]
    @Published private(set) var availableObjects: [GameObject]
    @Published private(set) var phase: DragDropPhase
    @Published private(set) var chapterResult: ChapterResult?
    @Published private(set) var chapterName: String
    @Published private(set) var hintText: String?
    @Published private(set) var wrongAttempts: Int = 0
    @Published private(set) var currentStars: Int = 3
    @Published private(set) var showPeekHint: Bool = false
    @Published private(set) var tutorialStep: ChapterTutorialStep
    @Published private(set) var currentNarratorLine: String? = nil
    @Published private(set) var showNarratorBox: Bool = false
    @Published var isDraggingItem: Bool = false
    @Published var animatingSceneID: UUID?
    
    private var engine: DragDropGameEngine
    private var currentChapterIndex: Int = 0
    private var storyChapters: [StoryChapterReference] = []
    private var storyNumber = 1
    private var hasPlayedCompletionSFX: Bool = false
    private var tutorialHintSession = TutorialHintSession()
    private var chapterTutorial: ChapterTutorialSession
    private var narratorDismissTask: Task<Void, Never>? = nil

    var isGuidedTutorialActive: Bool { tutorialStep != .inactive }

    func dismissPeekHint() {
        showPeekHint = false
    }

    func dismissNarratorBox() {
        narratorDismissTask?.cancel()
        narratorDismissTask = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            showNarratorBox = false
        }
    }

    func caregiverLine(for object: GameObject) -> String? {
        guard let story = engine.chapter.storyDefinition else { return nil }
        let lang = engine.chapter.language
        if let action = story.actions.first(where: {
            $0.id == object.symbol ||
            AssetFallbackHelper.actionImageName(for: $0.id) == object.symbol ||
            $0.name.localized(language: lang) == object.name
        }) {
            return action.caregiverLine.localized(language: lang)
        }
        return nil
    }

    func selectNarratorLine(for object: GameObject) {
        if let line = caregiverLine(for: object) {
            presentNarratorLine(line)
        }
    }

    private func presentNarratorLine(_ line: String) {
        narratorDismissTask?.cancel()
        withAnimation(.easeInOut(duration: 0.2)) {
            self.currentNarratorLine = line
            self.showNarratorBox = true
        }
        narratorDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                self.showNarratorBox = false
            }
        }
    }
    
    init(chapter: Chapter) {
        let group = chapter.storyDefinition.flatMap { story in
            StoryCatalog.stories.first { group in
                group.chapters.contains { $0.id == story.id }
            }
        }
        let savedCompletion = chapter.storyDefinition.flatMap { story in
            try? StoryProgressStore().state(for: story.id).completion
        }
        let chapterTutorial = ChapterTutorialSession(
            storyNumber: group?.number ?? 0,
            chapterNumber: chapter.number,
            chapterAlreadyCompleted: savedCompletion != nil
        )
        let engine = DragDropGameEngine(chapter: chapter)
        if chapterTutorial.isActive {
            engine.restart()
        }
        self.engine = engine
        self.chapterTutorial = chapterTutorial
        self.tutorialStep = chapterTutorial.step
        self.scenes = engine.scenes
        self.availableObjects = engine.availableObjects
        self.phase = engine.phase
        self.chapterResult = engine.phase == .needsBreak ? engine.buildResult() : nil
        self.chapterName = chapter.name
        self.hintText = Self.localizedHint(for: chapter)
        self.wrongAttempts = engine.wrongAttempts
        self.currentStars = engine.placementFeedbackState.meterStars
        
        if let group,
           let storyDef = chapter.storyDefinition {
            self.storyChapters = group.chapters
            self.storyNumber = group.number
            self.currentChapterIndex = group.chapters.firstIndex(where: { $0.id == storyDef.id }) ?? 0
        }
    }

    var meterCharacterName: String {
        guard let story = engine.chapter.storyDefinition else { return "rhodey" }
        let id = story.id.lowercased()
        if id.contains("jojo") || storyNumber == 2 {
            return "jojo"
        }
        return "rhodey"
    }

    var meterImageName: String {
        let character = meterCharacterName
        let stars = engine.placementFeedbackState.meterStars
        return "\(character)_\(stars)_star"
    }
    
    var hasNextChapter: Bool {
        !storyChapters.isEmpty && currentChapterIndex + 1 < storyChapters.count
    }

    func canDrag(_ object: GameObject) -> Bool {
        chapterTutorial.allowsTrayAction(object.symbol)
    }

    func canDragPlacedObject(_ object: GameObject) -> Bool {
        chapterTutorial.allowsRemoval(object.symbol)
    }

    func isTutorialItem(_ object: GameObject) -> Bool {
        switch tutorialStep {
        case .approach: object.symbol == "action_approach"
        case .toy: object.symbol == "action_toy"
        case .crayon: object.symbol == "action_crayon"
        default: false
        }
    }

    func isTutorialTarget(_ scene: GameScene) -> Bool {
        guard let index = scenes.firstIndex(where: { $0.id == scene.id }) else { return false }
        return switch tutorialStep {
        case .approach: index == 0
        case .toy, .crayon: index == 1
        default: false
        }
    }

    var canUseHint: Bool {
        !isGuidedTutorialActive || tutorialStep == .wrongAndHint
    }
    
    /// Loads the next chapter in sequence.
    func loadNextChapter() {
        hasPlayedCompletionSFX = false
        if hasNextChapter {
            let nextIndex = currentChapterIndex + 1
            let nextReference = storyChapters[nextIndex]
            guard let nextChapter = StoryCatalog.chapter(
                for: nextReference,
                storyNumber: storyNumber,
                language: engine.chapter.language
            ) else { return }
            currentChapterIndex = nextIndex
            self.engine = DragDropGameEngine(chapter: nextChapter, resumeProgress: false)
            self.chapterName = nextChapter.name
            self.hintText = Self.localizedHint(for: nextChapter)
            self.chapterResult = nil
            self.showPeekHint = false
            self.showNarratorBox = false
            self.currentNarratorLine = nil
            self.tutorialHintSession.reset()
            self.chapterTutorial = ChapterTutorialSession(
                storyNumber: storyNumber,
                chapterNumber: nextChapter.number,
                chapterAlreadyCompleted: false
            )
            syncTutorialStep()
            syncWithEngine()
        }
    }
    
    func setDraggingActive(_ active: Bool) {
        guard isDraggingItem != active else { return }
        if active {
            SoundManager.shared.play(.itemPickup)
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            self.isDraggingItem = active
        }
    }
    
    /// Total number of scenes in this chapter.
    var totalSceneCount: Int { engine.totalSceneCount }
    
    /// Currently filled scene count.
    var placedObjectCount: Int { engine.placedObjectCount }
    
    /// Progress indicator text e.g. "2 / 3 Scenes Filled"
    var progressText: String {
        AppLocalization.shared.text(
            "gameplay.scenesFilled",
            language: engine.chapter.language,
            placedObjectCount,
            totalSceneCount
        )
    }

    var placementFace: String {
        switch engine.placementFeedbackState {
        case .green: return "🙂"
        case .yellow: return "😐"
        case .orange: return "😟"
        case .red: return "😣"
        }
    }

    var placementColor: Color {
        switch engine.placementFeedbackState {
        case .green: return .green
        case .yellow: return .yellow
        case .orange: return .orange
        case .red: return .red
        }
    }

    var placementStateLabel: String {
        switch engine.placementFeedbackState {
        case .green: return AppLocalization.shared.text("gameplay.greenRange", language: engine.chapter.language)
        case .yellow: return AppLocalization.shared.text("gameplay.yellowRange", language: engine.chapter.language)
        case .orange: return AppLocalization.shared.text("gameplay.orangeRange", language: engine.chapter.language)
        case .red: return AppLocalization.shared.text("gameplay.lost", language: engine.chapter.language)
        }
    }

    var placementLimitMessage: String { engine.placementLimitMessage }

    private static func localizedHint(for chapter: Chapter) -> String {
        if let hints = chapter.storyDefinition?.hints, !hints.isEmpty {
            return hints.map { $0.localized(language: chapter.language) }.joined(separator: "\n\n")
        }
        return chapter.storyDefinition?.description.localized(language: chapter.language) ?? chapter.description
    }
    
    /// Drop or replace an object in a target scene slot.
    func dropObject(_ object: GameObject, intoSlot slotID: String? = nil, intoScene sceneID: UUID) {
        guard let sceneIndex = engine.scenes.firstIndex(where: { $0.id == sceneID }),
              chapterTutorial.allowsDrop(actionID: object.symbol, sceneIndex: sceneIndex) else { return }
        let success = engine.placeObject(object, inSlot: slotID, inScene: sceneID)
        guard success else { return }

        chapterTutorial.didPlace(actionID: object.symbol, sceneIndex: sceneIndex)
        if engine.phase == .completed {
            chapterTutorial.didCompleteChapter()
        }
        syncTutorialStep()

        if engine.isAllScenesFilled {
            if engine.isCurrentOutcomeSuccessful {
                if !hasPlayedCompletionSFX {
                    hasPlayedCompletionSFX = true
                    SoundManager.shared.play(.chapterComplete)
                } else {
                    SoundManager.shared.play(.itemPickup)
                }
            }
        } else {
            hasPlayedCompletionSFX = false
            SoundManager.shared.play(.itemPickup)
        }
        
        // Trigger visual reaction pulse
        animatingSceneID = sceneID
        
        syncWithEngine()

        if let line = caregiverLine(for: object) {
            presentNarratorLine(line)
        }
        
        if let droppedScene = scenes.first(where: { $0.id == sceneID }) {
            let played = SoundManager.shared.playVoiceOverIfPresent(
                for: droppedScene.characterImageNames,
                emotion: droppedScene.characterEmotion
            )
            if !played {
                for scene in scenes where scene.id != sceneID {
                    if SoundManager.shared.playVoiceOverIfPresent(
                        for: scene.characterImageNames,
                        emotion: scene.characterEmotion
                    ) {
                        break
                    }
                }
            }
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            self.animatingSceneID = nil
        }
    }
    
    /// Remove an object from a scene slot.
    func removeObject(_ object: GameObject, fromSlot slotID: String? = nil, fromScene sceneID: UUID) {
        guard chapterTutorial.allowsRemoval(object.symbol) else { return }
        let success = engine.removeObject(object, fromSlot: slotID, fromScene: sceneID)
        guard success else { return }
        chapterTutorial.didRemove(object.symbol)
        syncTutorialStep()
        hasPlayedCompletionSFX = false
        SoundManager.shared.play(.itemRemove)
        syncWithEngine()
        updateNarratorStateAfterRemoval()
    }
    
    /// Remove an object globally from whichever scene currently holds it.
    func removeObjectGlobal(_ object: GameObject) {
        guard chapterTutorial.allowsRemoval(object.symbol) else { return }
        let success = engine.removeObjectGlobal(object)
        guard success else { return }
        chapterTutorial.didRemove(object.symbol)
        syncTutorialStep()
        hasPlayedCompletionSFX = false
        SoundManager.shared.play(.itemRemove)
        syncWithEngine()
        updateNarratorStateAfterRemoval()
    }

    private func updateNarratorStateAfterRemoval() {
        let remainingObjects = scenes.flatMap(\.dropSlots).compactMap(\.currentObject)
        if remainingObjects.isEmpty {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.showNarratorBox = false
                self.currentNarratorLine = nil
            }
        } else if let lastObject = remainingObjects.last, let line = caregiverLine(for: lastObject) {
            self.currentNarratorLine = line
        }
    }
    
    /// Restart the chapter.
    func restart(playSound: Bool = true) {
        hasPlayedCompletionSFX = false
        if playSound {
            SoundManager.shared.play(.buttonTap)
        }
        engine.restart()
        chapterResult = nil
        showPeekHint = false
        showNarratorBox = false
        currentNarratorLine = nil
        tutorialHintSession.reset()
        chapterTutorial.resetForRestart()
        syncTutorialStep()
        syncWithEngine()
    }

    func didDismissTutorialHint() {
        chapterTutorial.didDismissHint()
        syncTutorialStep()
    }

    func acknowledgeTutorialMeter() {
        chapterTutorial.didAcknowledgeMeter()
        syncTutorialStep()
    }

    private func syncTutorialStep() {
        tutorialStep = chapterTutorial.step
    }
    
    private func syncWithEngine() {
        let oldPhase = self.phase
        let oldWrongAttempts = self.wrongAttempts
        self.scenes = engine.scenes
        self.availableObjects = engine.availableObjects
        self.phase = engine.phase
        self.wrongAttempts = engine.wrongAttempts
        self.currentStars = engine.placementFeedbackState.meterStars
        
        if self.wrongAttempts > oldWrongAttempts {
            SoundManager.shared.play(.chapterRetry)
            if tutorialHintSession.shouldShowPeekHint() {
                withAnimation {
                    showPeekHint = true
                }
            }
        }
        
        if engine.phase == .completed {
            self.chapterResult = engine.buildResult()
            if oldPhase != .completed && !hasPlayedCompletionSFX {
                hasPlayedCompletionSFX = true
                SoundManager.shared.play(.chapterComplete)
            }
        } else if engine.phase == .needsBreak {
            self.chapterResult = engine.buildResult()
        } else {
            self.chapterResult = nil
        }
    }
}
