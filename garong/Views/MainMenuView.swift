import SwiftUI

struct MainMenuView: View {

    @State private var showChapterSelection = false
    @State private var showGuidebook = false
    @State private var showSettings = false

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

                        showChapterSelection = true

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


                    // =====================================================
                    // GUIDEBOOK BUTTON
                    // =====================================================

                    Button {

                        showGuidebook = true

                    } label: {

                        Image("GuidebookButton")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: width * 0.060
                            )
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: width * 0.84,
                        y: height * 0.075
                    )


                    // =====================================================
                    // SETTINGS BUTTON
                    // =====================================================

                    Button {

                        showSettings = true

                    } label: {

                        Image("SettingsButton")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: width * 0.060
                            )
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: width * 0.91,
                        y: height * 0.075
                    )
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
