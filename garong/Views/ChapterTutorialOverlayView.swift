import SwiftUI

enum TutorialCalloutEdge: Equatable {
    case above
    case below
}

struct TutorialCalloutLayout {
    static func edge(for target: CGRect, viewportHeight: CGFloat) -> TutorialCalloutEdge {
        target.midY > viewportHeight / 2 ? .above : .below
    }
}

struct TutorialTargetPreferenceKey: PreferenceKey {
    static var defaultValue: [Anchor<CGRect>] = []

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value.append(contentsOf: nextValue())
    }
}

struct ChapterTutorialOverlayView<Target: View>: View {
    let step: ChapterTutorialStep
    let message: String
    let targetRects: [CGRect]
    @ViewBuilder let targetView: (CGRect) -> Target

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                if let target = targetRects.last {
                    targetView(target)
                        .frame(width: target.width, height: target.height)
                        .position(x: target.midX, y: target.midY)

                    callout(for: target, viewport: proxy.size)
                }
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func callout(for target: CGRect, viewport: CGSize) -> some View {
        let edge = TutorialCalloutLayout.edge(for: target, viewportHeight: viewport.height)
        let x = min(max(target.midX, 170), viewport.width - 170)

        if step == .wrongAndHint {
            VStack(spacing: 4) {
                peekHintArrow
                instructionText
            }
                .position(
                    x: min(x + 70, viewport.width - 170),
                    y: min(viewport.height - 82, target.maxY + 82)
                )
        } else if edge == .above {
            VStack(spacing: 6) {
                instructionText
                arrow
            }
            .position(x: x, y: max(70, target.minY - 62))
        } else {
            VStack(spacing: 6) {
                arrow.rotationEffect(.degrees(180))
                instructionText
            }
            .position(x: x, y: min(viewport.height - 70, target.maxY + 62))
        }
    }

    private var instructionText: some View {
        Text(message)
            .font(.appFont(size: 22, relativeTo: .body))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.8), radius: 3, y: 2)
            .frame(width: 340)
    }

    private var arrow: some View {
        Group {
            if AssetFallbackHelper.hasAsset(named: "red_arrow_hint") {
                Image("red_arrow_hint")
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "arrow.down")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.red)
            }
        }
        .frame(width: 34, height: 50)
    }

    private var peekHintArrow: some View {
        Group {
            if AssetFallbackHelper.hasAsset(named: "peek_hint") {
                Image("peek_hint")
                    .resizable()
                    .scaledToFit()
            } else {
                arrow.rotationEffect(.degrees(180))
            }
        }
        .frame(width: 90, height: 70)
    }
}

private struct TutorialTargetModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content.anchorPreference(key: TutorialTargetPreferenceKey.self, value: .bounds) {
            isActive ? [$0] : []
        }
    }
}

extension View {
    func tutorialTarget(_ isActive: Bool) -> some View {
        modifier(TutorialTargetModifier(isActive: isActive))
    }
}
