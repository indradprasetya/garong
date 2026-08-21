import SwiftUI

struct MainMenuView: View {

    @State private var showChapterSelection = false
    @State private var showSettings = false
    @State private var showGuidebook = false
    @State private var isLoading = false

    var body: some View {

        NavigationStack {

            GeometryReader { geo in

                let width = geo.size.width
                let height = geo.size.height

                ZStack {

                    // ==========================================
                    // BACKGROUND
                    // ==========================================

                    Image("StoriesGreenGrid")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: width,
                            height: height
                        )
                        .clipped()


                    // ==========================================
                    // START HOMEPAGE ASSET
                    // ==========================================

                    Image("Starthomepage")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.999
                        )
                        .zIndex(1)


                    // ==========================================
                    // INVISIBLE START BUTTON
                    // ==========================================

                    Button {
                        SoundManager.shared.play(.buttonTap)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLoading = true
                        }
                    } label: {

                        Rectangle()
                            .fill(Color.clear)
                            .frame(
                                width: width * 0.35,
                                height: height * 0.20
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: width * 0.65,
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
                                    .frame(width: 64, height: 64)
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
                                    .frame(width: 64, height: 64)
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
                                    showChapterSelection = true
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
                .clipped()
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)


            // ==========================================
            // CHAPTER PICK
            // ==========================================

            .navigationDestination(
                isPresented: $showChapterSelection
            ) {
                ChapterSelectionView(
                    stories: StoryCatalog.stories
                )
            }
        }
    }
}


// ==========================================
// PREVIEW
// ==========================================

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
