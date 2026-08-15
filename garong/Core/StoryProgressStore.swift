//
//  StoryProgressStore.swift
//  garong
//

import Foundation

struct StoryProgressStore {
    private static let storageKey = "storyProgressByStoryID"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func progress(for storyID: String) throws -> [StoryProgressStep] {
        try allProgress()[storyID] ?? []
    }

    func save(_ progress: [StoryProgressStep], for storyID: String) throws {
        var stored = try allProgress()
        stored[storyID] = progress
        defaults.set(try JSONEncoder().encode(stored), forKey: Self.storageKey)
    }

    func reset(storyID: String) throws {
        var stored = try allProgress()
        stored.removeValue(forKey: storyID)
        defaults.set(try JSONEncoder().encode(stored), forKey: Self.storageKey)
    }

    func resetAll() {
        defaults.removeObject(forKey: Self.storageKey)
    }

    private func allProgress() throws -> [String: [StoryProgressStep]] {
        guard let data = defaults.data(forKey: Self.storageKey) else { return [:] }
        return try JSONDecoder().decode([String: [StoryProgressStep]].self, from: data)
    }
}
