import SwiftUI

struct ChapterSelectionView: View {
    let title: String
    let subtitle: String
    let chapters: [Chapter]

    init(story: GameStory) {
        title = story.title
        subtitle = story.subtitle
        chapters = story.chapters
    }

    init(title: String, subtitle: String, chapters: [Chapter]) {
        self.title = title
        self.subtitle = subtitle
        self.chapters = chapters
    }

    var body: some View {
        ZStack {
            paperBackground

            VStack(alignment: .leading, spacing: 14) {
                Text("STORIES PICK")
                    .font(.caption.weight(.heavy))
                    .tracking(2.2)
                    .foregroundStyle(GarongTheme.ink.opacity(0.46))

                HStack(spacing: 48) {
                    storyHero.frame(maxWidth: .infinity)
                    chapterList.frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 44)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(GarongTheme.cream.opacity(0.88))
                        .shadow(color: GarongTheme.ink.opacity(0.08), radius: 24, y: 12)
                )
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 20)
        }
    }

    private var storyHero: some View {
        VStack(spacing: 8) {
            Text(environmentTitle)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(GarongTheme.ink)

            Image("SchoolSketch")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 470, maxHeight: 330)
                .accessibilityLabel("Hand-drawn school")

            Text(storyDescription)
                .font(.subheadline)
                .foregroundStyle(GarongTheme.ink.opacity(0.62))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: 440)
        }
    }

    private var chapterList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your moment")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(GarongTheme.ink)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(GarongTheme.teal)

            VStack(spacing: 10) {
                ForEach(Array(chapters.enumerated()), id: \.element.id) { index, chapter in
                    chapterDestination(for: chapter, isFeatured: index == 0)
                }
            }
            .padding(.top, 6)
        }
    }

    @ViewBuilder
    private func chapterDestination(for chapter: Chapter, isFeatured: Bool) -> some View {
        if chapter.isUnlocked {
            NavigationLink {
                ChapterIntroView(chapter: chapter)
            } label: {
                ChapterRow(chapter: chapter, isFeatured: isFeatured)
            }
            .buttonStyle(.plain)
        } else {
            ChapterRow(chapter: chapter, isFeatured: false)
                .opacity(0.48)
                .accessibilityLabel("Chapter \(chapter.number), \(chapter.name), locked")
        }
    }

    private var environmentTitle: String {
        if title.localizedCaseInsensitiveContains("classroom") { return "SCHOOL" }
        if title.localizedCaseInsensitiveContains("playground") { return "PLAYGROUND" }
        return title.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? title
    }

    private var storyDescription: String {
        if title.localizedCaseInsensitiveContains("classroom") {
            return "Follow Rhodey and Jojo through small moments at school."
        }
        return "Choose a chapter and see how each response changes the story."
    }

    private var paperBackground: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.94)
            GarongTheme.pageBackground.opacity(0.48)
            Circle()
                .fill(GarongTheme.sun.opacity(0.10))
                .frame(width: 420, height: 420)
                .offset(x: 470, y: -260)
        }
        .ignoresSafeArea()
    }
}

private struct ChapterRow: View {
    let chapter: Chapter
    let isFeatured: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: chapter.isUnlocked ? "star.fill" : "star")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(isFeatured ? GarongTheme.sun : GarongTheme.ink.opacity(0.68))

            VStack(alignment: .leading, spacing: 3) {
                Text("CHAPTER \(chapter.number)")
                    .font(.system(.headline, design: .rounded, weight: .heavy))
                    .tracking(1.2)
                    .foregroundStyle(GarongTheme.ink)

                Text(chapter.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(GarongTheme.ink.opacity(0.60))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: chapter.isUnlocked ? "play.fill" : "lock.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(chapter.isUnlocked ? GarongTheme.ink : GarongTheme.ink.opacity(0.36))
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 76)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isFeatured ? .white.opacity(0.92) : .white.opacity(0.52))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isFeatured ? GarongTheme.sun.opacity(0.48) : GarongTheme.ink.opacity(0.08), lineWidth: 1.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct ChapterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChapterSelectionView(story: StoryCatalog.gameStories[0])
        }
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
