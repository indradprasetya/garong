import Foundation

@main
struct TutorialCalloutLayoutTests {
    static func main() {
        let viewportHeight: CGFloat = 800

        precondition(
            TutorialCalloutLayout.edge(
                for: CGRect(x: 300, y: 40, width: 80, height: 60),
                viewportHeight: viewportHeight
            ) == .below,
            "A toolbar target needs its instruction below it"
        )

        precondition(
            TutorialCalloutLayout.edge(
                for: CGRect(x: 300, y: 690, width: 80, height: 60),
                viewportHeight: viewportHeight
            ) == .above,
            "A tray target needs its instruction above it"
        )

        print("TutorialCalloutLayoutTests passed")
    }
}
