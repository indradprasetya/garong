import SwiftUI

struct ChapterSelectionView: View {

    // =========================================================
    // MARK: - DATA
    // =========================================================

    private let stories: [GameStory]

    @State private var selectedStoryIndex: Int

    @Environment(\.dismiss)
    private var dismiss


    // =========================================================
    // MARK: - PROGRESS
    //
    // Sementara untuk testing.
    //
    // 0 = chapter 1 current
    // 1 = chapter 1 complete, chapter 2 current
    // 2 = chapter 1 + 2 complete, chapter 3 current
    // 3 = semua complete
    //
    // Progress School dan Playground dipisah.
    // =========================================================

    @State private var completedChaptersByStory: [Int: Int] = [
        0: 1,
        1: 1
    ]


    // =========================================================
    // MARK: - INIT
    // =========================================================

    init(story: GameStory) {

        let allStories =
            StoryCatalog.gameStories

        self.stories =
            allStories

        let startingIndex =
            allStories.firstIndex {
                $0.id == story.id
            } ?? 0

        _selectedStoryIndex =
            State(
                initialValue: startingIndex
            )
    }


    // =========================================================
    // MARK: - CURRENT STORY
    // =========================================================

    private var currentStory: GameStory {

        stories[
            selectedStoryIndex
        ]
    }


    private var currentChapters: [Chapter] {

        currentStory.chapters
    }


    private var completedChapterCount: Int {

        completedChaptersByStory[
            selectedStoryIndex
        ] ?? 0
    }


    // =========================================================
    // MARK: - BODY
    // =========================================================

    var body: some View {

        GeometryReader { geometry in

            let width =
                geometry.size.width

            let height =
                geometry.size.height


            ZStack {

                // =====================================================
                // BACKGROUND
                // =====================================================

                Image(
                    "StoriesGreenGrid"
                )
                .resizable()
                .scaledToFill()
                .frame(
                    width: width,
                    height: height
                )
                .clipped()
                .ignoresSafeArea()


                // =====================================================
                // STORY CONTENT
                // =====================================================

                ZStack {

                    // ===============================================
                    // SCHOOL
                    // ===============================================

                    if selectedStoryIndex == 0 {

                        Image(
                            "SchoolArtwork"
                        )
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


                        Image(
                            "School"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width:
                                width * 0.255
                        )
                        .position(
                            x: width * 0.675,
                            y: height * 0.285
                        )
                    }


                    // ===============================================
                    // PLAYGROUND
                    // title sudah menyatu di artwork
                    // ===============================================

                    if selectedStoryIndex == 1 {

                        Image(
                            "PlaygroundArtwork"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width:
                                width * 0.72
                        )
                        .position(
                            x: width * 0.50,
                            y: height * 0.51
                        )
                    }


                    // ===============================================
                    // CHAPTER 1
                    // ===============================================

                    chapterButton(
                        index: 0,
                        width: width,
                        height: height
                    )
                    .position(
                        x: width * 0.66,
                        y: height * 0.445
                    )


                    // ===============================================
                    // CHAPTER 2
                    // ===============================================

                    chapterButton(
                        index: 1,
                        width: width,
                        height: height
                    )
                    .position(
                        x: width * 0.66,
                        y: height * 0.585
                    )


                    // ===============================================
                    // CHAPTER 3
                    // ===============================================

                    chapterButton(
                        index: 2,
                        width: width,
                        height: height
                    )
                    .position(
                        x: width * 0.66,
                        y: height * 0.725
                    )
                }
                .id(
                    selectedStoryIndex
                )
                .transition(
                    .asymmetric(
                        insertion:
                            .move(
                                edge: .trailing
                            )
                            .combined(
                                with: .opacity
                            ),

                        removal:
                            .move(
                                edge: .leading
                            )
                            .combined(
                                with: .opacity
                            )
                    )
                )


                // =====================================================
                // BACK BUTTON
                // =====================================================

                Button {

                    dismiss()

                } label: {

                    Image(
                        "BackRibbon"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:
                            width * 0.060
                    )
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.075,
                    y: height * 0.070
                )


                // =====================================================
                // PREVIOUS STORY - LEFT ARROW
                // =====================================================

                Button {

                    showPreviousStory()

                } label: {

                    Image(
                        "NextArrow"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:
                            width * 0.070
                    )
                    .scaleEffect(
                        x: -1,
                        y: 1
                    )
                }
                .buttonStyle(.plain)
                .position(
                    x: width * 0.095,
                    y: height * 0.54
                )


                // =====================================================
                // NEXT STORY - RIGHT ARROW
                // =====================================================

                Button {

                    showNextStory()

                } label: {

                    Image(
                        "NextArrow"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:
                            width * 0.070
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
        .navigationBarBackButtonHidden(
            true
        )
        .toolbar(
            .hidden,
            for: .navigationBar
        )
    }


    // =========================================================
    // MARK: - NEXT STORY
    // =========================================================

    private func showNextStory() {

        guard !stories.isEmpty else {
            return
        }

        withAnimation(
            .easeInOut(
                duration: 0.38
            )
        ) {

            selectedStoryIndex =
                (
                    selectedStoryIndex + 1
                )
                % stories.count
        }
    }


    // =========================================================
    // MARK: - PREVIOUS STORY
    // =========================================================

    private func showPreviousStory() {

        guard !stories.isEmpty else {
            return
        }

        withAnimation(
            .easeInOut(
                duration: 0.38
            )
        ) {

            selectedStoryIndex =
                (
                    selectedStoryIndex - 1 + stories.count
                )
                % stories.count
        }
    }


    // =========================================================
    // MARK: - CHAPTER BUTTON
    //
    // SATU FUNCTION INI DIPAKAI:
    // SCHOOL
    // PLAYGROUND
    // STORY BERIKUTNYA
    //
    // Jadi ukuran/style cukup diubah di sini.
    // =========================================================

    @ViewBuilder
    private func chapterButton(
        index: Int,
        width: CGFloat,
        height: CGFloat
    ) -> some View {

        if index <
            currentChapters.count {

            let status =
                chapterStatus(
                    index: index
                )


            // =====================================================
            // REUSABLE CONFIG
            // =====================================================

            let buttonWidth =
                width * 0.26

            let buttonContainerWidth =
                width * 0.48

            let buttonContainerHeight =
                height * 0.22

            let textWidth =
                width * 0.11

            let textHeight =
                height * 0.043

            let starSize =
                width * 0.017


            switch status {

            // =================================================
            // COMPLETED
            //
            // WHITE + STAR
            // =================================================

            case .completed:

                ZStack {

                    Image(
                        "ChapterButtonWhite"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:
                            buttonWidth
                    )


                    HStack(
                        spacing:
                            width * 0.010
                    ) {

                        Image(
                            "StarIcon"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width:
                                starSize,
                            height:
                                starSize
                        )
                        .offset(
                            x: 112,
                            y: -6
                        )


                        chapterTextAsset(
                            index: index
                        )
                        .frame(
                            width:
                                textWidth,
                            height:
                                textHeight
                        )
                        .offset(
                            x: -25,
                            y: 0
                        )
                    }
                }
                .frame(
                    width:
                        buttonContainerWidth,
                    height:
                        buttonContainerHeight
                )


                // =================================================
                // CURRENT / NEXT CHAPTER
                //
                // YELLOW + ARROW
                // Klik langsung masuk GAMEPLAY
                // =================================================

                case .current:

                    NavigationLink {

                        GameplayView(
                            chapter: currentChapters[index]
                        )

                    } label: {

                        ZStack {

                            Image(
                                "DoChapter"
                            )
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: buttonWidth
                            )

                            chapterTextAsset(
                                index: index
                            )
                            .frame(
                                width: textWidth,
                                height: textHeight
                            )

                            Image(
                                systemName: "chevron.right"
                            )
                            .font(
                                .system(
                                    size: max(
                                        14,
                                        width * 0.017
                                    ),
                                    weight: .black
                                )
                            )
                            .foregroundStyle(
                                .black
                            )
                            .offset(
                                x: width * 0.070,
                                y: -6
                            )
                        }
                        .frame(
                            width: buttonContainerWidth,
                            height: buttonContainerHeight
                        )
                    }
                    .buttonStyle(.plain)


            // =================================================
            // LOCKED
            //
            // WHITE TRANSPARENT
            // =================================================

            case .locked:

                ZStack {

                    Image(
                        "ChapterButtonWhite"
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width:
                            buttonWidth
                    )
                    .opacity(
                        0.40
                    )


                    chapterTextAsset(
                        index: index
                    )
                    .frame(
                        width:
                            textWidth,
                        height:
                            textHeight
                    )
                    .opacity(
                        0.28
                    )
                }
                .frame(
                    width:
                        buttonContainerWidth,
                    height:
                        buttonContainerHeight
                )
                .allowsHitTesting(
                    false
                )
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

            Image(
                "CRY BABY..."
            )
            .resizable()
            .scaledToFit()


        case 1:

            Image(
                "BE QUIET!"
            )
            .resizable()
            .scaledToFit()


        case 2:

            Image(
                "GO STUDY"
            )
            .resizable()
            .scaledToFit()


        default:

            EmptyView()
        }
    }


    // =========================================================
    // MARK: - STATUS LOGIC
    //
    // completed < current < locked
    // =========================================================

    private func chapterStatus(
        index: Int
    ) -> ChapterPickStatus {

        if index <
            completedChapterCount {

            return .completed
        }

        if index ==
            completedChapterCount {

            return .current
        }

        return .locked
    }


    // =========================================================
    // MARK: - COMPLETE CHAPTER
    // =========================================================

    private func completeChapter(
        _ chapterIndex: Int
    ) {

        let newCompletedCount =
            chapterIndex + 1

        completedChaptersByStory[
            selectedStoryIndex
        ] =
            max(
                completedChaptersByStory[
                    selectedStoryIndex
                ] ?? 0,

                newCompletedCount
            )
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

#Preview {

    NavigationStack {

        ChapterSelectionView(
            story:
                StoryCatalog.gameStories[0]
        )
    }
}
