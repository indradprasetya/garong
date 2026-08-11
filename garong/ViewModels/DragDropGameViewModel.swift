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
    @Published var animatingSceneID: UUID?
    
    private let engine: DragDropGameEngine
    
    init(chapter: Chapter) {
        let engine = DragDropGameEngine(chapter: chapter)
        self.engine = engine
        self.scenes = engine.scenes
        self.availableObjects = engine.availableObjects
        self.phase = engine.phase
        self.chapterResult = nil
        self.chapterName = chapter.name
    }
    
    /// Total number of scenes in this chapter.
    var totalSceneCount: Int { engine.totalSceneCount }
    
    /// Currently filled scene count.
    var placedObjectCount: Int { engine.placedObjectCount }
    
    /// Progress indicator text e.g. "2 / 3 Scenes Filled"
    var progressText: String {
        "\(placedObjectCount) / \(totalSceneCount) Scenes Filled"
    }
    
    /// Drop or replace an object in a target scene.
    func dropObject(_ object: GameObject, intoScene sceneID: UUID) {
        let success = engine.placeObject(object, inScene: sceneID)
        guard success else { return }
        
        // Trigger visual reaction pulse
        animatingSceneID = sceneID
        
        syncWithEngine()
        
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            self.animatingSceneID = nil
        }
    }
    
    /// Remove an object from a scene.
    func removeObject(_ object: GameObject, fromScene sceneID: UUID) {
        let success = engine.removeObject(object, fromScene: sceneID)
        guard success else { return }
        syncWithEngine()
    }
    
    /// User explicitly taps the Finish button to complete the chapter.
    func finishChapter() {
        engine.finishChapter()
        syncWithEngine()
    }
    
    /// Restart the chapter.
    func restart() {
        engine.restart()
        chapterResult = nil
        syncWithEngine()
    }
    
    private func syncWithEngine() {
        self.scenes = engine.scenes
        self.availableObjects = engine.availableObjects
        self.phase = engine.phase
        
        if engine.phase == .completed {
            self.chapterResult = engine.buildResult()
        }
    }
}
