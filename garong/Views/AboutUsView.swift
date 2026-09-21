import SwiftUI
import UIKit

struct AboutUsView: View {
    let onBack: () -> Void

    @ObservedObject private var localization = AppLocalization.shared
    @ObservedObject private var textSizeManager = AppTextSizeManager.shared

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let compact = width < 750
            let textScale: CGFloat = textSizeManager.textSize == .standard ? 1.35 : 1.45

            ZStack {
                Image(.storiesGreenGrid)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()

                teamPaper(width: width, height: height, compact: compact)
                    .rotationEffect(.degrees(-4))
                    .position(x: width * 0.29, y: height * 0.57)
                    .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 8)

                storyPaper(
                    width: width,
                    height: height,
                    compact: compact,
                    textScale: textScale
                )
                .position(x: width * 0.69, y: height * 0.52)
                .shadow(color: .black.opacity(0.18), radius: 8, x: 2, y: 5)

                Image(.arrowSnake)
                    .resizable()
                    .scaledToFit()
                    .frame(width: compact ? 68 : 88)
                    .position(x: width * 0.47, y: height * 0.39)
                    .accessibilityHidden(true)

                Image(.aboutStar)
                    .resizable()
                    .scaledToFit()
                    .frame(width: compact ? 50 : 62)
                    .rotationEffect(.degrees(-8))
                    .position(x: width * 0.45, y: height * 0.61)
                    .accessibilityHidden(true)

                Image(.pencil)
                    .resizable()
                    .scaledToFit()
                    .frame(height: compact ? 118 : 145)
                    .position(x: width * 0.94, y: height * 0.90)
                    .accessibilityHidden(true)

                VStack {
                    HStack {
                        Button {
                            SoundManager.shared.play(.backTap)
                            onBack()
                        } label: {
                            HStack(spacing: 5) {
                                Image(.chevronRight)
                                    .resizable()
                                    .scaledToFit()
                                    .rotationEffect(.degrees(180))
                                    .frame(height: compact ? 30 : 38)

                                Text(localization.text("about.back"))
                                    .font(.appFontBold(size: compact ? 22 : 27, relativeTo: .headline))
                                    .foregroundStyle(.white)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(localization.text("about.back"))

                        Spacer()
                    }
                    .padding(.leading, compact ? 24 : 34)
                    .padding(.top, compact ? 18 : 24)

                    Spacer()
                }
            }
            .frame(width: width, height: height)
            .contentShape(Rectangle())
        }
        .ignoresSafeArea()
    }

    private func teamPaper(width: CGFloat, height: CGFloat, compact: Bool) -> some View {
        let paperWidth = min(width * (compact ? 0.37 : 0.38), 360)
        let paperHeight = paperWidth / (2644.0 / 2008.0)

        return ZStack {
            Image(.bgSetting)
                .resizable()
                .scaledToFit()
                .frame(width: paperWidth, height: paperHeight)

            VStack(spacing: compact ? 1 : 4) {
                Text(localization.text("about.teamTitle"))
                    .font(.appFontBold(size: compact ? 24 : 29, relativeTo: .headline))
                    .foregroundStyle(Color(red: 0.22, green: 0.22, blue: 0.20))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .rotationEffect(.degrees(-2))
                    .offset(x: compact ? -8 : -10)

                Image(.aboutTeam)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: paperHeight * 0.58)
                    .rotationEffect(.degrees(4))
                    .accessibilityLabel(localization.text("about.teamImageLabel"))
            }
            .frame(width: paperWidth * 0.72, height: paperHeight * 0.72)
            .offset(y: paperHeight * 0.02)
        }
        .frame(width: paperWidth, height: paperHeight)
    }

    private func storyPaper(
        width: CGFloat,
        height: CGFloat,
        compact: Bool,
        textScale: CGFloat
    ) -> some View {
        let paperWidth = min(width * (compact ? 0.55 : 0.56), 510)
        let paperHeight = paperWidth / (1784.0 / 1152.0)

        return ZStack {
            Image(.paperHint)
                .resizable()
                .scaledToFit()
                .frame(width: paperWidth, height: paperHeight)
                .rotationEffect(.degrees(182))

            VStack(spacing: compact ? 4 : 7) {
                InlineLogoLabel(
                    text: localization.text("about.whyTitle"),
                    fontName: AppFont.boldFontName,
                    fontSize: (compact ? 20 : 24) * textScale,
                    logoHeight: (compact ? 25 : 31) * textScale,
                    lineSpacing: 1,
                    maximumLines: 2
                )
                .frame(height: paperHeight * 0.22)

                InlineLogoLabel(
                    text: localization.text("about.body"),
                    fontName: AppFont.fontName,
                    fontSize: (compact ? 11.5 : 13.5) * textScale,
                    logoHeight: (compact ? 30 : 20) * textScale,
                    lineSpacing: compact ? 1 : 2,
                    maximumLines: 11
                )
                .frame(height: paperHeight * 0.60)
            }
            .frame(width: paperWidth * 0.79, height: paperHeight * 0.88)
            .rotationEffect(.degrees(2))
        }
        .frame(width: paperWidth, height: paperHeight)
    }
}

private struct InlineLogoLabel: UIViewRepresentable {
    let text: String
    let fontName: String
    let fontSize: CGFloat
    let logoHeight: CGFloat
    let lineSpacing: CGFloat
    let maximumLines: Int

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = maximumLines
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        label.numberOfLines = maximumLines
        label.attributedText = attributedText()
        label.accessibilityLabel = text
        label.isAccessibilityElement = true
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UILabel,
        context: Context
    ) -> CGSize? {
        guard let width = proposal.width else { return nil }
        uiView.preferredMaxLayoutWidth = width
        return uiView.sizeThatFits(
            CGSize(width: width, height: proposal.height ?? .greatestFiniteMagnitude)
        )
    }

    private func attributedText() -> NSAttributedString {
        let font = UIFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = lineSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(red: 0.16, green: 0.16, blue: 0.15, alpha: 1),
            .paragraphStyle: paragraphStyle
        ]
        let result = NSMutableAttributedString()
        let parts = text.components(separatedBy: "Kinario")

        for (index, part) in parts.enumerated() {
            result.append(NSAttributedString(string: part, attributes: attributes))
            guard index < parts.count - 1, let logo = UIImage(named: "kinario_title") else {
                continue
            }

            let attachment = NSTextAttachment()
            attachment.image = logo
            attachment.bounds = CGRect(
                x: 0,
                y: font.descender * 1.5,
                width: logoHeight * logo.size.width / logo.size.height,
                height: logoHeight
            )
            result.append(NSAttributedString(attachment: attachment))
        }

        return result
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView(onBack: {})
            .previewLayout(.fixed(width: 812, height: 375))
    }
}
