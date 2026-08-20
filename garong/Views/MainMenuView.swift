import SwiftUI

struct MainMenuView: View {

    @State private var showStorySelection = false
    @State private var showSettings = false

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

                        showStorySelection = true

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
            // STORY PICK
            // ==========================================

            .navigationDestination(
                isPresented: $showStorySelection
            ) {

                StorySelectionView(
                    stories: StoryCatalog.gameStories
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
