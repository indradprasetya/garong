import SwiftUI

struct AppBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background boleh full sampai bezel
            Image("IDCardBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // CONTENT JANGAN ignoresSafeArea
            content
        }
    }
}
