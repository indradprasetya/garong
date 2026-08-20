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
    @Published var isDraggingItem: Bool = false
    @Published var animatingSceneID: UUID?
    
    private var engine: DragDropGameEngine
    private var currentChapterIndex: Int = 0
    private var storyChapters: [StoryChapterItem] = []
    private var hasPlayedCompletionSFX: Bool = false
    
    init(chapter: Chapter) {
        let engine = DragDropGameEngine(chapter: chapter)
        self.engine = engine
        self.scenes = engine.scenes
        self.availableObjects = engine.availableObjects
        self.phase = engine.phase
        self.chapterResult = nil
        self.chapterName = chapter.name
        
        if let storyDef = chapter.storyDefinition,
           let group = StoryCatalog.stories.first(where: { g in g.chapters.contains { $0.id == storyDef.id || $0.fileName.contains(storyDef.id) } }) {
            self.storyChapters = group.chapters
            self.currentChapterIndex = group.chapters.firstIndex(where: { $0.id == storyDef.id || $0.fileName.contains(storyDef.id) }) ?? 0
        }
    }
    
    var hasNextChapter: Bool {
        !storyChapters.isEmpty && currentChapterIndex + 1 < storyChapters.count
    }
    
    /// Navigates to next chapter automatically or displays completed dialog if final chapter in story.
    func goToNextChapterOrFinish() {
        hasPlayedCompletionSFX = false
        if hasNextChapter {
            currentChapterIndex += 1
            let nextItem = storyChapters[currentChapterIndex]
            let nextChapter = Chapter(storyItem: nextItem)
            self.engine = DragDropGameEngine(chapter: nextChapter)
            self.chapterName = nextChapter.name
            self.chapterResult = nil
            syncWithEngine()
        } else {
            finishChapter()
        }
    }
    
    func setDraggingActive(_ active: Bool) {
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
        "\(placedObjectCount) / \(totalSceneCount) Scenes Filled"
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
        case .green: return "Green: 3-star range"
        case .yellow: return "Yellow: 2-star range"
        case .orange: return "Orange: 1-star range"
        case .red: return "Red: chapter lost"
        }
    }

    var placementLimitMessage: String { engine.placementLimitMessage }
    
    /// Drop or replace an object in a target scene slot.
    func dropObject(_ object: GameObject, intoSlot slotID: String? = nil, intoScene sceneID: UUID) {
        let success = engine.placeObject(object, inSlot: slotID, inScene: sceneID)
        guard success else { return }
        
        if engine.isAllScenesFilled {
            if engine.isCurrentOutcomeIdeal {
                if !hasPlayedCompletionSFX {
                    hasPlayedCompletionSFX = true
                    SoundManager.shared.play(.chapterComplete)
                } else {
                    SoundManager.shared.play(.itemPickup)
                }
            } else {
                SoundManager.shared.play(.chapterRetry)
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
    
    /// User explicitly taps the Finish button to complete the chapter.
    func finishChapter() {
        engine.finishChapter()
        syncWithEngine()
    }
    
    /// Restart the chapter.
    func restart() {
        hasPlayedCompletionSFX = false
        SoundManager.shared.play(.buttonTap)
        engine.restart()
        chapterResult = nil
        syncWithEngine()
    }
    
    private func syncWithEngine() {
        let oldPhase = self.phase
        self.scenes = engine.scenes
        self.availableObjects = engine.availableObjects
        self.phase = engine.phase
        
        if engine.phase == .completed {
            self.chapterResult = engine.buildResult()
            if oldPhase != .completed && !hasPlayedCompletionSFX {
                hasPlayedCompletionSFX = true
                if engine.isCurrentOutcomeIdeal {
                    SoundManager.shared.play(.chapterComplete)
                } else {
                    SoundManager.shared.play(.chapterRetry)
                }
            }
        } else {
            self.chapterResult = nil
        }
    }
}
