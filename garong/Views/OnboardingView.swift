import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var contentOpacity: Double = 0
    @State private var contentScale: CGFloat = 1.025
    @State private var contentOffset: CGFloat = 8

    @State private var didFinish = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {

                // BACKGROUND
                Image("IDCardBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: width,
                        height: height
                    )
                    .clipped()

                // DECORATION
                Image("RhodeyDecoration")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: width,
                        height: height
                    )

                // RHODEY NAME + DETAILS
                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Image("RhodeyOnboardingName")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.30
                        )

                    Image("RhodeyOnboardingDetails")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: width * 0.38
                        )
                }
                .position(
                    x: width * 0.67,
                    y: height * 0.47
                )
            }
            .frame(
                width: width,
                height: height
            )
            .scaleEffect(contentScale)
            .offset(y: contentOffset)
            .opacity(contentOpacity)
        }
        .ignoresSafeArea()
        .background(Color.white)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {

        // Smooth entrance
        withAnimation(
            .easeOut(duration: 0.55)
        ) {
            contentOpacity = 1
            contentScale = 1
            contentOffset = 0
        }

        // Stay around 2 seconds
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2
        ) {
            guard !didFinish else {
                return
            }

            didFinish = true

            // Fade onboarding slightly first
            withAnimation(
                .easeInOut(duration: 0.45)
            ) {
                contentOpacity = 0
                contentScale = 0.985
            }

            // Then switch to Main Menu
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.28
            ) {
                onFinish()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView {
            print("Go to Main Menu")
        }
        .previewLayout(.fixed(width: 812, height: 375))
    }
}
