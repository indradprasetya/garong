import SwiftUI

struct MainMenuView: View {

    @State private var showChapterSelection = false
    @State private var showGuidebook = false
    @State private var showSettings = false
    @State private var showGuidebook = false
    @State private var isLoading = false

    var body: some View {

        NavigationStack {

            GeometryReader { geometry in

                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {

                    // =====================================================
                    // BACKGROUND
                    // =====================================================

                    Image("StoriesGreenGrid")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: width,
                            height: height
                        )
                        .clipped()
                        .ignoresSafeArea()


                    // =====================================================
                    // HOME ARTWORK
                    // =====================================================

                    Image("HomeArtwork")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.98,
                            height: height * 0.98
                        )
                        .position(
                            x: width * 0.50,
                            y: height * 0.52
                        )


                    // =====================================================
                    // START BUTTON
                    // langsung ke ChapterSelectionView
                    // =====================================================

                    Button {
                        SoundManager.shared.play(.buttonTap)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLoading = true
                        }
                    } label: {

                        Image("StartButton")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: width * 0.39
                            )
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: width * 0.64,
                        y: height * 0.56
                    )
                    .zIndex(2)


                    // ==========================================
                    // TOP RIGHT BUTTONS (GUIDE + SETTING)
                    // ==========================================

                    VStack {
                        HStack(spacing: 12) {
                            Spacer()

                            // GUIDEBOOK BUTTON (Beside Setting Button)
                            Button {
                                SoundManager.shared.play(.buttonTap)
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showGuidebook = true
                                }
                            } label: {
                                Image("guide_button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 56, height: 56)
                            }
                            .buttonStyle(.plain)

                            // SETTING BUTTON
                            Button {
                                SoundManager.shared.play(.buttonTap)
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showSettings = true
                                }
                            } label: {
                                Image("setting_button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 56, height: 56)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    .padding(.trailing, 64)
                    .zIndex(3)


                    // ==========================================
                    // SETTINGS MODAL OVERLAY
                    // ==========================================

                    if showSettings {
                        SettingView(
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showSettings = false
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        .zIndex(10)
                    }


                    // ==========================================
                    // GUIDEBOOK MODAL OVERLAY
                    // ==========================================

                    if showGuidebook {
                        GuidebookView(
                            onBack: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showGuidebook = false
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        .zIndex(10)
                    }


                    // ==========================================
                    // LOADING VIEW OVERLAY
                    // ==========================================

                    if isLoading {
                        LoadingView(
                            duration: 2.0,
                            onComplete: {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    isLoading = false
                                    showStorySelection = true
                                }
                            }
                        )
                        .transition(.opacity)
                        .zIndex(20)
                    }
                }
                .frame(
                    width: width,
                    height: height
                )
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)


            // =========================================================
            // START → CHAPTER SELECTION
            // =========================================================

            .navigationDestination(
                isPresented: $showChapterSelection
            ) {

                ChapterSelectionView(
                    story: StoryCatalog.gameStories[0]
                )
            }


            // =========================================================
            // GUIDEBOOK
            // =========================================================

            .navigationDestination(
                isPresented: $showGuidebook
            ) {

                GuidebookPlaceholderView()
            }


            // =========================================================
            // SETTINGS
            // =========================================================

            .navigationDestination(
                isPresented: $showSettings
            ) {

                SettingsPlaceholderView()
            }
        }
    }
}


// =============================================================
// MARK: - GUIDEBOOK PLACEHOLDER
// =============================================================

private struct GuidebookPlaceholderView: View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {

        ZStack {

            Image("StoriesGreenGrid")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()


            VStack(spacing: 24) {

                Text("GUIDEBOOK")
                    .font(
                        .system(
                            size: 40,
                            weight: .black,
                            design: .rounded
                        )
                    )

                Button {

                    dismiss()

                } label: {

                    Text("Back")
                        .font(
                            .system(
                                size: 20,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


// =============================================================
// MARK: - SETTINGS PLACEHOLDER
// =============================================================

private struct SettingsPlaceholderView: View {

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {

        ZStack {

            Image("StoriesGreenGrid")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()


            VStack(spacing: 24) {

                Text("SETTINGS")
                    .font(
                        .system(
                            size: 40,
                            weight: .black,
                            design: .rounded
                        )
                    )

                Button {

                    dismiss()

                } label: {

                    Text("Back")
                        .font(
                            .system(
                                size: 20,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


// =============================================================
// MARK: - PREVIEW
// =============================================================

#Preview {
    MainMenuView()
}
