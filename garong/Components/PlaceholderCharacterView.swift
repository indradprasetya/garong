import SwiftUI

struct PlaceholderCharacterView: View {
    let emotion: CharacterEmotion
    let isReacting: Bool
    
    @State private var bounce = false
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Radial glow background
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [emotion.themeColor.opacity(0.3), Color.clear]), center: .center, startRadius: 10, endRadius: 80))
                .frame(width: 140, height: 140)
            
            // Face base
            Circle()
                .fill(Color(UIColor.systemBackground))
                .frame(width: 100, height: 100)
                .shadow(color: emotion.themeColor.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // Face features based on emotion
            faceFeatures
                .foregroundColor(emotion.themeColor)
            
            // Emotion badge overlay
            Text(emotion.emoji)
                .font(.system(size: 24))
                .padding(8)
                .background(Circle().fill(Color(UIColor.secondarySystemBackground)))
                .shadow(radius: 3)
                .offset(x: 35, y: 35)
        }
        .scaleEffect(isReacting || bounce ? 1.1 : 1.0)
        .rotationEffect(.degrees(rotation))
        .onChange(of: emotion.displayName) { _ in
            triggerAnimation()
        }
        .onAppear {
            if isReacting {
                triggerAnimation()
            }
        }
    }
    
    private func triggerAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            bounce = true
            rotation = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                rotation = -10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                bounce = false
                rotation = 0
            }
        }
    }
    
    @ViewBuilder
    private var faceFeatures: some View {
        VStack(spacing: 12) {
            switch emotion {
            case .neutral:
                HStack(spacing: 25) {
                    Circle().frame(width: 12, height: 12)
                    Circle().frame(width: 12, height: 12)
                }
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 30, height: 4)
            case .happy:
                HStack(spacing: 25) {
                    Image(systemName: "chevron.up").font(.system(size: 16, weight: .heavy))
                    Image(systemName: "chevron.up").font(.system(size: 16, weight: .heavy))
                }
                Image(systemName: "mouth").font(.system(size: 24, weight: .bold)) // Upward curve
            case .sad:
                HStack(spacing: 25) {
                    HStack(spacing: 0) {
                        Circle().frame(width: 12, height: 12)
                        Image(systemName: "drop.fill").font(.system(size: 10)).foregroundColor(.blue).offset(y: 8)
                    }
                    Circle().frame(width: 12, height: 12)
                }
                Image(systemName: "mouth").font(.system(size: 24, weight: .bold)).rotationEffect(.degrees(180)) // Downward frown
            case .confused:
                HStack(spacing: 25) {
                    Circle().frame(width: 16, height: 16)
                    Circle().frame(width: 8, height: 8)
                }
                Image(systemName: "waveform").font(.system(size: 20, weight: .bold)) // Wavy mouth
            case .angry:
                HStack(spacing: 20) {
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2).frame(width: 16, height: 4).rotationEffect(.degrees(15))
                        Circle().frame(width: 12, height: 12)
                    }
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2).frame(width: 16, height: 4).rotationEffect(.degrees(-15))
                        Circle().frame(width: 12, height: 12)
                    }
                }
                RoundedRectangle(cornerRadius: 2).frame(width: 25, height: 4) // Tight straight mouth
            case .excited:
                HStack(spacing: 25) {
                    Text("*").font(.system(size: 30, weight: .black))
                    Text("*").font(.system(size: 30, weight: .black))
                }
                Circle().trim(from: 0.5, to: 1.0).frame(width: 30, height: 30).rotationEffect(.degrees(180)) // Wide open smile
            case .calm:
                HStack(spacing: 25) {
                    RoundedRectangle(cornerRadius: 2).frame(width: 16, height: 4)
                    RoundedRectangle(cornerRadius: 2).frame(width: 16, height: 4)
                }
                Image(systemName: "mouth").font(.system(size: 18, weight: .regular)) // Gentle smile
            case .curious:
                HStack(spacing: 20) {
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2).frame(width: 16, height: 4).rotationEffect(.degrees(-10)).offset(y: -4)
                        Circle().frame(width: 16, height: 16)
                    }
                    VStack(spacing: 2) {
                        Color.clear.frame(width: 16, height: 4)
                        Circle().frame(width: 12, height: 12)
                    }
                }
                Circle().stroke(lineWidth: 4).frame(width: 12, height: 12) // 'O' mouth
            }
        }
    }
}

struct PlaceholderCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        // Need to provide a mock CharacterEmotion if it doesn't exist, but assuming it exists
        // We will just compile it. Assuming CharacterEmotion has .neutral etc.
        // As a mock for preview if needed, but we don't have the definition here.
        Text("Preview requires CharacterEmotion definition")
    }
}
