import SwiftUI

struct ChapterCompleteView: View {
    let result: ChapterResult
    let onDismiss: () -> Void
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text("Chapter Complete!")
                    .font(.appFont(size: 32, relativeTo: .largeTitle))

                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { star in
                        Image(systemName: star <= result.stars ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundColor(star <= result.stars ? .yellow : .secondary)
                    }
                }

                Text("\(result.placementCount) actions tried")
                    .font(.appFont(size: 18, relativeTo: .title3))
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
                        .font(.appFont(size: 16, relativeTo: .headline))
                        .foregroundColor(.accentColor)
                        .frame(width: 160, height: 50)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor, lineWidth: 2)
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
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
            }
            .padding(.top, 10)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.systemBackground))
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
