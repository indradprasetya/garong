import SwiftUI

enum GarongTheme {
    static let ink = Color(red: 0.09, green: 0.22, blue: 0.25)
    static let teal = Color(red: 0.18, green: 0.49, blue: 0.47)
    static let coral = Color(red: 0.85, green: 0.42, blue: 0.37)
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.89)
    static let mint = Color(red: 0.86, green: 0.94, blue: 0.91)
    static let sun = Color(red: 0.98, green: 0.77, blue: 0.32)

    static let pageBackground = LinearGradient(
        colors: [cream, mint.opacity(0.72)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct GarongPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(GarongTheme.teal.opacity(configuration.isPressed ? 0.78 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct GarongSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(GarongTheme.ink)
            .padding(.horizontal, 22)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(configuration.isPressed ? 0.72 : 0.92))
                    .stroke(GarongTheme.teal.opacity(0.25), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
