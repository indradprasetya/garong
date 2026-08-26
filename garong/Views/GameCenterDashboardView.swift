//
//  GameCenterDashboardView.swift
//  garong
//
//  Created by Antigravity on 26/08/26.
//

import GameKit
import SwiftUI

public struct GameCenterDashboardView: UIViewControllerRepresentable {
    public var state: GKGameCenterViewControllerState
    public var leaderboardID: String?
    public var achievementID: String?
    @Environment(\.dismiss) private var dismiss

    public init(
        state: GKGameCenterViewControllerState = .default,
        leaderboardID: String? = nil,
        achievementID: String? = nil
    ) {
        self.state = state
        self.leaderboardID = leaderboardID
        self.achievementID = achievementID
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(dismissAction: {
            dismiss()
        })
    }

    public func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let gameCenterVC: GKGameCenterViewController
        if #available(iOS 14.0, *) {
            if let leaderboardID = leaderboardID {
                gameCenterVC = GKGameCenterViewController(
                    leaderboardID: leaderboardID,
                    playerScope: .global,
                    timeScope: .allTime
                )
            } else if let achievementID = achievementID {
                gameCenterVC = GKGameCenterViewController(achievementID: achievementID)
            } else {
                gameCenterVC = GKGameCenterViewController(state: state)
            }
        } else {
            gameCenterVC = GKGameCenterViewController()
        }

        gameCenterVC.gameCenterDelegate = context.coordinator
        return gameCenterVC
    }

    public func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    public final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        private let dismissAction: () -> Void

        init(dismissAction: @escaping () -> Void) {
            self.dismissAction = dismissAction
        }

        public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true) { [weak self] in
                self?.dismissAction()
            }
        }
    }
}
