//
//  GameKitManagerTests.swift
//  garong
//
//  Created by Antigravity on 26/08/26.
//

import Foundation
import GameKit

@main
struct GameKitManagerTests {
    static func main() throws {
        // 1. Verify Identifiers
        precondition(
            GameKitManager.Identifiers.leaderboardTotalStars == "com.vidya.kinario.leaderboard.total_stars",
            "Total stars leaderboard ID mismatch"
        )
        precondition(
            GameKitManager.Identifiers.leaderboardStoriesCompleted == "com.vidya.kinario.leaderboard.stories_completed",
            "Stories completed leaderboard ID mismatch"
        )
        precondition(
            GameKitManager.Identifiers.achievementFirstStory == "com.vidya.kinario.achievement.first_story",
            "First story achievement ID mismatch"
        )
        precondition(
            GameKitManager.Identifiers.achievementAllStories == "com.vidya.kinario.achievement.all_stories",
            "All stories achievement ID mismatch"
        )
        precondition(
            GameKitManager.Identifiers.achievementThreeStars == "com.vidya.kinario.achievement.three_stars",
            "Three stars achievement ID mismatch"
        )
        precondition(
            GameKitManager.Identifiers.achievementMastery == "com.vidya.kinario.achievement.mastery",
            "Mastery achievement ID mismatch"
        )

        // 2. Verify GameKitManager shared instance accessibility
        let manager = GameKitManager.shared
        precondition(!manager.isAuthenticated, "Default manager in test runner without Game Center login must be unauthenticated")

        print("GameKitManagerTests passed successfully.")
    }
}
