//
//  GameScene.swift
//  garong
//

import Foundation

/// Represents one of the three interactive scenes in the gameplay view.
/// Each scene holds at most 1 item at a time.
struct GameScene: Identifiable, Equatable {
    let id: UUID
    let name: String           // e.g. "Scene 1"
    let description: String    // e.g. "A child sitting alone"
    var currentObject: GameObject?  // Single item currently placed in this scene
    var characterEmotion: CharacterEmotion  // Current reaction
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        currentObject: GameObject? = nil,
        characterEmotion: CharacterEmotion = .neutral
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.currentObject = currentObject
        self.characterEmotion = characterEmotion
    }
    
    /// Helper array representation for compatibility.
    var objects: [GameObject] {
        if let obj = currentObject {
            return [obj]
        } else {
            return []
        }
    }
    
    /// Whether this scene currently contains an object.
    var hasObjects: Bool { currentObject != nil }
    
    /// Number of objects in this scene (0 or 1).
    var objectCount: Int { currentObject != nil ? 1 : 0 }
}
