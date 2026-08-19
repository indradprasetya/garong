import SwiftUI

struct ChapterSelectionView: View {

    let storyNumber: Int
    let title: String
    let subtitle: String
    let chapters: [Chapter]

    @Environment(\.dismiss) private var dismiss

    // Untuk testing:
    // 1 = chapter 1 completed
    //     chapter 2 current
    //     chapter 3 locked
    @State private var completedChapterCount: Int = 1


    // MARK: - INIT

    init(story: GameStory) {
        self.storyNumber = story.number
        self.title = story.title
        self.subtitle = story.subtitle
        self.chapters = story.chapters
    }


    init(
        storyNumber: Int = 1,
        title: String,
        subtitle: String,
        chapters: [Chapter]
    ) {
        self.storyNumber = storyNumber
        self.title = title
        self.subtitle = subtitle
        self.chapters = chapters
    }


    // MARK: - BODY

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

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
                    .ignoresSafeArea()


                // ==========================================
                // SCHOOL PAPER + SCHOOL DRAWING
                // ==========================================

                Image("SchoolArtwork")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.98,
                        height: height * 1.08
                    )
                    .position(
                        x: width * 0.50,
                        y: height * 0.47
                    )


                // ==========================================
                // SCHOOL TITLE
                // ==========================================

                Image("School")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.255
                    )
                    .position(
                        x: width * 0.675,
                        y: height * 0.245
                    )


                // ==========================================
                // CHAPTER 1
                // ==========================================

                chapterButton(
                    chapterIndex: 0,
                    width: width,
                    height: height
                )
                .position(
                    x: width * 0.675,
                    y: height * 0.445
                )


                // ==========================================
                // CHAPTER 2
                // ==========================================

                chapterButton(
                    chapterIndex: 1,
                    width: width,
                    height: height
                )
                .position(
                    x: width * 0.675,
                    y: height * 0.585
                )


                // ==========================================
                // CHAPTER 3
                // ==========================================

                chapterButton(
                    chapterIndex: 2,
                    width: width,
                    height: height
                )
                .position(
                    x: width * 0.675,
                    y: height * 0.725
                )


                // ==========================================
                // BACK
                // ==========================================

                Button {
                    dismiss()
                } label: {

                    Image("BackRibbon")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.065
                        )
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.075,
                    y: height * 0.055
                )


                // ==========================================
                // NEXT STORY
                // ==========================================

                Button {

                    // nanti next story di sini

                } label: {

                    Image("NextArrow")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.075
                        )
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.905,
                    y: height * 0.54
                )
            }
            .frame(
                width: width,
                height: height
            )
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }


    // =====================================================
    // MARK: - CHAPTER BUTTON
    // =====================================================

    @ViewBuilder
    private func chapterButton(
        chapterIndex: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {

        if chapterIndex < chapters.count {

            let status = chapterStatus(
                chapterIndex: chapterIndex
            )

            switch status {


            // ==============================================
            // COMPLETED
            // WHITE + STAR
            // ==============================================

            case .completed:

                ZStack {

                    Image("ChapterButtonWhite")
                        .resizable()
                        .scaledToFit()


                    HStack(spacing: width * 0.012) {

                        Image("StarIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: width * 0.025,
                                height: width * 0.025
                            )


                        chapterTextAsset(
                            chapterIndex: chapterIndex
                        )
                        .frame(
                            width: width * 0.145,
                            height: height * 0.055
                        )


                        Spacer()
                    }
                    .padding(
                        .leading,
                        width * 0.025
                    )
                }
                .frame(
                    width: width * 0.31,
                    height: height * 0.105
                )


            // ==============================================
            // CURRENT
            // YELLOW + ARROW
            // ==============================================

            case .current:

                NavigationLink {

                    ChapterIntroView(
                        chapter: chapters[chapterIndex]
                    )

                } label: {

                    ZStack {

                        Image("ChapterButtonYellow")
                            .resizable()
                            .scaledToFit()


                        HStack {

                            Spacer()


                            chapterTextAsset(
                                chapterIndex: chapterIndex
                            )
                            .frame(
                                width: width * 0.16,
                                height: height * 0.058
                            )


                            Spacer()


                            Image(systemName: "chevron.right")
                                .font(
                                    .system(
                                        size: max(
                                            16,
                                            width * 0.021
                                        ),
                                        weight: .black
                                    )
                                )
                                .foregroundStyle(.black)


                            Spacer()
                                .frame(
                                    width: width * 0.020
                                )
                        }
                    }
                    .frame(
                        width: width * 0.31,
                        height: height * 0.105
                    )
                }
                .buttonStyle(.plain)


            // ==============================================
            // LOCKED
            // WHITE + FADED
            // ==============================================

            case .locked:

                ZStack {

                    Image("ChapterButtonWhite")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.55)


                    chapterTextAsset(
                        chapterIndex: chapterIndex
                    )
                    .frame(
                        width: width * 0.15,
                        height: height * 0.055
                    )
                    .opacity(0.35)
                }
                .frame(
                    width: width * 0.31,
                    height: height * 0.105
                )
                .allowsHitTesting(false)
        }
    }
}


    // =====================================================
    // MARK: - CHAPTER TEXT ASSETS
    // =====================================================

    @ViewBuilder
    private func chapterTextAsset(
        chapterIndex: Int
    ) -> some View {

        switch chapterIndex {

        case 0:

            Image("CRY BABY...")
                .resizable()
                .scaledToFit()


        case 1:

            Image("BE QUIET!")
                .resizable()
                .scaledToFit()


        case 2:

            Image("GO STUDY")
                .resizable()
                .scaledToFit()


        default:

            EmptyView()
        }
    }


    // =====================================================
    // MARK: - CHAPTER LOGIC
    // =====================================================

    private func chapterStatus(
        chapterIndex: Int
    ) -> ChapterPickStatus {

        if chapterIndex < completedChapterCount {
            return .completed
        }

        if chapterIndex == completedChapterCount {
            return .current
        }

        return .locked
    }
}


// =========================================================
// MARK: - STATUS
// =========================================================

private enum ChapterPickStatus {

    case completed
    case current
    case locked
}


// =========================================================
// MARK: - PREVIEW
// =========================================================

#Preview {

    NavigationStack {

        ChapterSelectionView(
            story: StoryCatalog.gameStories[0]
        )
    }
}
