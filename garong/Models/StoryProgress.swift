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
