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
    @Published private(set) var hasDroppedFirstItemInChapter1: Bool = false
    @Published private(set) var showPeekHint: Bool = false
    @Published var isDraggingItem: Bool = false
    @Published var animatingSceneID: UUID?
    
    private var engine: DragDropGameEngine
    private var currentChapterIndex: Int = 0
    private var storyChapters: [StoryChapterReference] = []
    private var storyNumber = 1
    private var hasPlayedCompletionSFX: Bool = false
    private var tutorialHintSession = TutorialHintSession()

    private var isStory1Chapter1: Bool {
        TutorialHintSession.showsOnboarding(
            storyNumber: storyNumber,
            chapterNumber: engine.chapter.number
        )
    }

    var showChapter1TutorialHint: Bool {
        isStory1Chapter1 && !hasDroppedFirstItemInChapter1 && phase == .playing
    }

    func dismissPeekHint() {
        showPeekHint = false
    }
    
    init(chapter: Chapter) {
        let engine = DragDropGameEngine(chapter: chapter)
        self.engine = engine
        self.scenes = engine.scenes
        self.availableObjects = engine.availableObjects
        self.phase = engine.phase
        self.chapterResult = engine.phase == .needsBreak ? engine.buildResult() : nil
        self.chapterName = chapter.name
        self.hintText = Self.localizedHint(for: chapter)
        self.wrongAttempts = engine.wrongAttempts
        self.currentStars = engine.placementFeedbackState.meterStars
        
        if let storyDef = chapter.storyDefinition,
           let group = StoryCatalog.stories.first(where: { group in
               group.chapters.contains { $0.id == storyDef.id }
           }) {
            self.storyChapters = group.chapters
            self.storyNumber = group.number
            self.currentChapterIndex = group.chapters.firstIndex(where: { $0.id == storyDef.id }) ?? 0
        }
    }

    #if DEBUG
    convenience init(chapter: Chapter, showTutorialHintForPreview: Bool = false, showPeekHintForPreview: Bool = false) {
        self.init(chapter: chapter)
        if showTutorialHintForPreview {
            self.hasDroppedFirstItemInChapter1 = false
        } else {
            self.hasDroppedFirstItemInChapter1 = true
        }
        if showPeekHintForPreview {
            self.showPeekHint = true
        }
    }
    #endif
    
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
            self.engine = DragDropGameEngine(chapter: nextChapter)
            self.chapterName = nextChapter.name
            self.hintText = Self.localizedHint(for: nextChapter)
            self.chapterResult = nil
            self.hasDroppedFirstItemInChapter1 = false
            self.showPeekHint = false
            self.tutorialHintSession.reset()
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
        let success = engine.placeObject(object, inSlot: slotID, inScene: sceneID)
        guard success else { return }

        if isStory1Chapter1 {
            withAnimation {
                hasDroppedFirstItemInChapter1 = true
            }
        }
        
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
        
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            self.animatingSceneID = nil
        }
    }
    
    /// Remove an object from a scene slot.
    func removeObject(_ object: GameObject, fromSlot slotID: String? = nil, fromScene sceneID: UUID) {
        let success = engine.removeObject(object, fromSlot: slotID, fromScene: sceneID)
        guard success else { return }
        hasPlayedCompletionSFX = false
        SoundManager.shared.play(.itemRemove)
        syncWithEngine()
    }
    
    /// Remove an object globally from whichever scene currently holds it.
    func removeObjectGlobal(_ object: GameObject) {
        let success = engine.removeObjectGlobal(object)
        guard success else { return }
        hasPlayedCompletionSFX = false
        SoundManager.shared.play(.itemRemove)
        syncWithEngine()
    }
    
    /// Restart the chapter.
    func restart(playSound: Bool = true) {
        hasPlayedCompletionSFX = false
        if playSound {
            SoundManager.shared.play(.buttonTap)
        }
        engine.restart()
        chapterResult = nil
        hasDroppedFirstItemInChapter1 = false
        showPeekHint = false
        tutorialHintSession.reset()
        syncWithEngine()
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
