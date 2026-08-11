//
//  DragDropGameEngine.swift
//  garong
//

import Foundation

/// Core engine managing drag-and-drop gameplay state, single-item replacement, and global chained reactions.
final class DragDropGameEngine {
    private let reactionEvaluator: ReactionEvaluating
    private let completionEvaluator: CompletionEvaluator
    
    private(set) var chapter: Chapter
    private(set) var scenes: [GameScene]
    private(set) var availableObjects: [GameObject]
    private(set) var phase: DragDropPhase = .playing
    
    init(
        chapter: Chapter,
        reactionEvaluator: ReactionEvaluating = DefaultReactionEvaluator(),
        completionEvaluator: CompletionEvaluator = CompletionEvaluator()
    ) {
        self.chapter = chapter
        self.scenes = chapter.scenes
        self.availableObjects = chapter.objects
        self.reactionEvaluator = reactionEvaluator
        self.completionEvaluator = completionEvaluator
        reevaluateAllReactions()
    }
    
    /// Total number of scenes in this chapter.
    var totalSceneCount: Int { scenes.count }
    
    /// Number of scenes currently holding an item.
    var placedObjectCount: Int {
        scenes.reduce(0) { $0 + ($1.currentObject != nil ? 1 : 0) }
    }
    
    /// Total objects available in tray.
    var totalObjectCount: Int { chapter.objects.count }
    
    /// Place or replace an object in a specific scene.
    /// If an item is already placed in that scene, it is REPLACED with the new item.
    /// Triggers dynamic re-evaluation across all 3 scenes without auto-ending the chapter.
    @discardableResult
    func placeObject(_ object: GameObject, inScene sceneID: UUID) -> Bool {
        guard phase == .playing else { return false }
        guard let sceneIndex = scenes.firstIndex(where: { $0.id == sceneID }) else { return false }
        
        // Replace or set current object in the target scene
        scenes[sceneIndex].currentObject = object
        
        // Dynamic global re-evaluation for ALL 3 scenes
        reevaluateAllReactions()
        
        return true
    }
    
    /// Remove an object from a scene.
    /// Triggers dynamic re-evaluation across all 3 scenes.
    @discardableResult
    func removeObject(_ object: GameObject, fromScene sceneID: UUID) -> Bool {
        guard phase == .playing else { return false }
        guard let sceneIndex = scenes.firstIndex(where: { $0.id == sceneID }) else { return false }
        
        guard scenes[sceneIndex].currentObject?.id == object.id || scenes[sceneIndex].currentObject?.name == object.name else {
            return false
        }
        
        scenes[sceneIndex].currentObject = nil
        
        // Dynamic global re-evaluation for ALL 3 scenes
        reevaluateAllReactions()
        
        if phase == .completed {
            phase = .playing
        }
        
        return true
    }
    
    /// Explicitly finishes the chapter and transitions to the completion result overlay.
    func finishChapter() {
        phase = .completed
    }
    
    /// Recalculates character emotions for all scenes based on current global combinations.
    func reevaluateAllReactions() {
        let newEmotions = reactionEvaluator.evaluateReactions(for: scenes)
        for (index, emotion) in newEmotions.enumerated() {
            if scenes.indices.contains(index) {
                scenes[index].characterEmotion = emotion
            }
        }
    }
    
    /// Build summary result for chapter completion.
    func buildResult() -> ChapterResult {
        ChapterResult(
            chapterName: chapter.name,
            totalObjects: totalSceneCount,
            placedObjects: placedObjectCount,
            sceneStates: scenes.map { scene in
                ChapterResult.SceneResultEntry(
                    sceneName: scene.name,
                    objectNames: scene.currentObject != nil ? [scene.currentObject!.name] : [],
                    emotionName: scene.characterEmotion.displayName
                )
            }
        )
    }
    
    /// Reset the game session.
    func restart() {
        scenes = chapter.scenes.map { scene in
            var s = scene
            s.currentObject = nil
            s.characterEmotion = .neutral
            return s
        }
        availableObjects = chapter.objects
        phase = .playing
        reevaluateAllReactions()
    }
}
