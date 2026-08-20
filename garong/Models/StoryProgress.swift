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
