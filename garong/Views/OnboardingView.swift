import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    private let pages = [
        ("Meet Rhodey & Jojo", "Every story begins with a small moment. Notice what each child may need.", "Rhodey", "Jojo"),
        ("Choose an approach", "Drag a response into the scene and watch how the moment changes.", "Approach", "AskQuiet"),
        ("Explore, don’t score", "There are no wrong answers here. Try, reflect, and discover a kinder next step.", "GiveBandage", "Apologize")
    ]

    var body: some View {
        ZStack {
            GarongDecorativeBackground()
            HStack(spacing: 56) {
                ZStack {
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(.white.opacity(0.78))
                    HStack(spacing: 12) {
                        StoryArtworkView(assetName: pages[page].2, size: 190)
                        StoryArtworkView(assetName: pages[page].3, size: 150)
                    }
                    .padding(30)
                }
                .frame(maxWidth: 500, maxHeight: 430)

                VStack(alignment: .leading, spacing: 22) {
                    Text("GARONG • HOW TO PLAY")
                        .font(.caption.weight(.heavy)).tracking(1.8)
                        .foregroundStyle(GarongTheme.coral)
                    Text(pages[page].0)
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(GarongTheme.ink)
                    Text(pages[page].1)
                        .font(.title3).foregroundStyle(GarongTheme.ink.opacity(0.72))
                        .frame(maxWidth: 470, alignment: .leading)
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule().fill(index == page ? GarongTheme.teal : GarongTheme.teal.opacity(0.2))
                                .frame(width: index == page ? 30 : 9, height: 9)
                        }
                    }
                    Button {
                        if page == pages.count - 1 { onFinish() }
                        else { withAnimation(.spring(response: 0.35)) { page += 1 } }
                    } label: {
                        Label(page == pages.count - 1 ? "Start the Story" : "Continue", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GarongPrimaryButtonStyle())
                }
                .frame(maxWidth: 500, alignment: .leading)
            }
            .padding(52)
        }
    }
}
