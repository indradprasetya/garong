import SwiftUI

struct CharacterView: View {
    let emotion: CharacterEmotion
    let isReacting: Bool
    
    var body: some View {
        PlaceholderCharacterView(emotion: emotion, isReacting: isReacting)
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        Text("CharacterView Preview")
    }
}
