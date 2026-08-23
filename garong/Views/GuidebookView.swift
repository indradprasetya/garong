import SwiftUI

struct GuidebookView: View {
    var onBack: (() -> Void)? = nil

    @ObservedObject private var localization = AppLocalization.shared
    @State private var currentPage = 0

    let items: [GuidebookItem] = GuidebookData.items

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
                            Image("guidebook_back_button")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, -32)

                        Spacer()

                        Text(localization.text("guidebook.title"))
                            .font(.appFont(size: 58))
                            .foregroundStyle(.white)
                            .padding(.top, 24)
                            .bold()

                        Spacer()

                        // Balanced invisible placeholder for header centering
                        Color.clear
                            .frame(width: 48, height: 48)
                    }
                    .padding(.horizontal, 72)

                    Spacer(minLength: 8)

                    // Notebook Page Content with Prev/Next Navigation
                    HStack(spacing: 12) {
                        // Previous Page Button
                        Button {
                            if currentPage > 0 {
                                SoundManager.shared.play(.buttonTap)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage -= 1
                                }
                            }
                        } label: {
                            Image("chevron_right")
                                .resizable()
                                .scaledToFit()
                                .rotationEffect(.degrees(180))
                                .frame(width: width * 0.070)
                                .opacity(currentPage > 0 ? 1.0 : 0.0)
                        }
                        .disabled(currentPage == 0)
                        .buttonStyle(.plain)

                        // Content Container
                        ZStack {
                            let item = items[currentPage]

                            if !item.isBookReference {
                                Image("guidebook_placeholder")
                                    .resizable()
                                    .scaledToFit()
                            }

                            GeometryReader { notebookGeo in
                                let bookWidth = notebookGeo.size.width
                                let bookHeight = notebookGeo.size.height

                                HStack(spacing: 0) {
                                    if item.isBookReference {
                                        // LEFT SIDE: Book Reference Image
                                        VStack {
                                            Spacer()
                                            Image("book_reference")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxHeight: bookHeight * 0.75)
                                            Spacer()
                                        }
                                        .padding(.leading, bookWidth * 0.04)
                                        .padding(.trailing, bookWidth * 0.04)
                                        .frame(width: bookWidth * 0.48, height: bookHeight)

                                        // RIGHT SIDE: Reference Text
                                        VStack(alignment: .leading) {
                                            Spacer()
                                            Text(localization.text(item.paragraph1Key))
                                                .font(.appFont(size: 32))
                                                .foregroundStyle(.white)
                                                .lineSpacing(6)
                                                .multilineTextAlignment(.center)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .frame(width: bookWidth * 0.52, height: bookHeight, alignment: .leading)
                                    } else {
                                        // LEFT PAGE CONTENT
                                        VStack(alignment: .center) {
                                            Text(localization.text(item.titleKey))
                                                .font(.appFont(size: 22))
                                                .foregroundStyle(.black)

                                            HStack(spacing: 10) {
                                                if let leftChar = item.leftChar {
                                                    Image(leftChar)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxHeight: bookHeight * 0.42)

                                                    Image(systemName: "arrow.right")
                                                        .font(.system(size: 24, weight: .bold))
                                                        .foregroundStyle(Color(red: 0.9, green: 0.25, blue: 0.1))

                                                    Image(item.rightChar)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxHeight: bookHeight * 0.42)
                                                } else {
                                                    Spacer()
                                                    Image(item.rightChar)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxHeight: bookHeight * 0.42)
                                                    Spacer()
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        .padding(.leading, bookWidth * 0.08)
                                        .padding(.trailing, bookWidth * 0.04)
                                        .padding(.top, bookHeight * 0.26)
                                        .padding(.bottom, bookHeight * 0.12)
                                        .frame(width: bookWidth * 0.49, height: bookHeight, alignment: .topLeading)

                                        // RIGHT PAGE CONTENT
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text(localization.text(item.paragraph1Key))
                                                .font(.appFont(size: 16))
                                                .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.15))
                                                .lineSpacing(4)

                                            if let paragraph2Key = item.paragraph2Key {
                                                Text(localization.text(paragraph2Key))
                                                    .font(.appFont(size: 16))
                                                    .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.15))
                                                    .lineSpacing(4)
                                            }
                                            Spacer(minLength: 0)
                                        }
                                        .padding(.leading, bookWidth * 0.05)
                                        .padding(.trailing, bookWidth * 0.08)
                                        .padding(.top, bookHeight * 0.28)
                                        .padding(.bottom, bookHeight * 0.12)
                                        .frame(width: bookWidth * 0.49, height: bookHeight, alignment: .topLeading)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: min(width * 0.82, 780), maxHeight: height * 0.75)

                        // Next Page Button
                        Button {
                            if currentPage < items.count - 1 {
                                SoundManager.shared.play(.buttonTap)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }
                        } label: {
                            Image("chevron_right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: width * 0.070)
                                .opacity(currentPage < items.count - 1 ? 1.0 : 0.0)
                        }
                        .disabled(currentPage == items.count - 1)
                        .buttonStyle(.plain)
                    }
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
    GuidebookView()
}
