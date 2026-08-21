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
    let language: String
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
        language: String = AppLocalization.shared.languageCode,
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
        self.language = language
        self.isUnlocked = isUnlocked
        self.storyDefinition = storyDefinition
    }

    init(storyItem: StoryChapterItem, language: String = AppLocalization.shared.languageCode) {
        self.id = UUID()
        self.number = storyItem.chapterNumber
        self.name = storyItem.storyDefinition?.title.localized(language: language)
            ?? AppLocalization.shared.text("story.chapterFallback", language: language, storyItem.chapterNumber)
        self.description = storyItem.storyDefinition?.description.localized(language: language) ?? ""
        self.language = language
        self.isUnlocked = storyItem.isUnlocked
        self.completionRule = .allObjectsPlaced
        self.storyDefinition = storyItem.storyDefinition

        if let story = storyItem.storyDefinition {
            let firstOutcome = story.outcomes.first
            self.scenes = story.grids.enumerated().map { index, grid in
                let initialState = firstOutcome?.states.first(where: { $0.gridID == grid.id })
                let initialImageNames: [String] = initialState?.visualSlotsList.map { visualSlot in
                    let asset = visualSlot.assetID.isEmpty ? (visualSlot.characterIDs.first ?? "") : visualSlot.assetID
                    return AssetFallbackHelper.imageName(for: asset)
                } ?? []

                let charNames = !initialImageNames.isEmpty
                    ? initialImageNames
                    : story.characters.map { AssetFallbackHelper.imageName(for: $0.id) }

                let initialSpeechBubble = (index == 0)
                    ? initialState?.textBubble?.text.localized(language: language)
                    : nil
                let dropSlots: [GameDropSlot]
                let isOutcomeGrid: Bool
                if let jsonSlots = grid.dropSlots, !jsonSlots.isEmpty {
                    isOutcomeGrid = false
                    dropSlots = jsonSlots.map { slot in
                        let label: String
                        if let targetCharID = slot.targetCharacterID {
                            let charName = story.characters.first(where: { $0.id == targetCharID })?.displayName ?? targetCharID.capitalized
                            label = AppLocalization.shared.text("scene.forCharacter", language: language, charName)
                        } else {
                            label = AppLocalization.shared.text("scene.scene", language: language)
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
                    name: isOutcomeGrid
                        ? AppLocalization.shared.text("scene.outcome", language: language)
                        : AppLocalization.shared.text("scene.grid", language: language, grid.order),
                    description: isOutcomeGrid
                        ? AppLocalization.shared.text("scene.finalResult", language: language)
                        : AppLocalization.shared.text("scene.number", language: language, grid.order),
                    dropSlots: dropSlots,
                    speechBubbleText: initialSpeechBubble,
                    characterImageNames: charNames.isEmpty ? ["fallback_globe"] : charNames,
                    isUnlocked: index == 0,
                    backgroundID: grid.backgroundID ?? "background_classroom"
                )
            }
            self.objects = story.actions.map { action in
                GameObject(
                    name: action.name.localized(language: language),
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
