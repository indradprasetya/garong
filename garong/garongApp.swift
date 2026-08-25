import SwiftUI

@main
struct garongApp: App {
    @AppStorage("hasSeenLetter") private var hasSeenLetter = false
    @State private var isShowingOnboarding = true
    @State private var isShowingLetter = false

    init() {
        AppFont.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isShowingOnboarding {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.65)) {
                            isShowingOnboarding = false
                            if !hasSeenLetter {
                                isShowingLetter = true
                            }
                        }
                    }
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 1.015)
                        )
                    )

                } else if isShowingLetter {
                    LetterView {
                        withAnimation(.easeInOut(duration: 0.65)) {
                            hasSeenLetter = true
                            isShowingLetter = false
                        }
                    }
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 0.985)
                        )
                    )

                } else {
                    MainMenuView()
                        .transition(
                            .opacity.combined(
                                with: .scale(scale: 0.985)
                            )
                        )
                }
            }
            .preferredColorScheme(.light)
            .ignoresSafeArea()
            .onAppear {
                BackgroundMusicManager.shared.play()
            }
        }
    }
}
