//
//  LetterView.swift
//  garong
//
//  Created by Muhammad Bintang Al-Fath on 25/08/26.
//

import SwiftUI

struct LetterView: View {
    var onContinue: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localization = AppLocalization.shared
    @ObservedObject private var textSizeManager = AppTextSizeManager.shared

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            // Responsive card dimensions based on landscape screen size
            let letterWidth = min(screenWidth * 0.56, 520.0)
            let photoWidth = min(screenWidth * 0.42, 380.0)

            ZStack {
                // 1. Full Screen Background Grid (Edge-to-edge, unclipped)
                Image(.storiesGreenGrid)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // 2. Layered Desk Composition (Centered independently)
                ZStack {
                    // Back Layer: Photo Card (paperHint + Rhodey & Jojo)
                    photoCardView(width: photoWidth)
                        .offset(x: letterWidth * 0.35, y: screenHeight * 0.1)
                        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 2, y: 5)

                    // Front Layer: Letter Card (bgSetting + Letter Content)
                    letterCardView(width: letterWidth)
                        .rotationEffect(.degrees(-4))
                        .offset(x: -screenWidth * 0.17, y: 0)
                        .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 8)
                    
                    Image(.arrowSnake)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .offset(x: screenWidth * 0.06, y: screenHeight * 0.05)
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 3. Top-Trailing Next Button Overlay (Independent layer)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            SoundManager.shared.play(.buttonTap)
                            if let onContinue {
                                onContinue()
                            } else {
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(localization.text("result.next"))
                                    .font(.appFont(size: 28))
                                    .foregroundStyle(.white)
                                Image(.chevronRight)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 44)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 36)
                    .padding(.top, 24)

                    Spacer()
                    
                    Image(.pencil)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                }
            }
            .frame(width: screenWidth, height: screenHeight)
        }
        .ignoresSafeArea()
    }

    // MARK: - Photo Card (.paperHint + Characters fitted inside)
    @ViewBuilder
    private func photoCardView(width: CGFloat) -> some View {
        let aspectRatio: CGFloat = 1784.0 / 1152.0 // paper_hint aspect ratio
        let height = width / aspectRatio

        ZStack {
            // Paper Background
            Image(.paperHint)
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .rotationEffect(.degrees(186))

            // Characters Content fitted cleanly within the paper's inner area
            HStack(alignment: .bottom, spacing: width * 0.09) {
                Spacer()
                VStack {
                    Text(localization.text("letter.rhodey"))
                        .font(.appFontBold(size: min(width * 0.5, 32)))
                    
                    Image(.rhodeyHappy)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: height * 0.72)
                }

                VStack {
                    Text(localization.text("letter.jojo"))
                        .font(.appFontBold(size: min(width * 0.5, 32)))
                    
                    Image(.jojoQuestioning)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: height * 0.72)
                }
            }
            .rotationEffect(.degrees(6))
            .padding(.horizontal, width * 0.2)
            .padding(.vertical, height * 0.15)
        }
        .frame(width: width, height: height)
    }

    // MARK: - Letter Card (.bgSetting + Text Content fitted inside)
    @ViewBuilder
    private func letterCardView(width: CGFloat) -> some View {
        let aspectRatio: CGFloat = 414.0 / 314.0 // bg_setting aspect ratio
        let height = width / aspectRatio

        ZStack {
            // Stamp Letter Background
            Image(.bgSetting)
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.9, height: height * 0.9)

            // Text Content fitted within the safe writable margins
            VStack(alignment: .leading, spacing: height * 0.035) {
                Text(localization.text("letter.greeting"))
                    .font(.appFontBold(size: min(width * 0.5, 32)))
                    .foregroundStyle(Color(red: 0.8, green: 0.07, blue: 0.07))

                VStack(alignment: .leading, spacing: height * 0.05) {
                    Text(localization.text("letter.body1"))
                        .font(.appFont(size: min(width * 0.5, 20)))
                        .lineSpacing(3)
                        .minimumScaleFactor(0.70)

                    Text(localization.text("letter.body2"))
                        .font(.appFont(size: min(width * 0.5, 20)))
                        .lineSpacing(3)
                        .minimumScaleFactor(0.70)

                    Text(localization.text("letter.sign"))
                        .font(.appFont(size: min(width * 0.3, 20)))
                        .lineSpacing(2)
                        .minimumScaleFactor(0.70)
                }

            }
            .padding(.horizontal, width * 0.15)
            .padding(.top, height * 0.2)
            .padding(.bottom, height * 0.1)
            .frame(width: width, height: height, alignment: .topLeading)
        }
        .frame(width: width, height: height)
    }
}

struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        LetterView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

