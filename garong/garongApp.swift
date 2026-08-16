//
//  garongApp.swift
//  garong
//
//  Created by Indrayana Dian Prasetya on 11/08/26.
//

import SwiftUI

@main
struct garongApp: App {
    @AppStorage("hasSeenGarongOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainMenuView()
            } else {
                OnboardingView { hasSeenOnboarding = true }
            }
        }
    }
}
