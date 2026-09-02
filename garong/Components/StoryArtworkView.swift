import SwiftUI

struct StoryArtworkView: View {
    let assetName: String
    var size: CGFloat = 120

    var body: some View {
        Image(AssetFallbackHelper.storyArtworkImageName(for: assetName))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel(assetName)
    }
}

struct GarongDecorativeBackground: View {
    var body: some View {
        ZStack {
            GarongTheme.pageBackground
            Circle()
                .fill(GarongTheme.sun.opacity(0.18))
                .frame(width: 430, height: 430)
                .offset(x: 420, y: -260)
            Circle()
                .fill(GarongTheme.teal.opacity(0.10))
                .frame(width: 520, height: 520)
                .offset(x: -460, y: 300)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
