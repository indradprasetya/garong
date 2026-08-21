//
//  ChapterResultView.swift
//  garong
//
//  Created by Muhammad Bintang Al-Fath on 21/08/26.
//

import SwiftUI

struct ChapterResultView: View {
    let result: ChapterResult
    var onBack: (() -> Void)? = nil
    var onNext: (() -> Void)? = nil
    var onTryAgain: (() -> Void)? = nil
    var statusMessage: String? = nil
    @ObservedObject private var localization = AppLocalization.shared

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // Background Grid
                Image("StoriesGreenGrid")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()

                VStack(spacing: 0) {
                    // Top Navigation Header
                    HStack {
                        Button {
                            SoundManager.shared.play(.backTap)
                            onBack?()
                        } label: {
                            if AssetFallbackHelper.hasAsset(named: "guidebook_back_button") {
                                Image("guidebook_back_button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 48)
                            } else {
                                Image(systemName: "arrow.backward.square.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        if let onTryAgain {
                            Button {
                                SoundManager.shared.play(.buttonTap)
                                onTryAgain()
                            } label: {
                                Text(localization.text("result.tryAgain"))
                                    .font(.appFont(size: 28))
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 18)
                                    .frame(height: 48)
                                    .background(
                                        Capsule()
                                            .fill(.white)
                                            .stroke(.red, lineWidth: 3)
                                    )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                SoundManager.shared.play(.buttonTap)
                                onNext?()
                            } label: {
                                if AssetFallbackHelper.hasAsset(named: "next_button") {
                                    Image(.nextButtonResult)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 48)
                                } else {
                                    HStack(spacing: 6) {
                                        Text(localization.text("result.next"))
                                            .font(.appFont(size: 28))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                    .foregroundStyle(.white)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 72)

                    Spacer(minLength: 8)

                    // Notebook Page Content
                    ZStack {
                        Image("guidebook_placeholder")
                            .resizable()
                            .scaledToFit()

                        GeometryReader { notebookGeo in
                            let bookWidth = notebookGeo.size.width
                            let bookHeight = notebookGeo.size.height

                            HStack(spacing: 0) {
                                // LEFT PAGE: RESULT
                                VStack(alignment: .center) {
                                    Text(localization.text("result.title"))
                                        .font(.appFont(size: 32))
                                        .foregroundStyle(Color(red: 0.9, green: 0.28, blue: 0.1))

                                    if let resultMessage = statusMessage ?? result.completionSummary {
                                        Text(resultMessage)
                                            .font(.appFont(size: 18))
                                            .foregroundStyle(
                                                statusMessage == nil
                                                    ? Color(red: 0.15, green: 0.15, blue: 0.15)
                                                    : .red
                                            )
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(4)
                                            .padding(.horizontal, 8)
                                    }


                                    HStack(alignment: .center, spacing: 16) {
                                        // Meter head icon
                                        if AssetFallbackHelper.hasAsset(named: result.meterImageName) {
                                            Image(result.meterImageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxHeight: bookHeight * 0.35)
                                        } else {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 60))
                                                .foregroundStyle(.yellow)
                                        }

                                        // Yellow stars earned
                                        if result.stars > 0 {
                                            HStack(spacing: 8) {
                                                ForEach(0..<result.stars, id: \.self) { index in
                                                    let yOffset: CGFloat = (result.stars == 3 && index == 1) ? -8 : 4
                                                    Image("StarIcon")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 38, height: 38)
                                                        .offset(y: yOffset)
                                                }
                                            }
                                        }
                                    }

                                    Spacer(minLength: 0)
                                }
                                .padding(.leading, bookWidth * 0.08)
                                .padding(.trailing, bookWidth * 0.04)
                                .padding(.top, bookHeight * 0.22)
                                .padding(.bottom, bookHeight * 0.12)
                                .frame(width: bookWidth * 0.49, height: bookHeight, alignment: .top)

                                // RIGHT PAGE: TIPS
                                VStack(alignment: .center) {
                                    Text(localization.text("result.tips"))
                                        .font(.appFont(size: 32))
                                        .foregroundStyle(Color(red: 0.9, green: 0.28, blue: 0.1))


                                    if let completionTip = result.completionTip {
                                        Text(completionTip)
                                            .font(.appFont(size: 20))
                                            .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.15))
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(6)
                                            .padding(.horizontal, 12)
                                    }

                                    Spacer(minLength: 0)
                                }
                                .padding(.leading, bookWidth * 0.04)
                                .padding(.trailing, bookWidth * 0.08)
                                .padding(.top, bookHeight * 0.22)
                                .padding(.bottom, bookHeight * 0.12)
                                .frame(width: bookWidth * 0.49, height: bookHeight, alignment: .top)
                            }
                        }
                    }
                    .frame(maxWidth: min(width * 0.82, 780), maxHeight: height * 0.75)
                    .padding(.horizontal, 54)

                    Spacer(minLength: 16)
                }
            }
            .frame(width: width, height: height)
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}

#Preview {
    ChapterResultView(
        result: ChapterResult(
            chapterName: "Make Rhodey Want to Draw",
            totalObjects: 2,
            placedObjects: 2,
            placementCount: 2,
            stars: 3,
            completionSummary: "Rhodey needed to feel noticed before he could join in.",
            completionTip: "Before asking a hesitant child to join an activity, sit with them first. Let them feel your presence before you invite them in.",
            sceneStates: [],
            characterName: "Rhodey",
            meterImageName: "rhodey_3_star"
        )
    )
}
