//
//  StoryDefinition.swift
//  garong
//

import Foundation

struct StoryDefinition: Codable {
    let schemaVersion: Int
    let id: String
    let shortTitle: LocalizedStoryText
    let title: LocalizedStoryText
    let description: LocalizedStoryText
    let completionSummary: LocalizedStoryText
    let completionTip: LocalizedStoryText
    let hints: [LocalizedStoryText]?
    let initialState: String?
    let gridCount: Int
    let choiceCount: Int
    let maximumPlacements: Int
    let starThresholds: StoryStarThresholds
    let placementLimitMessage: LocalizedStoryText
    let actions: [StoryActionDefinition]
    let characters: [StoryCharacterDefinition]
    let grids: [StoryGridDefinition]
    let outcomes: [StoryOutcome]
}

struct StoryStarThresholds: Codable, Equatable {
    let threeStars: Int
    let twoStars: Int
}

struct StoryActionDefinition: Codable, Identifiable {
    let id: String
    let name: LocalizedStoryText
}

struct StoryCharacterDefinition: Codable, Identifiable {
    let id: String
    let displayName: String
    let expressionIDs: [String]
}

struct StoryGridDefinition: Codable, Identifiable {
    let id: String
    let order: Int
    let locked: Bool
    let backgroundID: String?
    let dropSlots: [StoryDropSlot]?
}

struct StoryDropSlot: Codable, Identifiable {
    let id: String
    let targetCharacterID: String?
}

struct StoryOutcome: Codable {
    let steps: [StoryOutcomeStep]?
    let actionIDsRaw: [String]?
    let states: [StoryGridState]
    let finalState: String
    let isIdeal: Bool
    let category: String

    enum CodingKeys: String, CodingKey {
        case steps
        case actionIDsRaw = "actionIDs"
        case states
        case finalState
        case isIdeal
        case category
    }

    var actionIDs: [String] {
        if let steps = steps, !steps.isEmpty {
            return steps.flatMap { $0.placements.map(\.actionID) }
        }
        return actionIDsRaw ?? []
    }
}

struct StoryOutcomeStep: Codable {
    let sourceGridID: String
    let placements: [StoryPlacement]
}

struct StoryPlacement: Codable {
    let slotID: String
    let actionID: String
}

struct StoryGridState: Codable {
    let gridID: String
    let visualSlots: [StoryVisualSlot]?
    let characterSlotsRaw: [StoryCharacterSlot]?
    let textBubble: StoryTextBubble?

    enum CodingKeys: String, CodingKey {
        case gridID
        case visualSlots
        case characterSlotsRaw = "characterSlots"
        case textBubble
    }

    var visualSlotsList: [StoryVisualSlot] {
        if let visualSlots = visualSlots, !visualSlots.isEmpty {
            return visualSlots
        }
        if let slots = characterSlotsRaw {
            return slots.map { slot in
                StoryVisualSlot(
                    slot: slot.slot,
                    characterIDs: [slot.characterID],
                    assetID: slot.expressionID,
                    assetType: "expression"
                )
            }
        }
        return []
    }
}

struct StoryVisualSlot: Codable {
    let slot: Int
    let characterIDs: [String]
    let assetID: String
    let assetType: String
}

struct StoryCharacterSlot: Codable {
    let slot: Int
    let characterID: String
    let expressionID: String
}

struct StoryTextBubble: Codable {
    let speakerID: String
    let text: LocalizedStoryText
}

struct LocalizedStoryText: Codable {
    let en: String
    let id: String

    func localized(language: String = "en") -> String {
        return language == "id" ? id : en
    }
}
