#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct CharacterView: View {
    let imageName: String?
    let emotion: CharacterEmotion
    let isReacting: Bool
    let isWiggling: Bool
    
    init(
        imageName: String? = nil,
        emotion: CharacterEmotion = .neutral,
        isReacting: Bool = false,
        isWiggling: Bool = false
    ) {
        self.imageName = imageName
        self.emotion = emotion
        self.isReacting = isReacting
        self.isWiggling = isWiggling
    }
    
    private var resolvedImageName: String? {
        guard let name = imageName, !name.isEmpty else { return nil }
        let resolved = AssetFallbackHelper.imageName(for: name)
        if resolved != "fallback_globe" && AssetFallbackHelper.hasAsset(named: resolved) {
            return resolved
        }
        return AssetFallbackHelper.hasAsset(named: name) ? name : nil
    }
    
    var body: some View {
        if let name = resolvedImageName {
            Image(name)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(isWiggling ? 7 : 0))
                .scaleEffect(isWiggling ? 1.12 : (isReacting ? 1.08 : 1.0))
                .shadow(color: emotion.themeColor.opacity(isWiggling ? 0.7 : 0.4), radius: isWiggling ? 12 : 8, x: 0, y: isWiggling ? 6 : 4)
                .animation(.spring(response: 0.25, dampingFraction: 0.4), value: isWiggling)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isReacting)
        } else {
            PlaceholderCharacterView(emotion: emotion, isReacting: isReacting || isWiggling)
        }
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView(imageName: "rhodey", emotion: .happy)
    }
}
