import SwiftUI

struct ChapterCompleteView: View {

    let result: ChapterResult
    @ObservedObject private var localization = AppLocalization.shared

    let onDismiss: () -> Void
    let onRestart: () -> Void

    var body: some View {

        VStack(spacing: 24) {

            HStack(spacing: 12) {

                StoryArtworkView(
                    assetName: "GiveBandage",
                    size: 84
                )

                StoryArtworkView(
                    assetName: "Apologize",
                    size: 84
                )
            }

            VStack(spacing: 8) {

                Text(localization.text("chapter.complete"))
                    .font(
                        .system(
                            .largeTitle,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        GarongTheme.ink
                    )

                Text(
                    localization.text("chapter.completeMessage")
                )
                .font(.title3)
                .foregroundColor(.secondary)
            }

            HStack(spacing: 20) {

                Button {
                    SoundManager.shared.play(.buttonTap)
                    onRestart()
                } label: {

                    Text(localization.text("chapter.playAgain"))
                        .font(.headline)
                        .foregroundColor(
                            GarongTheme.teal
                        )
                        .frame(
                            width: 160,
                            height: 50
                        )
                        .background(
                            Color(
                                UIColor.secondarySystemBackground
                            )
                        )
                        .cornerRadius(12)
                        .overlay {

                            RoundedRectangle(
                                cornerRadius: 12
                            )
                            .stroke(
                                GarongTheme.teal,
                                lineWidth: 2
                            )
                        }
                }
                Button(
                    action: onDismiss
                ) {
                    Text(localization.text("chapter.back"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(
                            width: 160,
                            height: 50
                        )
                        .background(
                            GarongTheme.teal
                        )
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
            }
            .padding(.top, 10)
        }
        .padding(40)
        .background {

            RoundedRectangle(
                cornerRadius: 24
            )
            .fill(
                GarongTheme.cream
            )
            .shadow(
                color: Color.black.opacity(0.2),
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .frame(maxWidth: 500)
    }
}


struct ChapterCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        Text("ChapterCompleteView Preview")
    }
}
