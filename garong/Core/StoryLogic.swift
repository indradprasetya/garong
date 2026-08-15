//
//  StoryLogic.swift
//  garong
//

import Foundation

enum StoryLoader {
    static func load(named name: String, bundle: Bundle = .main) throws -> StoryDefinition {
        let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Resources/Stories") ??
                  bundle.url(forResource: name, withExtension: "json")
        guard let url else {
            throw StoryValidationError.missingStory(name)
        }

        let story = try JSONDecoder().decode(StoryDefinition.self, from: Data(contentsOf: url))
        try story.validate()
        return story
    }
}

struct StoryRunner {
    private let outcomesByKey: [String: StoryOutcome]

    init(story: StoryDefinition) throws {
        try story.validate()
        outcomesByKey = Dictionary(uniqueKeysWithValues: story.outcomes.map { ($0.actionIDs.joined(separator: "|"), $0) })
    }

    func outcome(for actionIDs: [String]) -> StoryOutcome? {
        outcomesByKey[actionIDs.joined(separator: "|")]
    }
}

enum StoryValidationError: Error, LocalizedError {
    case missingStory(String)
    case duplicateID(String)
    case invalidGrid(String)
    case invalidOutcome(String)

    var errorDescription: String? {
        switch self {
        case .missingStory(let name):
            return "Story JSON not found: \(name).json"
        case .duplicateID(let id):
            return "Duplicate story ID: \(id)"
        case .invalidGrid(let id):
            return "Invalid story grid: \(id)"
        case .invalidOutcome(let actionIDs):
            return "Invalid story outcome: \(actionIDs)"
        }
    }
}

private extension StoryDefinition {
    func validate() throws {
        let actionIDs = try uniqueIDs(actions.map(\.id))
        let characterIDs = try uniqueIDs(characters.map(\.id))
        let gridIDs = try uniqueIDs(grids.map(\.id))
        let charactersByID = Dictionary(uniqueKeysWithValues: characters.map { ($0.id, $0) })

        guard gridCount > 0, choiceCount > 0, !actions.isEmpty,
              grids.count == gridCount,
              Set(grids.map(\.order)) == Set(1...gridCount),
              !title.en.isEmpty, !title.id.isEmpty,
              !description.en.isEmpty, !description.id.isEmpty else {
            throw StoryValidationError.invalidGrid("story")
        }

        guard actions.allSatisfy({ !$0.name.en.isEmpty && !$0.name.id.isEmpty }),
              characters.allSatisfy({
                  !$0.expressionIDs.isEmpty && Set($0.expressionIDs).count == $0.expressionIDs.count
              }) else {
            throw StoryValidationError.duplicateID("localized content or expression")
        }

        let expectedOutcomeCount = (0..<choiceCount).reduce(1) { count, _ in count * actions.count }
        guard outcomes.count == expectedOutcomeCount else {
            throw StoryValidationError.invalidOutcome("outcomeCount")
        }

        var seenSequences = Set<String>()
        for outcome in outcomes {
            let key = outcome.actionIDs.joined(separator: "|")
            guard outcome.actionIDs.count == choiceCount,
                  outcome.actionIDs.allSatisfy(actionIDs.contains),
                  outcome.states.count == gridCount,
                  seenSequences.insert(key).inserted else {
                throw StoryValidationError.invalidOutcome(key)
            }

            for state in outcome.states {
                guard gridIDs.contains(state.gridID),
                      (1...2).contains(state.characterSlots.count),
                      Set(state.characterSlots.map(\.slot)) == Set(1...state.characterSlots.count),
                      Set(state.characterSlots.map(\.characterID)).count == state.characterSlots.count else {
                    throw StoryValidationError.invalidOutcome(key)
                }

                for slot in state.characterSlots {
                    guard characterIDs.contains(slot.characterID),
                          charactersByID[slot.characterID]?.expressionIDs.contains(slot.expressionID) == true else {
                        throw StoryValidationError.invalidOutcome(key)
                    }
                }

                if let bubble = state.textBubble {
                    guard state.characterSlots.contains(where: { $0.characterID == bubble.speakerID }),
                          !bubble.text.en.isEmpty,
                          !bubble.text.id.isEmpty else {
                        throw StoryValidationError.invalidOutcome(key)
                    }
                }
            }

            guard Set(outcome.states.map(\.gridID)) == gridIDs else {
                throw StoryValidationError.invalidOutcome(key)
            }
        }
    }

    func uniqueIDs(_ ids: [String]) throws -> Set<String> {
        let set = Set(ids)
        guard set.count == ids.count else { throw StoryValidationError.duplicateID(ids.joined(separator: ",")) }
        return set
    }
}
