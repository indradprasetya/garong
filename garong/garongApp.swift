import SwiftUI

@main
struct garongApp: App {
    @State private var isShowingOnboarding = true

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
                        }
                    }
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 1.015)
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
            .ignoresSafeArea()
            .onAppear {
                BackgroundMusicManager.shared.play()
            }
        }
    }
}
