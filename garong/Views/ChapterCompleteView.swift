import SwiftUI

struct ChapterCompleteView: View {
    let result: ChapterResult
    let onDismiss: () -> Void
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                StoryArtworkView(assetName: "GiveBandage", size: 84)
                StoryArtworkView(assetName: "Apologize", size: 84)
            }
            
            VStack(spacing: 8) {
                Text("Chapter Complete!")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(GarongTheme.ink)
                
                // Fallback text since result properties aren't fully defined in prompt
                // Assuming it has some summary or we can just show generic completion
                Text("Great job placing all objects!")
                    .font(.title3)
                    .foregroundColor(.secondary)

                if let summary = result.completionSummary {
                    Text(summary)
                        .font(.appFont(size: 16, relativeTo: .body))
                        .multilineTextAlignment(.center)
                }

                if let tip = result.completionTip {
                    Text("Tip: \(tip)")
                        .font(.appFont(size: 14, relativeTo: .callout))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            HStack(spacing: 20) {
                Button {
                    SoundManager.shared.play(.buttonTap)
                    onRestart()
                } label: {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(GarongTheme.teal)
                        .frame(width: 160, height: 50)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(GarongTheme.teal, lineWidth: 2)
                        )
                }
                
                Button {
                    SoundManager.shared.play(.backTap)
                    onDismiss()
                } label: {
                    Text("Back to Chapters")
                        .font(.appFont(size: 16, relativeTo: .headline))
                        .foregroundColor(.white)
                        .frame(width: 160, height: 50)
                        .background(GarongTheme.teal)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
            }
            .padding(.top, 10)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(GarongTheme.cream)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .frame(maxWidth: 500)
    }
}

struct ChapterCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        Text("ChapterCompleteView Preview")
    }
}
