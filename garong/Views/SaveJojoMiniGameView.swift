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
                if game.phase == .aiming {
                    aimingScene(width: width, height: height)
                } else if game.phase == .pulling {
                    pullingScene(width: width, height: height)
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
    }

    private var backgroundImage: Image {
        switch game.phase {
        case .onboarding: Image("save_jojo_onboarding")
        case .aiming: Image("save_jojo_aim")
        case .caught: Image("save_jojo_caught")
        case .pulling: Image("save_jojo_pull")
        case .won: Image("save_jojo_win")
        case .lost: Image("save_jojo_lose")
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

    private func aimingScene(width: CGFloat, height: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let jojoX = oscillation(time: time, period: 3.1, lower: 0.30, upper: 0.70)
            let jojoY = height * 0.34
            let buoyX = width * 0.52
            let buoyY = height * 0.94
            let aimAngle = oscillation(time: time, period: 2.2, lower: -52, upper: 52)
            let angleRadians = aimAngle * .pi / 180
            let arrowRadius = height * 0.27
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

                Image(systemName: "arrow.up")
                    .font(.system(size: max(30, width * 0.055), weight: .black))
                    .foregroundStyle(.yellow)
                    .shadow(color: .black.opacity(0.7), radius: 0, x: 3, y: 3)
                    .rotationEffect(.degrees(aimAngle))
                    .position(
                        x: buoyX + CGFloat(sin(angleRadians)) * arrowRadius,
                        y: buoyY - CGFloat(cos(angleRadians)) * arrowRadius
                    )

                livesDisplay(width: width, height: height)

                Button {
                    let targetAngle = atan2(
                        Double(width * CGFloat(jojoX) - buoyX),
                        Double(buoyY - jojoY)
                    ) * 180 / .pi
                    let angularError = abs(aimAngle - targetAngle) / 100
                    let success = game.throwLifebuoy(alignmentError: angularError)
                    SoundManager.shared.play(success ? .itemPickup : .itemRemove)
                    flash(success ? .green.opacity(0.20) : .red.opacity(0.24))
                    guard success else { return }
                    resetPullMechanic()
                    game.beginPulling()
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
            let floatX = CGFloat(sin(time * 0.85)) * width * 0.045
            let floatY = CGFloat(sin(time * 1.35)) * height * 0.025
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
                            y: centerY + height * 0.10
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
            game.completeRescue()
        } else if rescueProgress <= 0, failureCooldown <= 0 {
            SoundManager.shared.play(.itemRemove)
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
        Text("\(game.lives)× 🛟")
            .font(.system(size: max(20, width * 0.033), weight: .bold, design: .rounded))
            .foregroundStyle(.black)
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
