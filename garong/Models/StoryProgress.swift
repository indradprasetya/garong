//
//  StoryProgress.swift
//  garong
//

import Foundation

struct StoryProgressStep: Codable, Equatable {
    let sourceGridID: String
    let placements: [StoryProgressPlacement]
}

struct StoryProgressPlacement: Codable, Equatable {
    let slotID: String
    let actionID: String
}

enum StoryRunStatus: String, Codable, Equatable {
    case playing
    case needsBreak
}

struct StoryActiveRun: Codable, Equatable {
    let steps: [StoryProgressStep]
    let placementCount: Int
    let status: StoryRunStatus
}

struct StoryCompletion: Codable, Equatable {
    let bestStars: Int
    let bestPlacementCount: Int
}

struct StoryProgressState: Codable, Equatable {
    var activeRun: StoryActiveRun?
    var completion: StoryCompletion?

    init(activeRun: StoryActiveRun? = nil, completion: StoryCompletion? = nil) {
        self.activeRun = activeRun
        self.completion = completion
    }
}

enum ChapterProgressStatus: Equatable {
    case completed(stars: Int)
    case current
    case locked

    static func resolve(
        at index: Int,
        completions: [StoryCompletion?],
        previousStoriesComplete: Bool = true
    ) -> Self {
        guard previousStoriesComplete else { return .locked }
        guard completions.indices.contains(index) else { return .locked }
        if let completion = completions[index] {
            return .completed(stars: completion.bestStars)
        }
        return completions[..<index].allSatisfy { $0 != nil } ? .current : .locked
    }
}

enum ChapterPageDirection: Equatable {
    case previous
    case next
}

enum ChapterPageNavigation {
    static func destinationIndex(
        from index: Int,
        direction: ChapterPageDirection,
        pageCount: Int
    ) -> Int {
        guard pageCount > 1 else { return 0 }
        switch direction {
        case .previous:
            return max(0, index - 1)
        case .next:
            return min(pageCount - 1, index + 1)
        }
    }
}
