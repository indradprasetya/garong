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
    var storyDefinition: StoryDefinition?

    init(
        id: UUID = UUID(),
        number: Int,
        name: String,
        description: String,
        scenes: [GameScene],
        objects: [GameObject],
        completionRule: CompletionRule = .allObjectsPlaced,
        isUnlocked: Bool = false,
        storyDefinition: StoryDefinition? = nil
    ) {
        self.id = id
        self.number = number
        self.name = name
        self.description = description
        self.scenes = scenes
        self.objects = objects
        self.completionRule = completionRule
        self.isUnlocked = isUnlocked
        self.storyDefinition = storyDefinition
    }

    init(storyItem: StoryChapterItem) {
        self.id = UUID()
        self.number = storyItem.chapterNumber
        self.name = storyItem.title
        self.description = storyItem.description
        self.isUnlocked = storyItem.isUnlocked
        self.completionRule = .allObjectsPlaced
        self.storyDefinition = storyItem.storyDefinition

        if let story = storyItem.storyDefinition {
            self.scenes = story.grids.enumerated().map { index, grid in
                let charNames = story.characters.map { AssetFallbackHelper.imageName(for: $0.id) }
                let dropSlots: [GameDropSlot]
                let isOutcomeGrid: Bool
                if let jsonSlots = grid.dropSlots, !jsonSlots.isEmpty {
                    isOutcomeGrid = false
                    dropSlots = jsonSlots.map { slot in
                        let label: String
                        if let targetCharID = slot.targetCharacterID {
                            let charName = story.characters.first(where: { $0.id == targetCharID })?.displayName ?? targetCharID.capitalized
                            label = "For \(charName)"
                        } else {
                            label = "Scene"
                        }
                        return GameDropSlot(
                            id: slot.id,
                            label: label,
                            targetCharacterID: slot.targetCharacterID,
                            currentObject: nil
                        )
                    }
                } else {
                    isOutcomeGrid = true
                    dropSlots = []
                }
                
                return GameScene(
                    name: isOutcomeGrid ? "Outcome" : "Grid \(grid.order)",
                    description: isOutcomeGrid ? "Final Result" : "Scene \(grid.order)",
                    dropSlots: dropSlots,
                    characterImageNames: charNames.isEmpty ? ["Globe"] : charNames,
                    isUnlocked: index == 0
                )
            }
            self.objects = story.actions.map { action in
                GameObject(
                    name: action.name.en,
                    symbol: AssetFallbackHelper.actionImageName(for: action.id),
                    sfSymbol: AssetFallbackHelper.sfSymbol(for: action.id)
                )
            }
        } else {
            self.scenes = []
            self.objects = []
        }
    }
    
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        lhs.id == rhs.id && lhs.number == rhs.number && lhs.name == rhs.name && lhs.isUnlocked == rhs.isUnlocked
    }
}

