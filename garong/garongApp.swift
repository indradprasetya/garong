//
//  garongApp.swift
//  garong
//
//  Created by Indrayana Dian Prasetya on 11/08/26.
//

import SwiftUI

@main
struct garongApp: App {
    // Version the key whenever onboarding content changes so an installed build
    // does not silently skip a newly introduced onboarding screen.
    @AppStorage("hasSeenGarongOnboardingV2") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    MainMenuView()
                } else {
                    OnboardingView { hasSeenOnboarding = true }
                }
            }
            .task {
                BackgroundMusicManager.shared.play()
            }
        }
    }
}
