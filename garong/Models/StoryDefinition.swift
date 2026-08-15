//
//  StoryDefinition.swift
//  garong
//

import Foundation

struct StoryDefinition: Codable {
    let schemaVersion: Int
    let id: String
    let title: LocalizedStoryText
    let description: LocalizedStoryText
    let gridCount: Int
    let choiceCount: Int
    let actions: [StoryActionDefinition]
    let characters: [StoryCharacterDefinition]
    let grids: [StoryGridDefinition]
    let outcomes: [StoryOutcome]
}

struct StoryActionDefinition: Codable {
    let id: String
    let name: LocalizedStoryText
}

struct StoryCharacterDefinition: Codable {
    let id: String
    let displayName: String
    let expressionIDs: [String]
}

struct StoryGridDefinition: Codable {
    let id: String
    let order: Int
    let locked: Bool
}

struct StoryOutcome: Codable {
    let actionIDs: [String]
    let states: [StoryGridState]
    let finalState: String
    let isIdeal: Bool
    let category: String
}

struct StoryGridState: Codable {
    let gridID: String
    let characterSlots: [StoryCharacterSlot]
    let textBubble: StoryTextBubble?
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
}
