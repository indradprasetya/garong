#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct CharacterView: View {
    let imageName: String?
    let emotion: CharacterEmotion
    let isReacting: Bool
    
    init(imageName: String? = nil, emotion: CharacterEmotion = .neutral, isReacting: Bool = false) {
        self.imageName = imageName
        self.emotion = emotion
        self.isReacting = isReacting
    }
    
    var body: some View {
        #if canImport(UIKit)
        if let name = imageName, !name.isEmpty, UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFit()
                .scaleEffect(isReacting ? 1.08 : 1.0)
                .shadow(color: emotion.themeColor.opacity(0.4), radius: 8, x: 0, y: 4)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isReacting)
        } else {
            PlaceholderCharacterView(emotion: emotion, isReacting: isReacting)
        }
        #else
        if let name = imageName, !name.isEmpty {
            Image(name)
                .resizable()
                .scaledToFit()
                .scaleEffect(isReacting ? 1.08 : 1.0)
                .shadow(color: emotion.themeColor.opacity(0.4), radius: 8, x: 0, y: 4)
        } else {
            PlaceholderCharacterView(emotion: emotion, isReacting: isReacting)
        }
        #endif
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView(imageName: "rhodey", emotion: .happy)
    }
}
