import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var showArtwork = true
    @State private var showName = true
    @State private var showDetails = true
    @State private var showButton = true
    @State private var hasStartedReveal = false

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 760

            ZStack {
                NotebookBackground()

                Group {
                    if compact {
                        VStack(spacing: 8) {
                            artwork.frame(maxWidth: 440)
                            profile.frame(maxWidth: 440)
                        }
                    } else {
                        HStack(spacing: 10) {
                            artwork.frame(maxWidth: .infinity)
                            profile.frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, compact ? 26 : 42)
                .padding(.vertical, 28)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: finish) {
                            HStack(spacing: 10) {
                                Text("Let's play")
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 54)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.03, green: 0.53, blue: 0.93))
                                    .shadow(color: .blue.opacity(0.2), radius: 10, y: 5)
                            )
                        }
                        .buttonStyle(.plain)
                        .opacity(showButton ? 1 : 0)
                        .offset(y: showButton ? 0 : 14)
                        .accessibilityHint("Opens the main menu")
                    }
                    .padding(28)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            guard !hasStartedReveal else { return }
            hasStartedReveal = true

            // Content starts visible as a safe fallback. Hide it only when the
            // reveal task actually begins, preventing a cancelled task from
            // leaving an empty white screen.
            showArtwork = false
            showName = false
            showDetails = false
            showButton = false
            Task { await revealContent() }
        }
    }

    private var artwork: some View {
        Image("RhodeyOnboardingArtwork")
            .resizable()
            .scaledToFit()
            .opacity(showArtwork ? 1 : 0)
            .scaleEffect(showArtwork ? 1 : 0.86)
            .rotationEffect(.degrees(showArtwork ? 0 : -4))
            .accessibilityLabel("A playful polaroid picture of Rhodey surrounded by colorful doodles")
    }

    private var profile: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image("RhodeyOnboardingName")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 320, alignment: .leading)
                .opacity(showName ? 1 : 0)
                .offset(x: showName ? 0 : 30)
                .accessibilityLabel("Rhodey")

            Image("RhodeyOnboardingDetails")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 405, alignment: .leading)
                .opacity(showDetails ? 1 : 0)
                .offset(y: showDetails ? 0 : 18)
                .accessibilityLabel("Age three. Characteristics: loud and highly active. Favorite subject: English.")
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }

    @MainActor
    private func revealContent() async {
        withAnimation(.spring(response: 0.65, dampingFraction: 0.72)) { showArtwork = true }
        try? await Task.sleep(for: .milliseconds(350))
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) { showName = true }
        try? await Task.sleep(for: .milliseconds(250))
        withAnimation(.easeOut(duration: 0.55)) { showDetails = true }
        try? await Task.sleep(for: .milliseconds(350))
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) { showButton = true }
    }

    private func finish() {
        withAnimation(.easeInOut(duration: 0.35)) { onFinish() }
    }
}

private struct NotebookBackground: View {
    private let gridSize: CGFloat = 44

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.99, green: 0.98, blue: 0.97)))

            var grid = Path()
            stride(from: gridSize, through: size.width, by: gridSize).forEach { x in
                grid.move(to: CGPoint(x: x, y: 0))
                grid.addLine(to: CGPoint(x: x, y: size.height))
            }
            stride(from: gridSize, through: size.height, by: gridSize).forEach { y in
                grid.move(to: CGPoint(x: 0, y: y))
                grid.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(grid, with: .color(Color.gray.opacity(0.15)), lineWidth: 1.5)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    OnboardingView(onFinish: {})
        .previewInterfaceOrientation(.landscapeLeft)
}
