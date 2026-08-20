import SwiftUI

struct ChapterSelectionView: View {

    let storyNumber: Int
    let title: String
    let subtitle: String
    let chapters: [Chapter]

    @Environment(\.dismiss)
    private var dismiss

    /*
     TEST STATE:
     0 = Cry Baby current
     1 = Cry Baby completed, Be Quiet current
     2 = Cry Baby + Be Quiet completed, Go Study current
     3 = all completed
    */
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
                // SCHOOL ARTWORK
                // =====================================================

                Image("SchoolArtwork")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.98,
                        height: height * 1.08
                    )
                    .position(
                        x: width * 0.50,
                        y: height * 0.49
                    )


                // =====================================================
                // SCHOOL TITLE
                // =====================================================

                Image("School")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width * 0.255
                    )
                    .position(
                        x: width * 0.675,
                        y: height * 0.285
                    )


                // =====================================================
                // CHAPTER 1
                // =====================================================

                chapterButton(
                    index: 0,
                    width: width,
                    height: height
                )
                .position(
                    x: width * 0.675,
                    y: height * 0.445
                )


                // =====================================================
                // CHAPTER 2
                // =====================================================

                chapterButton(
                    index: 1,
                    width: width,
                    height: height
                )
                .position(
                    x: width * 0.675,
                    y: height * 0.585
                )


                // =====================================================
                // CHAPTER 3
                // =====================================================

                chapterButton(
                    index: 2,
                    width: width,
                    height: height
                )
                .position(
                    x: width * 0.675,
                    y: height * 0.725
                )


                // =====================================================
                // BACK BUTTON
                // =====================================================

                Button {
                    dismiss()
                } label: {

                    Image("BackRibbon")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.060
                        )
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.075,
                    y: height * 0.070
                )


                // =====================================================
                // NEXT STORY ARROW
                // =====================================================

                Button {
                    // next story nanti
                } label: {

                    Image("NextArrow")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.070
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


    // =========================================================
    // MARK: - CHAPTER BUTTON
    // =========================================================

    @ViewBuilder
    private func chapterButton(
        index: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {

        if index < chapters.count {

            let status = chapterStatus(index: index)

            switch status {

            // =================================================
            // COMPLETED
            // WHITE BORDER + STAR + TEXT
            // =================================================

            case .completed:

                ZStack {

                    Image("ChapterButtonWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.27
                        )
                        .offset(
                            x: -10,
                            y: 0
                        )

                    HStack(spacing: width * 0.012) {

                        Image("StarIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: width * 0.021,
                                height: width * 0.021
                            )
                            .offset(
                                x: 15,
                                y: 0
                            )

                        chapterTextAsset(index: index)
                            .frame(
                                width: width * 0.115,
                                height: height * 0.040
                            )
                            .offset(
                                x: 8,
                                y: 0
                            )

                        Spacer()
                    }
                    .frame(
                        width: width * 0.215
                    )
                }
                .frame(
                    width: width * 0.33,
                    height: height * 0.20
                )


            // =================================================
            // CURRENT / CONTINUE
            // PAKAI ASSET DoChapter
            // =================================================

            case .current:

                NavigationLink {

                    ChapterIntroView(
                        chapter: chapters[index]
                    )

                } label: {

                    ZStack {

                        // asset current/continue yang sudah jadi
                        Image("DoChapter")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: width * 0.27
                            )

                        chapterTextAsset(index: index)
                            .frame(
                                width: width * 0.120,
                                height: height * 0.040
                            )

                        Image(systemName: "chevron.right")
                            .font(
                                .system(
                                    size: max(
                                        14,
                                        width * 0.017
                                    ),
                                    weight: .black
                                )
                            )
                            .foregroundStyle(.black)
                            .offset(
                                x: width * 0.090,
                                y: 0
                            )
                    }
                    .frame(
                        width: width * 0.30,
                        height: height * 0.18
                    )
                }
                .buttonStyle(.plain)


            // =================================================
            // LOCKED
            // WHITE BORDER FADED
            // =================================================

            case .locked:

                ZStack {

                    Image("ChapterButtonWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.27
                        )
                        .offset(
                            x: -10,
                            y: 0
                        )
                        .opacity(0.45)

                    chapterTextAsset(index: index)
                        .frame(
                            width: width * 0.115,
                            height: height * 0.040
                        )
                        .opacity(0.32)
                }
                .frame(
                    width: width * 0.33,
                    height: height * 0.20
                )
                .allowsHitTesting(false)
            }
        }
    }


    // =========================================================
    // MARK: - CHAPTER TEXT ASSETS
    // =========================================================

    @ViewBuilder
    private func chapterTextAsset(
        index: Int
    ) -> some View {

        switch index {

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


    // =========================================================
    // MARK: - STATUS LOGIC
    // =========================================================

    private func chapterStatus(
        index: Int
    ) -> ChapterPickStatus {

        if index < completedChapterCount {
            return .completed
        }

        if index == completedChapterCount {
            return .current
        }

        return .locked
    }
}


// =============================================================
// MARK: - STATUS ENUM
// =============================================================

private enum ChapterPickStatus {
    case completed
    case current
    case locked
}


// =============================================================
// MARK: - PREVIEW
// =============================================================

struct ChapterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChapterSelectionView(
                story: StoryCatalog.gameStories[0]
            )
        }
    }
}
