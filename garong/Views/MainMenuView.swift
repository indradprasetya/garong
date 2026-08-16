import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                GarongDecorativeBackground()

                HStack(spacing: 34) {
                    hero
                    actionPanel
                }
                .padding(.horizontal, 54)
                .padding(.vertical, 34)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(GarongTheme.teal)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("A SMALL STEP CAN\nCHANGE THE MOMENT")
                .font(.caption.weight(.heavy))
                .tracking(1.8)
                .foregroundStyle(GarongTheme.coral)

            Text("GARONG")
                .font(.system(size: 68, weight: .black, design: .rounded))
                .foregroundStyle(GarongTheme.ink)
                .minimumScaleFactor(0.7)

            Text("Observe. Try an approach.\nWatch what changes.")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundStyle(GarongTheme.teal)

            Text("A story-driven interaction game about responding to children with curiosity, care, and flexible support.")
                .font(.body)
                .foregroundStyle(GarongTheme.ink.opacity(0.7))
                .frame(maxWidth: 480, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionPanel: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(GarongTheme.sun.opacity(0.36))
                    .frame(width: 150, height: 150)

                StoryArtworkView(assetName: "Rhodey", size: 112)

                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundStyle(GarongTheme.coral)
                    .offset(x: 58, y: -55)
            }
            .accessibilityHidden(true)

            NavigationLink {
                StorySelectionView(stories: StoryCatalog.gameStories)
            } label: {
                Label("Start a Story", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GarongPrimaryButtonStyle())

            NavigationLink {
                ChapterSelectionView(
                    title: "All Chapters",
                    subtitle: "Development access to every GARONG chapter.",
                    chapters: StoryCatalog.allChapters
                )
            } label: {
                Label("Browse Chapters", systemImage: "square.grid.2x2.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GarongSecondaryButtonStyle())

            Text("No scores. No wrong answers. Your choices shape the response.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(GarongTheme.ink.opacity(0.58))
        }
        .padding(26)
        .frame(maxWidth: 390)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.white.opacity(0.86))
                .shadow(color: GarongTheme.ink.opacity(0.12), radius: 20, y: 10)
        )
    }

}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
