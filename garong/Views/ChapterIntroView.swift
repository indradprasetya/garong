import SwiftUI

struct ChapterIntroView: View {
    let chapter: Chapter

    var body: some View {
        ZStack {
            GarongTheme.pageBackground.ignoresSafeArea()

            HStack(spacing: 36) {
                scenePreview

                VStack(alignment: .leading, spacing: 18) {
                    Text("LEVEL \(chapter.number)")
                        .font(.caption.weight(.heavy))
                        .tracking(1.5)
                        .foregroundStyle(GarongTheme.coral)

                    Text(chapter.name)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(GarongTheme.ink)

                    Text(chapter.description)
                        .font(.title3)
                        .foregroundStyle(GarongTheme.ink.opacity(0.72))
                        .frame(maxWidth: 480, alignment: .leading)

                    HStack(spacing: 12) {
                        stat("\(chapter.scenes.count)", "Frames", "rectangle.stack.fill")
                        stat("\(chapter.objects.count)", "Objects", "shippingbox.fill")
                    }

                    NavigationLink {
                        GameplayView(chapter: chapter)
                    } label: {
                        Label("Enter the Scene", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GarongPrimaryButtonStyle())
                    .padding(.top, 6)
                }
                .frame(maxWidth: 500, alignment: .leading)
            }
            .padding(40)
        }
        .navigationTitle(chapter.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var scenePreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(GarongTheme.mint)

            Circle()
                .fill(GarongTheme.sun.opacity(0.5))
                .frame(width: 160, height: 160)
                .offset(x: -80, y: -60)

            Image(systemName: "cat.fill")
                .font(.system(size: 120, weight: .semibold))
                .foregroundStyle(GarongTheme.ink)
                .offset(y: 28)

            Text("Background artwork\nfor this chapter")
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(GarongTheme.ink.opacity(0.54))
                .offset(y: -110)
        }
        .frame(maxWidth: 430, maxHeight: 400)
        .accessibilityLabel("Chapter illustration placeholder")
    }

    private func stat(_ value: String, _ label: String, _ symbol: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: symbol)
                .foregroundStyle(GarongTheme.teal)
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(.headline)
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct ChapterIntroView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChapterIntroView(chapter: SampleGameData.firstInvitation)
        }
    }
}
