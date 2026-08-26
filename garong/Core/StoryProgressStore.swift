//
//  StoryProgressStore.swift
//  garong
//

import Foundation

struct StoryProgressStore {
    private static let storageKey = "storyStateByStoryID"
    private static let legacyStorageKey = "storyProgressByStoryID"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func state(for storyID: String) throws -> StoryProgressState {
        var state = try allStates()[storyID] ?? StoryProgressState()
        if state.completion != nil {
            state.activeRun = nil
        }
        return state
    }

    func saveActiveRun(_ activeRun: StoryActiveRun, for storyID: String) throws {
        var stored = try allStates()
        var state = stored[storyID] ?? StoryProgressState()
        guard state.completion == nil else { return }
        state.activeRun = activeRun
        stored[storyID] = state
        defaults.set(try JSONEncoder().encode(stored), forKey: Self.storageKey)
    }

    func complete(storyID: String, stars: Int, placementCount: Int) throws {
        var stored = try allStates()
        var state = stored[storyID] ?? StoryProgressState()
        let result = StoryCompletion(bestStars: stars, bestPlacementCount: placementCount)
        if let best = state.completion {
            if stars > best.bestStars || (stars == best.bestStars && placementCount < best.bestPlacementCount) {
                state.completion = result
            }
        } else {
            state.completion = result
        }
        state.activeRun = nil
        stored[storyID] = state
        defaults.set(try JSONEncoder().encode(stored), forKey: Self.storageKey)

        Task { @MainActor in
            let totalCompleted = stored.values.compactMap(\.completion).count
            let totalStars = stored.values.compactMap(\.completion).reduce(0) { $0 + $1.bestStars }
            let totalStoriesCount = StoryCatalog.stories.reduce(0) { $0 + $1.chapters.count }
            GameKitManager.shared.reportProgressAfterStoryCompletion(
                completedStoriesCount: totalCompleted,
                totalStoriesCount: totalStoriesCount > 0 ? totalStoriesCount : stored.count,
                totalStars: totalStars,
                latestStoryStars: stars
            )
        }
    }

    func clearActiveRun(storyID: String) throws {
        var stored = try allStates()
        guard var state = stored[storyID] else { return }
        state.activeRun = nil
        if state.completion == nil {
            stored.removeValue(forKey: storyID)
        } else {
            stored[storyID] = state
        }
        defaults.set(try JSONEncoder().encode(stored), forKey: Self.storageKey)
    }

    func reset(storyID: String) throws {
        var stored = try allStates()
        stored.removeValue(forKey: storyID)
        defaults.set(try JSONEncoder().encode(stored), forKey: Self.storageKey)
    }

    func resetAll() {
        defaults.removeObject(forKey: Self.storageKey)
        defaults.removeObject(forKey: Self.legacyStorageKey)
    }

    private func allStates() throws -> [String: StoryProgressState] {
        if let data = defaults.data(forKey: Self.storageKey) {
            return try JSONDecoder().decode([String: StoryProgressState].self, from: data)
        }
        guard let legacyData = defaults.data(forKey: Self.legacyStorageKey) else { return [:] }
        let legacy = try JSONDecoder().decode([String: [StoryProgressStep]].self, from: legacyData)
        return legacy.mapValues { steps in
            StoryProgressState(activeRun: StoryActiveRun(
                steps: steps,
                placementCount: steps.reduce(0) { $0 + $1.placements.count },
                status: .playing
            ))
        }
    }
}
