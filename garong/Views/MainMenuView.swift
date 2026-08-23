import SwiftUI
import Combine

struct MainMenuView: View {

    @ObservedObject private var localization = AppLocalization.shared
    @State private var showChapterSelection = false
    @State private var showSettings = false
    @State private var showGuidebook = false
    @State private var isLoading = false
    @State private var useFrame1: Bool = true
    @State private var timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    

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


                    // ==========================================
                    // START HOMEPAGE ASSET
                    // ==========================================

                    Image(.mainmenuBg)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.999
                        )
                        .zIndex(1)
                    
                    Image(.kinarioTitle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 450)
                        .position(
                            x: width * 0.72,
                            y: height * 0.38
                        )


                    // ==========================================
                    // INVISIBLE START BUTTON
                    // ==========================================

                    Button {
                        SoundManager.shared.play(.buttonTap)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isLoading = true
                        }
                    } label: {

                        let buttonPrefix = localization.language == .indonesian ? "mulai_button" : "start_button"
                        Image(useFrame1 ? "\(buttonPrefix)_1" : "\(buttonPrefix)_2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 130)
                            .animation(.easeInOut(duration: 0.01), value: useFrame1)
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: width * 0.72,
                        y: height * 0.6
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
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    useFrame1.toggle()
                }
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
