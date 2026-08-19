import SwiftUI
import UIKit

struct MainMenuView: View {

    var body: some View {
        AppBackground {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                HStack(spacing: width * 0.065) {

                    // MARK: - LEFT CONTENT
                    VStack(alignment: .leading, spacing: 0) {

                        Spacer()

                        Text("A SMALL STEP CAN\nCHANGE THE MOMENT")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .tracking(4)
                            .foregroundStyle(
                                Color(
                                    red: 0.88,
                                    green: 0.38,
                                    blue: 0.33
                                )
                            )

                        Spacer()
                            .frame(height: 28)

                        Text("GARONG")
                            .font(
                                .system(
                                    size: 55,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                Color(
                                    red: 0.03,
                                    green: 0.19,
                                    blue: 0.22
                                )
                            )

                        Spacer()
                            .frame(height: 30)

                        Text(
                            "Observe. Try an approach.\nWatch what changes."
                        )
                        .font(
                            .system(
                                size: 24,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            Color(
                                red: 0.08,
                                green: 0.55,
                                blue: 0.51
                            )
                        )
                        .lineSpacing(7)

                        Spacer()
                            .frame(height: 25)

                        Text(
                            """
                            A story-driven interaction game about
                            responding to children with curiosity,
                            care, and flexible support.
                            """
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .regular,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            Color(
                                red: 0.30,
                                green: 0.42,
                                blue: 0.44
                            )
                        )
                        .lineSpacing(5)

                        Spacer()
                    }
                    .frame(
                        width: width * 0.40,
                        alignment: .leading
                    )


                    // MARK: - RIGHT CARD
                    VStack(spacing: 14) {

                        Spacer()
                            .frame(height: 14)

                        // Rhodey illustration
                        ZStack {
                            Circle()
                                .fill(
                                    Color(
                                        red: 1.0,
                                        green: 0.90,
                                        blue: 0.68
                                    )
                                )
                                .frame(
                                    width: height * 0.31,
                                    height: height * 0.31
                                )

                            Image("Rhodey")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: height * 0.23,
                                    height: height * 0.23
                                )
                        }


                        // MARK: Start Story
                        Button {
                            // Masukkan navigation Start Story kamu di sini
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")

                                Text("Start a Story")
                            }
                            .font(
                                .system(
                                    size: 20,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 58
                            )
                            .background(
                                Color(
                                    red: 0.08,
                                    green: 0.55,
                                    blue: 0.51
                                )
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 20
                                )
                            )
                        }
                        .buttonStyle(.plain)


                        // MARK: Browse Chapters
                        Button {
                            // Masukkan navigation Browse Chapters kamu di sini
                        } label: {
                            HStack(spacing: 12) {
                                Image(
                                    systemName:
                                        "square.grid.2x2.fill"
                                )

                                Text("Browse Chapters")
                            }
                            .font(
                                .system(
                                    size: 19,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                Color(
                                    red: 0.03,
                                    green: 0.19,
                                    blue: 0.22
                                )
                            )
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 58
                            )
                            .background(.white)
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 20
                                )
                                .stroke(
                                    Color.gray.opacity(0.25),
                                    lineWidth: 1.5
                                )
                            }
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 20
                                )
                            )
                        }
                        .buttonStyle(.plain)


                        Text(
                            """
                            No scores. No wrong answers.
                            Your choices shape the response.
                            """
                        )
                        .font(
                            .system(
                                size: 13,
                                weight: .medium,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                        Spacer()
                            .frame(height: 12)
                    }
                    .padding(.horizontal, 28)
                    .frame(
                        width: width * 0.34,
                        height: height * 0.88
                    )
                    .background(
                        Color.white.opacity(0.94)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 34
                        )
                    )
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 12,
                        y: 5
                    )
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
            }
        }

        // MARK: - FONT CHECK
        .onAppear {
            print("========== VIRELS FONT CHECK ==========")

            for family in UIFont.familyNames.sorted() {
                for font in UIFont.fontNames(
                    forFamilyName: family
                ) {
                    if font
                        .lowercased()
                        .contains("virel") {

                        print("FONT FOUND:", font)
                    }
                }
            }

            print("=======================================")
        }
    }
}


// MARK: - PREVIEW

#Preview {
    MainMenuView()
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
