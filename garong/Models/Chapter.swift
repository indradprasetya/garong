//  Chapter.swift
//  garong
//

import Foundation

/// Defines how a chapter is considered complete.
enum CompletionRule: Equatable {
    /// All objects must be placed into scenes.
    case allObjectsPlaced
    /// Future: specific object-scene combinations required.
    case specificObjectsInScenes
}

/// Represents a game chapter containing scenes and objects.
struct Chapter: Identifiable, Equatable {
    let id: UUID
    let number: Int
    let name: String
    let description: String
    let scenes: [GameScene]
    let objects: [GameObject]
    let completionRule: CompletionRule
    var isUnlocked: Bool
    
    init(
        id: UUID = UUID(),
        number: Int,
        name: String,
        description: String,
        scenes: [GameScene],
        objects: [GameObject],
        completionRule: CompletionRule = .allObjectsPlaced,
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.number = number
        self.name = name
        self.description = description
        self.scenes = scenes
        self.objects = objects
        self.completionRule = completionRule
        self.isUnlocked = isUnlocked
    }
}
