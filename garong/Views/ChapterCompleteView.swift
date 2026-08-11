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
                    .font(.largeTitle.bold())
                
                // Fallback text since result properties aren't fully defined in prompt
                // Assuming it has some summary or we can just show generic completion
                Text("Great job placing all objects!")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                Button(action: onRestart) {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .frame(width: 160, height: 50)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                }
                
                Button(action: onDismiss) {
                    Text("Back to Chapters")
                        .font(.headline)
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
