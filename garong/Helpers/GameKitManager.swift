//
//  GameKitManager.swift
//  garong
//
//  Created by Antigravity on 26/08/26.
//

import GameKit
import SwiftUI
import Combine
import UIKit

@MainActor
public final class GameKitManager: NSObject, ObservableObject {
    public static let shared = GameKitManager()

    // MARK: - Published Properties
    @Published public private(set) var isAuthenticated: Bool = false
    @Published public private(set) var localPlayer: GKLocalPlayer = .local
    @Published public private(set) var localPlayerDisplayName: String = ""
    @Published public private(set) var localPlayerAvatar: UIImage? = nil
    @Published public private(set) var lastErrorMessage: String? = nil
    @Published public var showGameCenterDashboard: Bool = false

    // MARK: - Game Center Identifiers
    public struct Identifiers {
        // Leaderboards
        public static let leaderboardTotalStars = "com.vidya.kinario.leaderboard.total_stars"
        public static let leaderboardStoriesCompleted = "com.vidya.kinario.leaderboard.stories_completed"

        // Achievements
        public static let achievementFirstStory = "com.vidya.kinario.achievement.first_story"
        public static let achievementAllStories = "com.vidya.kinario.achievement.all_stories"
        public static let achievementThreeStars = "com.vidya.kinario.achievement.three_stars"
        public static let achievementMastery = "com.vidya.kinario.achievement.mastery"
    }

    public override init() {
        super.init()
    }

    // MARK: - Authentication
    public func authenticateLocalPlayer(presentingViewController: UIViewController? = nil) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }

            if let viewController = viewController {
                // Present authentication view controller if needed (e.g. sign in modal)
                let presenter = presentingViewController ?? self.topViewController()
                presenter?.present(viewController, animated: true)
                return
            }

            if let error = error {
                self.lastErrorMessage = error.localizedDescription
                self.isAuthenticated = false
                print("[GameKitManager] Authentication error: \(error.localizedDescription)")
                return
            }

            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                self.localPlayer = GKLocalPlayer.local
                self.localPlayerDisplayName = GKLocalPlayer.local.displayName
                self.lastErrorMessage = nil
                print("[GameKitManager] Authenticated successfully as \(GKLocalPlayer.local.displayName)")

                // Load player photo
                GKLocalPlayer.local.loadPhoto(for: .small) { [weak self] image, photoError in
                    Task { @MainActor [weak self] in
                        if let image = image {
                            self?.localPlayerAvatar = image
                        } else if let photoError = photoError {
                            print("[GameKitManager] Photo load error: \(photoError.localizedDescription)")
                        }
                    }
                }

                // Register Game Center listener if needed
                GKLocalPlayer.local.register(self)

                // Hide the on-screen floating access point (Game Center is in iOS Control Center / Game Overlay)
                GKAccessPoint.shared.isActive = false
            } else {
                self.isAuthenticated = false
                GKAccessPoint.shared.isActive = false
            }
        }
    }

    // MARK: - Access Point
    public func setAccessPoint(active: Bool, location: GKAccessPoint.Location = .topLeading, showHighlights: Bool = true) {
        GKAccessPoint.shared.location = location
        GKAccessPoint.shared.isActive = active
    }

    // MARK: - Score / Leaderboard Submission
    public func submitScore(_ score: Int, leaderboardID: String, context: Int = 0, completion: ((Error?) -> Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated && isAuthenticated else {
            print("[GameKitManager] Skipped submitScore: Local player is not authenticated.")
            completion?(nil)
            return
        }

        GKLeaderboard.submitScore(score, context: context, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("[GameKitManager] Submit score failed for \(leaderboardID): \(error.localizedDescription)")
            } else {
                print("[GameKitManager] Submitted score \(score) to \(leaderboardID)")
            }
            completion?(error)
        }
    }

    // MARK: - Achievement Reporting
    public func reportAchievement(identifier: String, percentComplete: Double, showsCompletionBanner: Bool = true, completion: ((Error?) -> Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated && isAuthenticated else {
            print("[GameKitManager] Skipped reportAchievement: Local player is not authenticated.")
            completion?(nil)
            return
        }

        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = min(100.0, max(0.0, percentComplete))
        achievement.showsCompletionBanner = showsCompletionBanner

        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("[GameKitManager] Report achievement failed for \(identifier): \(error.localizedDescription)")
            } else {
                print("[GameKitManager] Reported achievement \(identifier): \(achievement.percentComplete)%")
            }
            completion?(error)
        }
    }

    // MARK: - Comprehensive Story Progress Reporter
    public func reportProgressAfterStoryCompletion(
        completedStoriesCount: Int,
        totalStoriesCount: Int,
        totalStars: Int,
        latestStoryStars: Int
    ) {
        guard isAuthenticated else { return }

        // 1. Leaderboards
        submitScore(totalStars, leaderboardID: Identifiers.leaderboardTotalStars)
        submitScore(completedStoriesCount, leaderboardID: Identifiers.leaderboardStoriesCompleted)

        // 2. First Story Achievement
        if completedStoriesCount >= 1 {
            reportAchievement(identifier: Identifiers.achievementFirstStory, percentComplete: 100.0)
        }

        // 3. 3-Star Achievement
        if latestStoryStars >= 3 {
            reportAchievement(identifier: Identifiers.achievementThreeStars, percentComplete: 100.0)
        }

        // 4. All Stories Progress Achievement
        if totalStoriesCount > 0 {
            let progress = (Double(completedStoriesCount) / Double(totalStoriesCount)) * 100.0
            reportAchievement(identifier: Identifiers.achievementAllStories, percentComplete: progress)

            // 5. Mastery (All 3 stars across all stories)
            let maxPossibleStars = totalStoriesCount * 3
            if totalStars >= maxPossibleStars {
                reportAchievement(identifier: Identifiers.achievementMastery, percentComplete: 100.0)
            }
        }
    }

    // MARK: - Helper: Find Topmost View Controller
    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseController: UIViewController? = base ?? {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return nil
            }
            return keyWindow.rootViewController
        }()

        if let nav = baseController as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = baseController?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseController
    }
}

// MARK: - GKLocalPlayerListener Extension
extension GameKitManager: GKLocalPlayerListener {}
