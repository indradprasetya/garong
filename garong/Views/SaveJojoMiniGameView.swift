import SwiftUI
import Combine

struct SaveJojoMiniGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var game = SaveJojoGameState()
    @State private var feedbackColor = Color.clear
    @State private var pullHeld = false
    @State private var catchBarPosition = 0.62
    @State private var catchBarVelocity = 0.0
    @State private var rescueProgress = 0.25
    @State private var lastPullTick: Date?
    @State private var failureCooldown = 0.0
    @State private var caughtJojoX = 0.5
    @State private var caughtTransitionStart: Date?
    @State private var pullAnimationStart = Date()
    @State private var rescueTransitionStart: Date?
    @State private var rescueStartX = 0.43
    @State private var rescueStartY = 0.31
    @State private var missedThrowStart: Date?
    @State private var missedThrowAngle = 0.0

    private let pullTimer = Timer.publish(
        every: 1.0 / 60.0,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                if game.phase == .onboarding {
                    onboardingScene(width: width, height: height)
                } else if game.phase == .aiming {
                    aimingScene(width: width, height: height)
                } else if game.phase == .caught {
                    caughtTransitionScene(width: width, height: height)
                } else if game.phase == .pulling {
                    pullingScene(width: width, height: height)
                } else if game.phase == .rescuing {
                    rescueTransitionScene(width: width, height: height)
                } else {
                    backgroundImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()

                    interactionLayer(width: width, height: height)
                }

                if feedbackColor != .clear {
                    feedbackColor
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .frame(width: width, height: height)
            .contentShape(Rectangle())
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onReceive(pullTimer) { date in
            updatePullMechanic(at: date)
        }
        .onAppear {
            BackgroundMusicManager.shared.play(.miniGameOnboarding)
        }
        .onChange(of: game.phase) { _, phase in
            switch phase {
            case .won:
                SoundManager.shared.play(.chapterComplete)
                SoundManager.shared.playVoiceOver(.happy)
            case .lost:
                SoundManager.shared.play(.chapterRetry)
            default:
                break
            }
        }
        .onDisappear {
            BackgroundMusicManager.shared.play(.menu)
        }
    }

    private var backgroundImage: Image {
        switch game.phase {
        case .onboarding: Image("save_jojo_onboarding")
        case .aiming: Image("save_jojo_aim")
        case .caught: Image("save_jojo_caught")
        case .pulling: Image("save_jojo_pull")
        case .rescuing: Image("save_jojo_pull")
        case .won: Image("save_jojo_win")
        case .lost: Image("save_jojo_lose")
        }
    }

    private func onboardingScene(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let cycle = time.truncatingRemainder(dividingBy: 5.0) / 5.0
            let jojoX = width * (0.52 + 0.045 * sin(time * 1.8))
            let jojoY = height * (0.65 + 0.010 * sin(time * 2.4))
            let throwProgress = min(max((cycle - 0.28) / 0.34, 0), 1)
            let buoyStartX = width * 0.38
            let buoyStartY = height * 0.77
            let buoyX = buoyStartX + (jojoX - buoyStartX) * CGFloat(throwProgress)
            let buoyY = buoyStartY + (jojoY - buoyStartY) * CGFloat(throwProgress)

            ZStack {
                Image("save_jojo_onboarding")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()

                onboardingCopy(width: width, height: height)

                ZStack {
                    Image("save_jojo_ocean_back")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width * 0.52, height: height * 0.28)
                        .offset(
                            x: CGFloat(sin(time * 0.75)) * width * 0.012,
                            y: -height * 0.015
                        )
                }
                .frame(width: width * 0.48, height: height * 0.25)
                .clipped()
                .position(x: width * 0.52, y: height * 0.68)
                .allowsHitTesting(false)

                if throwProgress < 0.96 {
                    referenceSprite(
                        asset: "save_jojo_character",
                        crop: CGRect(x: 190, y: 285, width: 520, height: 650),
                        referenceSize: CGSize(width: 2622, height: 1206)
                    )
                    .frame(width: width * 0.045, height: height * 0.12)
                    .position(x: jojoX, y: jojoY)
                } else {
                    Image("save_jojo_floating")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.075, height: height * 0.15)
                        .position(x: jojoX, y: jojoY)
                }

                ZStack {
                    Image("save_jojo_ocean_middle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width * 0.52, height: height * 0.27)
                        .offset(
                            x: CGFloat(sin(time * 0.92 + 1.4)) * width * 0.014,
                            y: height * 0.025
                        )

                    Image("save_jojo_ocean_front")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width * 0.52, height: height * 0.26)
                        .offset(
                            x: CGFloat(sin(time * 1.08 + 2.7)) * width * 0.016,
                            y: height * 0.060
                        )
                }
                .frame(width: width * 0.48, height: height * 0.25)
                .clipped()
                .position(x: width * 0.52, y: height * 0.68)
                .allowsHitTesting(false)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.38, y: height * 0.80))
                    path.addLine(
                        to: CGPoint(
                            x: buoyX,
                            y: buoyY + (throwProgress < 0.96 ? width * 0.025 : height * 0.055)
                        )
                    )
                }
                .stroke(.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .allowsHitTesting(false)

                if throwProgress < 0.96 {
                    referenceSprite(
                        asset: "save_jojo_lifebuoy",
                        crop: CGRect(x: 900, y: 100, width: 960, height: 960),
                        referenceSize: CGSize(width: 2622, height: 1206)
                    )
                    .frame(width: width * 0.050, height: width * 0.050)
                    .rotationEffect(.degrees(throwProgress * 360))
                    .position(x: buoyX, y: buoyY)
                }

                ZStack {
                    referenceSprite(
                        asset: "save_jojo_button",
                        crop: CGRect(x: 875, y: 500, width: 390, height: 300),
                        referenceSize: CGSize(width: 2622, height: 1206)
                    )
                    Text("throw")
                        .font(.appFont(size: max(12, width * 0.016)))
                        .foregroundStyle(.white)
                        .offset(y: -height * 0.012)
                }
                .frame(width: width * 0.090, height: height * 0.145)
                .position(x: width * 0.69, y: height * 0.70)

                Button {
                    SoundManager.shared.play(.buttonTap)
                    game.dismissOnboarding()
                } label: {
                    Color.clear
                        .frame(width: width, height: height)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Start Save Jojo")
            }
        }
    }

    @ViewBuilder
    private func interactionLayer(width: CGFloat, height: CGFloat) -> some View {
        switch game.phase {
        case .onboarding:
            Button {
                SoundManager.shared.play(.buttonTap)
                game.dismissOnboarding()
            } label: {
                Color.clear
                    .frame(width: width, height: height)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start Save Jojo")

        case .aiming:
            EmptyView()

        case .caught:
            Color.clear.allowsHitTesting(false)

        case .pulling:
            pullingControls(width: width, height: height)

        case .rescuing:
            Color.clear.allowsHitTesting(false)

        case .won:
            Button {
                SoundManager.shared.play(.buttonTap)
                dismiss()
            } label: {
                Color.clear
                    .frame(width: width * 0.20, height: height * 0.18)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .position(x: width * 0.88, y: height * 0.08)
            .accessibilityLabel("Next")

        case .lost:
            Button {
                SoundManager.shared.play(.buttonTap)
                game.restart()
            } label: {
                Color.clear
                    .frame(width: width * 0.24, height: height * 0.18)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .position(x: width * 0.86, y: height * 0.08)
            .accessibilityLabel("Try again")
        }
    }

    private func onboardingCopy(width: CGFloat, height: CGFloat) -> some View {
        let paperCenterX = width * 0.52
        let copyWidth = width * 0.54
        let pinkLine = Color(red: 0.98, green: 0.86, blue: 0.88)

        return ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: copyWidth, height: height * 0.45)
                .position(x: paperCenterX, y: height * 0.34)

            ForEach([0.285, 0.425, 0.565], id: \.self) { y in
                Capsule()
                    .fill(pinkLine)
                    .frame(width: copyWidth * 0.90, height: max(2, height * 0.007))
                    .position(x: paperCenterX, y: height * y)
            }

            Text("SAVE JOJO")
                .font(.appFontBold(size: max(28, width * 0.052), relativeTo: .title))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .position(x: paperCenterX, y: height * 0.205)

            HStack(spacing: width * 0.007) {
                Text("Throw the lifebuoy")
                Image("save_jojo_lifebuoy_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.032, height: width * 0.032)
                Text("to JOJO")
                Image("save_jojo_floating")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.034, height: height * 0.075)
            }
            .font(.appFont(size: max(17, width * 0.026), relativeTo: .headline))
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(width: copyWidth * 0.92)
            .position(x: paperCenterX, y: height * 0.355)

            HStack(spacing: width * 0.006) {
                Text("Be careful because you only have 3×")
                Image("save_jojo_lifebuoy_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.030, height: width * 0.030)
            }
            .font(.appFont(size: max(16, width * 0.023), relativeTo: .body))
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(width: copyWidth * 0.92)
            .position(x: paperCenterX, y: height * 0.495)
        }
        .allowsHitTesting(false)
    }

    private func aimingScene(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let jojoX = oscillation(time: time, period: 4.2, lower: 0.10, upper: 0.90)
            let jojoY = height * 0.34
            let buoyX = width * 0.52
            let buoyY = height * 0.94
            let aimAngle = oscillation(time: time, period: 3.4, lower: -67, upper: 67)
            let angleRadians = aimAngle * .pi / 180
            let arrowRadius = height * 0.27
            let missedElapsed = timeline.date.timeIntervalSince(missedThrowStart ?? timeline.date)
            let isMissAnimating = missedThrowStart != nil && missedElapsed < 0.8
            let missedPhase = min(max(missedElapsed / 0.8, 0), 1)
            let missedTravel = missedPhase <= 0.65
                ? missedPhase / 0.65
                : 1 - (missedPhase - 0.65) / 0.35
            let missedRadians = missedThrowAngle * .pi / 180
            let missedDistance = height * 0.48 * CGFloat(max(0, missedTravel))
            let missedBuoyX = buoyX + CGFloat(sin(missedRadians)) * missedDistance
            let missedBuoyY = buoyY - CGFloat(cos(missedRadians)) * missedDistance
            let jojoFrame = CGRect(x: 190, y: 285, width: 520, height: 650)

            ZStack {
                Color(red: 0.65, green: 0.81, blue: 0.94)

                backWater(time: time, width: width, height: height)

                referenceSprite(
                    asset: "save_jojo_character",
                    crop: jojoFrame,
                    referenceSize: CGSize(width: 2622, height: 1206)
                )
                .frame(width: width * 0.18, height: height * 0.40)
                .position(x: width * CGFloat(jojoX), y: jojoY)

                frontWater(time: time, width: width, height: height)

                referenceSprite(
                    asset: "save_jojo_lifebuoy",
                    crop: CGRect(x: 900, y: 100, width: 960, height: 960),
                    referenceSize: CGSize(width: 2622, height: 1206)
                )
                .frame(width: width * 0.19, height: width * 0.19)
                .position(x: buoyX, y: buoyY)
                .opacity(isMissAnimating ? 0 : 1)

                Image(systemName: "arrow.up")
                    .font(.system(size: max(30, width * 0.055), weight: .black))
                    .foregroundStyle(.yellow)
                    .shadow(color: .black.opacity(0.7), radius: 0, x: 3, y: 3)
                    .rotationEffect(.degrees(aimAngle))
                    .position(
                        x: buoyX + CGFloat(sin(angleRadians)) * arrowRadius,
                        y: buoyY - CGFloat(cos(angleRadians)) * arrowRadius
                    )
                    .opacity(isMissAnimating ? 0 : 1)

                if isMissAnimating {
                    Path { path in
                        path.move(to: CGPoint(x: buoyX, y: height * 1.08))
                        path.addLine(
                            to: CGPoint(
                                x: missedBuoyX,
                                y: missedBuoyY + width * 0.095
                            )
                        )
                    }
                    .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .allowsHitTesting(false)

                    referenceSprite(
                        asset: "save_jojo_lifebuoy",
                        crop: CGRect(x: 900, y: 100, width: 960, height: 960),
                        referenceSize: CGSize(width: 2622, height: 1206)
                    )
                    .frame(width: width * 0.19, height: width * 0.19)
                    .rotationEffect(.degrees(missedTravel * 420))
                    .position(x: missedBuoyX, y: missedBuoyY)
                }

                livesDisplay(width: width, height: height)

                Button {
                    guard !isMissAnimating else { return }
                    let targetAngle = atan2(
                        Double(width * CGFloat(jojoX) - buoyX),
                        Double(buoyY - jojoY)
                    ) * 180 / .pi
                    let angularError = abs(aimAngle - targetAngle) / 100
                    let success = game.throwLifebuoy(
                        alignmentError: angularError,
                        deferLoss: true
                    )
                    SoundManager.shared.play(success ? .itemPickup : .itemRemove)
                    flash(success ? .green.opacity(0.20) : .red.opacity(0.24))
                    guard success else {
                        SoundManager.shared.playVoiceOver(.cry)
                        missedThrowAngle = aimAngle
                        missedThrowStart = Date()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            missedThrowStart = nil
                            game.finishFailedThrow()
                        }
                        return
                    }
                    caughtJojoX = jojoX
                    caughtTransitionStart = Date()
                    resetPullMechanic()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        guard game.phase == .caught else { return }
                        pullAnimationStart = Date()
                        game.beginPulling()
                    }
                } label: {
                    ZStack {
                        referenceSprite(
                            asset: "save_jojo_button",
                            crop: CGRect(x: 875, y: 500, width: 390, height: 300),
                            referenceSize: CGSize(width: 2622, height: 1206)
                        )

                        Text("throw")
                            .font(.appFont(size: max(25, width * 0.038)))
                            .foregroundStyle(.white)
                            .offset(y: -height * 0.028)
                    }
                    .frame(width: width * 0.17, height: height * 0.30)
                }
                .buttonStyle(.plain)
                .position(x: width * 0.87, y: height * 0.77)
                .accessibilityLabel("Throw lifebuoy")
                .accessibilityHint("Throw when the arrow is aligned with Jojo")
            }
        }
    }

    private func backWater(time: TimeInterval, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            WaterWave(phase: time * 0.42, amplitude: height * 0.055, frequency: 2.8)
                .fill(Color(red: 0.33, green: 0.68, blue: 0.91))
                .overlay {
                    WaterWave(phase: time * 0.42, amplitude: height * 0.055, frequency: 2.8)
                        .stroke(Color(red: 0.60, green: 0.80, blue: 0.94), lineWidth: 7)
                }
                .frame(width: width * 1.08, height: height * 0.82)
                .position(x: width * 0.50, y: height * 0.55)

        }
        .allowsHitTesting(false)
    }

    private func caughtTransitionScene(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let elapsed = timeline.date.timeIntervalSince(caughtTransitionStart ?? timeline.date)
            let progress = min(max(elapsed / 1.2, 0), 1)
            let throwProgress = min(progress / 0.55, 1)
            let pullProgress = min(max((progress - 0.62) / 0.38, 0), 1)
            let easedThrow = 1 - pow(1 - throwProgress, 3)
            let easedPull = pullProgress * pullProgress * (3 - 2 * pullProgress)

            let startX = width * 0.52
            let startY = height * 0.94
            let hitX = width * CGFloat(caughtJojoX)
            let hitY = height * 0.34
            let settledX = width * 0.43
            let settledY = height * 0.31
            let caughtX = hitX + (settledX - hitX) * CGFloat(easedPull)
            let caughtY = hitY + (settledY - hitY) * CGFloat(easedPull)
            let buoyX = startX + (hitX - startX) * CGFloat(easedThrow)
            let buoyY = startY + (hitY - startY) * CGFloat(easedThrow)
            let isCaught = progress >= 0.55

            ZStack {
                Color(red: 0.65, green: 0.81, blue: 0.94)
                backWater(time: time, width: width, height: height)

                referenceSprite(
                    asset: "save_jojo_character",
                    crop: CGRect(x: 190, y: 285, width: 520, height: 650),
                    referenceSize: CGSize(width: 2622, height: 1206)
                )
                .frame(width: width * 0.18, height: height * 0.40)
                .position(x: hitX, y: hitY)
                .opacity(isCaught ? max(0, 1 - (progress - 0.55) / 0.10) : 1)

                Image("save_jojo_floating")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.22, height: height * 0.43)
                    .position(x: caughtX, y: caughtY)
                    .scaleEffect(isCaught ? 1 : 0.78)
                    .opacity(isCaught ? min(1, (progress - 0.55) / 0.10) : 0)

                frontWater(time: time, width: width, height: height)

                Path { path in
                    path.move(to: CGPoint(x: startX, y: height * 1.08))
                    path.addLine(
                        to: CGPoint(
                            x: isCaught ? caughtX : buoyX,
                            y: isCaught
                                ? caughtY + height * 0.17
                                : buoyY + width * 0.095
                        )
                    )
                }
                .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .allowsHitTesting(false)

                if !isCaught {
                    referenceSprite(
                        asset: "save_jojo_lifebuoy",
                        crop: CGRect(x: 900, y: 100, width: 960, height: 960),
                        referenceSize: CGSize(width: 2622, height: 1206)
                    )
                    .frame(width: width * 0.19, height: width * 0.19)
                    .rotationEffect(.degrees(throwProgress * 540))
                    .position(x: buoyX, y: buoyY)
                }

                livesDisplay(width: width, height: height)
            }
        }
    }

    private func frontWater(time: TimeInterval, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            WaterWave(phase: -time * 0.55, amplitude: height * 0.06, frequency: 2.4)
                .fill(Color(red: 0.05, green: 0.53, blue: 0.91))
                .overlay {
                    WaterWave(phase: -time * 0.55, amplitude: height * 0.06, frequency: 2.4)
                        .stroke(Color(red: 0.24, green: 0.67, blue: 0.94), lineWidth: 7)
                }
                .frame(width: width * 1.08, height: height * 0.62)
                .position(x: width * 0.50, y: height * 0.72)

            WaterWave(phase: time * 0.68, amplitude: height * 0.05, frequency: 2.6)
                .fill(Color(red: 0.02, green: 0.38, blue: 0.72))
                .overlay {
                    WaterWave(phase: time * 0.68, amplitude: height * 0.05, frequency: 2.6)
                        .stroke(Color(red: 0.18, green: 0.57, blue: 0.84), lineWidth: 7)
                }
                .frame(width: width * 1.08, height: height * 0.37)
                .position(x: width * 0.50, y: height * 0.90)
        }
            .allowsHitTesting(false)
    }

    private func oscillation(
        time: TimeInterval,
        period: TimeInterval,
        lower: Double,
        upper: Double
    ) -> Double {
        let normalized = (sin(time * 2 * .pi / period) + 1) / 2
        return lower + normalized * (upper - lower)
    }

    private func referenceSprite(
        asset: String,
        crop: CGRect,
        referenceSize: CGSize
    ) -> some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / crop.width
            Image(asset)
                .resizable()
                .frame(
                    width: referenceSize.width * scale,
                    height: referenceSize.height * scale
                )
                .offset(x: -crop.minX * scale, y: -crop.minY * scale)
        }
        .clipped()
    }

    private func pullingControls(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let jojoPosition = markerPosition(at: timeline.date)

            ZStack {
                livesDisplay(width: width, height: height)
                fishingMeter(
                    jojoPosition: jojoPosition,
                    width: width,
                    height: height
                )

                ZStack {
                    referenceSprite(
                        asset: "save_jojo_button",
                        crop: CGRect(x: 875, y: 500, width: 390, height: 300),
                        referenceSize: CGSize(width: 2622, height: 1206)
                    )

                    Text("pull")
                        .font(.appFont(size: max(25, width * 0.038)))
                        .foregroundStyle(.white)
                        .offset(y: -height * 0.028)
                }
                    .frame(width: width * 0.17, height: height * 0.30)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in pullHeld = true }
                            .onEnded { _ in pullHeld = false }
                    )
                .position(x: width * 0.87, y: height * 0.78)
                .accessibilityLabel("Pull Jojo")
                .accessibilityHint("Hold to raise the catch bar and release to lower it")
            }
        }
    }

    private func pullingScene(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let pullElapsed = timeline.date.timeIntervalSince(pullAnimationStart)
            let floatX = CGFloat(sin(pullElapsed * 0.85)) * width * 0.045
            let floatY = CGFloat(sin(pullElapsed * 1.35)) * height * 0.025
            let centerX = width * 0.43 + floatX
            let centerY = height * 0.31 + floatY

            ZStack {
                Color(red: 0.65, green: 0.81, blue: 0.94)
                backWater(time: time, width: width, height: height)

                Image("save_jojo_floating")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.22, height: height * 0.43)
                .position(x: centerX, y: centerY)

                frontWater(time: time, width: width, height: height)

                Path { path in
                    path.move(
                        to: CGPoint(
                            x: centerX,
                            y: centerY + height * 0.17
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: width * 0.52,
                            y: height * 1.10
                        )
                    )
                }
                .stroke(
                    .white,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .shadow(color: .black.opacity(0.12), radius: 1, x: 1, y: 1)
                .allowsHitTesting(false)

                pullingControls(width: width, height: height)
            }
        }
    }

    private func rescueTransitionScene(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let elapsed = timeline.date.timeIntervalSince(rescueTransitionStart ?? timeline.date)
            let progress = min(max(elapsed / 1.5, 0), 1)
            let eased = progress * progress * (3 - 2 * progress)
            let startX = width * CGFloat(rescueStartX)
            let startY = height * CGFloat(rescueStartY)
            let endX = width * 0.52
            let endY = height * 0.78
            let swing = CGFloat(sin(progress * .pi)) * width * 0.025
            let jojoX = startX + (endX - startX) * CGFloat(eased) + swing
            let jojoY = startY + (endY - startY) * CGFloat(eased)
            let scale = 1 - CGFloat(eased) * 0.18

            ZStack {
                Color(red: 0.65, green: 0.81, blue: 0.94)
                backWater(time: time, width: width, height: height)

                frontWater(time: time, width: width, height: height)

                Path { path in
                    path.move(to: CGPoint(x: endX, y: height * 1.06))
                    path.addLine(
                        to: CGPoint(
                            x: jojoX,
                            y: jojoY + height * 0.17 * scale
                        )
                    )
                }
                .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .allowsHitTesting(false)

                Image("save_jojo_floating")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.22, height: height * 0.43)
                    .scaleEffect(scale)
                    .rotationEffect(
                        .degrees(sin(progress * .pi * 2) * 3 * (1 - progress))
                    )
                    .position(x: jojoX, y: jojoY)

                livesDisplay(width: width, height: height)
            }
        }
    }

    private func fishingMeter(
        jojoPosition: Double,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let meterHeight = height * 0.68
        let meterTop = height * 0.15
        let jojoY = meterTop + CGFloat(jojoPosition) * meterHeight
        let catchBarY = meterTop + CGFloat(catchBarPosition) * meterHeight
        let catchBarHeight = meterHeight * 0.20
        let progressHeight = meterHeight * CGFloat(rescueProgress)

        return ZStack {
            Image("save_jojo_meter_wide")
                .resizable()
                .frame(width: width * 0.050, height: meterHeight)
                .position(x: width * 0.169, y: meterTop + meterHeight / 2)

            Image("save_jojo_meter_track")
                .resizable()
                .frame(width: width * 0.022, height: meterHeight)
                .position(x: width * 0.121, y: meterTop + meterHeight / 2)

            RoundedRectangle(cornerRadius: 7)
                .fill(Color(red: 0.14, green: 0.92, blue: 0.57).opacity(0.88))
                .frame(width: width * 0.043, height: catchBarHeight)
                .position(x: width * 0.169, y: catchBarY)

            Image("save_jojo_meter_fill")
                .resizable()
                .frame(width: width * 0.011, height: progressHeight)
                .position(
                    x: width * 0.121,
                    y: meterTop + meterHeight - progressHeight / 2
                )

            Image("save_jojo_meter_marker")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.045, height: height * 0.12)
            .position(x: width * 0.169, y: jojoY)
        }
    }

    private func updatePullMechanic(at date: Date) {
        guard game.phase == .pulling else {
            lastPullTick = nil
            pullHeld = false
            return
        }

        guard let previousTick = lastPullTick else {
            lastPullTick = date
            return
        }

        let delta = min(max(date.timeIntervalSince(previousTick), 0), 0.05)
        lastPullTick = date
        failureCooldown = max(0, failureCooldown - delta)

        catchBarVelocity += (pullHeld ? -2.35 : 1.75) * delta
        catchBarVelocity *= pow(0.055, delta)
        catchBarPosition += catchBarVelocity * delta

        if catchBarPosition < 0.14 {
            catchBarPosition = 0.14
            catchBarVelocity = max(0, catchBarVelocity * -0.25)
        } else if catchBarPosition > 0.86 {
            catchBarPosition = 0.86
            catchBarVelocity = min(0, catchBarVelocity * -0.25)
        }

        let jojoPosition = markerPosition(at: date)
        let jojoInsideBar = abs(jojoPosition - catchBarPosition) <= 0.14
        rescueProgress += (jojoInsideBar ? 0.30 : -0.20) * delta
        rescueProgress = min(max(rescueProgress, 0), 1)

        if rescueProgress >= 1 {
            pullHeld = false
            SoundManager.shared.play(.itemPickup)
            flash(.green.opacity(0.20))
            let pullElapsed = date.timeIntervalSince(pullAnimationStart)
            rescueStartX = 0.43 + sin(pullElapsed * 0.85) * 0.045
            rescueStartY = 0.31 + sin(pullElapsed * 1.35) * 0.025
            rescueTransitionStart = date
            game.beginRescueTransition()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard game.phase == .rescuing else { return }
                game.completeRescue()
            }
        } else if rescueProgress <= 0, failureCooldown <= 0 {
            SoundManager.shared.play(.itemRemove)
            SoundManager.shared.playVoiceOver(.cry)
            flash(.red.opacity(0.24))
            game.failPullAttempt()
            rescueProgress = 0.25
            failureCooldown = 0.8
        }
    }

    private func resetPullMechanic() {
        pullHeld = false
        catchBarPosition = 0.62
        catchBarVelocity = 0
        rescueProgress = 0.25
        lastPullTick = nil
        failureCooldown = 0
    }

    private func livesDisplay(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: width * 0.008) {
            Text("\(game.lives)×")
                .font(.system(size: max(20, width * 0.033), weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Image("save_jojo_lifebuoy_icon")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.045, height: height * 0.10)
        }
            .frame(width: width * 0.17, height: height * 0.13)
            .background(Color(red: 0.66, green: 0.81, blue: 0.93))
            .position(x: width * 0.90, y: height * 0.07)
    }

    private func markerPosition(at date: Date) -> Double {
        let duration = 4.5
        let cycle = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration)
        let progress = cycle / duration
        return progress <= 0.5 ? progress * 2 : (1 - progress) * 2
    }

    private func flash(_ color: Color) {
        feedbackColor = color
        withAnimation(.easeOut(duration: 0.25)) {
            feedbackColor = .clear
        }
    }
}

private struct WaterWave: Shape {
    var phase: Double
    var amplitude: CGFloat
    var frequency: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: amplitude))
        let steps = max(Int(rect.width / 4), 1)
        for step in 0...steps {
            let x = rect.width * CGFloat(step) / CGFloat(steps)
            let angle = Double(x / rect.width) * frequency * 2 * .pi + phase
            let y = amplitude + CGFloat(sin(angle)) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SaveJojoMiniGameView()
}
