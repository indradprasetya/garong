//
//  StoryLogic.swift
//  garong
//

import Foundation

enum StoryLoader {
    static func load(named name: String, bundle: Bundle = .main) throws -> StoryDefinition {
        let cleanName = name.replacingOccurrences(of: ".json", with: "")
        let url = bundle.url(forResource: cleanName, withExtension: "json") ??
                  bundle.url(forResource: cleanName, withExtension: "json", subdirectory: "Resources") ??
                  bundle.url(forResource: cleanName, withExtension: "json", subdirectory: "Resources/Stories")
        guard let url else {
            throw StoryValidationError.missingStory(name)
        }

        let story = try JSONDecoder().decode(StoryDefinition.self, from: Data(contentsOf: url))
        try story.validate()
        return story
    }
}

struct StoryRunner {
    let story: StoryDefinition
    private let outcomesByKey: [String: StoryOutcome]

    init(story: StoryDefinition) throws {
        try story.validate()
        self.story = story
        outcomesByKey = Dictionary(uniqueKeysWithValues: story.outcomes.map { ($0.actionIDs.joined(separator: "|"), $0) })
    }

    var initialOutcome: StoryOutcome? {
        story.outcomes.first
    }

    func outcome(for actionIDs: [String]) -> StoryOutcome? {
        outcomesByKey[actionIDs.joined(separator: "|")]
    }

    func partialOutcome(matching prefixActionIDs: [String]) -> StoryOutcome? {
        guard !prefixActionIDs.isEmpty else { return initialOutcome }
        return outcomesByKey.values.first { outcome in
            let actionIDs = outcome.actionIDs
            guard actionIDs.count >= prefixActionIDs.count else { return false }
            return zip(actionIDs, prefixActionIDs).allSatisfy { $0 == $1 }
        }
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

        guard gridCount > 0, choiceCount > 0, !actions.isEmpty,
              maximumPlacements > choiceCount,
              starThresholds.threeStars >= choiceCount,
              starThresholds.threeStars < starThresholds.twoStars,
              starThresholds.twoStars < maximumPlacements,
              grids.count == gridCount,
              Set(grids.map(\.order)) == Set(1...gridCount),
              !shortTitle.en.isEmpty, !shortTitle.id.isEmpty,
              !title.en.isEmpty, !title.id.isEmpty,
              !description.en.isEmpty, !description.id.isEmpty,
              !completionSummary.en.isEmpty, !completionSummary.id.isEmpty,
              !completionTip.en.isEmpty, !completionTip.id.isEmpty,
              !placementLimitMessage.en.isEmpty, !placementLimitMessage.id.isEmpty,
              characters.allSatisfy({ placementLimitMessage.en.contains($0.displayName) }) else {
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
            throw StoryValidationError.invalidOutcome("outcomeCount (expected \(expectedOutcomeCount), got \(outcomes.count))")
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
                let slots = state.visualSlotsList
                guard gridIDs.contains(state.gridID),
                      !slots.isEmpty else {
                    throw StoryValidationError.invalidOutcome(key)
                }

                for slot in slots {
                    guard slot.characterIDs.allSatisfy(characterIDs.contains) else {
                        throw StoryValidationError.invalidOutcome(key)
                    }
                }

                if let bubble = state.textBubble {
                    guard !bubble.text.en.isEmpty,
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
