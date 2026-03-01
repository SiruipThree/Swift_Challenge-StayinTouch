import SwiftUI
import simd

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0
    @State private var opacity: Double = 0
    @State private var page2LineVisible: [Bool] = Array(repeating: false, count: 5)
    @State private var page3LineVisible: [Bool] = Array(repeating: false, count: 4)
    @State private var page3IconScale: [CGFloat] = [0.01, 0.01, 0.01]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentPage) {
                onboardingPage1.tag(0)
                onboardingPage2.tag(1)
                onboardingPage3.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            VStack {
                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.stAccent : Color.white.opacity(0.2))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                Button {
                    if currentPage < 2 {
                        withAnimation(.spring(response: 0.4)) { currentPage += 1 }
                    } else {
                        withAnimation(.easeOut(duration: 0.4)) { opacity = 0 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onComplete() }
                    }
                } label: {
                    Text(currentPage < 2 ? "Continue" : "Enter")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.stAccent)
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 12)

                if currentPage < 2 {
                    Button("Skip") {
                        withAnimation(.easeOut(duration: 0.4)) { opacity = 0 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onComplete() }
                    }
                    .font(.callout)
                    .foregroundStyle(.stSecondaryText)
                }

                Spacer().frame(height: 28)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { opacity = 1 }
        }
    }

    // MARK: - Page 1: Distance

    private var onboardingPage1: some View {
        let screenH = UIScreen.main.bounds.height
        let globeH = screenH * 0.68

        return ZStack(alignment: .top) {
            starsBackground

            GlobeView(
                fromCoordinate: MockDataProvider.me.location,
                toCoordinate: MockDataProvider.mom.location,
                distanceMiles: MockDataProvider.me.location.distanceInMiles(to: MockDataProvider.mom.location),
                daysApart: MockDataProvider.mom.daysApart,
                zoom: 2.0,
                userRotation: simd_quatf(angle: -0.40, axis: SIMD3<Float>(1, 0, 0)),
                baseMode: .pair,
                routeRevealProgress: 1.0,
                contactAvatar: MockDataProvider.mom.avatarEmoji
            )
            .frame(width: UIScreen.main.bounds.width, height: globeH)
            .offset(y: -screenH * 0.06)
            .allowsHitTesting(false)

            LinearGradient(
                colors: [.clear, .black.opacity(0.6), .black],
                startPoint: .init(x: 0.5, y: 0.45),
                endPoint: .init(x: 0.5, y: 0.72)
            )
            .frame(height: globeH)
            .offset(y: -screenH * 0.06)
            .allowsHitTesting(false)

            VStack(spacing: 18) {
                Spacer()

                Text("8,014 miles  ·  562 days apart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.stAccent)

                Text("When was the last day\nyou saw the people you love?")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.stPrimaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 36)

                Spacer().frame(height: screenH * 0.16)
            }
        }
    }

    // MARK: - Page 2: Care

    private var onboardingPage2: some View {
        ZStack {
            starsBackground

            VStack(spacing: 0) {
                Spacer()

                page2Line(index: 0) {
                    VStack(spacing: 4) {
                        Text("My mom worries")
                        Text("about me.")
                    }
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                }

                Spacer().frame(height: 30)

                page2Line(index: 1) {
                    VStack(spacing: 4) {
                        Text("I worry")
                        Text("about her.")
                    }
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                }

                Spacer().frame(height: 36)

                page2Line(index: 2) {
                    VStack(spacing: 4) {
                        Text("We both care.")
                            .foregroundStyle(.white.opacity(0.75))
                        Text("Every single day.")
                            .foregroundStyle(.stAccent)
                    }
                    .font(.system(size: 22, weight: .semibold))
                }

                Spacer().frame(height: 48)

                page2Line(index: 3) {
                    Text("But when did we\nlast really talk?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.stPrimaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }

                Spacer()
                Spacer()
            }
            .multilineTextAlignment(.center)
        }
        .onChange(of: currentPage) { _, newPage in
            if newPage == 1 { startPage2Animation() }
            if newPage != 1 { resetPage2Animation() }
        }
    }

    private func page2Line<Content: View>(index: Int, @ViewBuilder content: () -> Content) -> some View {
        content()
            .opacity(page2LineVisible[index] ? 1 : 0)
            .offset(y: page2LineVisible[index] ? 0 : 14)
            .animation(.easeOut(duration: 0.7), value: page2LineVisible[index])
    }

    private func startPage2Animation() {
        let delays: [Double] = [0.3, 0.9, 1.5, 2.2]
        for i in 0..<delays.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + delays[i]) {
                page2LineVisible[i] = true
            }
        }
    }

    private func resetPage2Animation() {
        for i in 0..<page2LineVisible.count { page2LineVisible[i] = false }
    }

    // MARK: - Page 3: Solution

    private var onboardingPage3: some View {
        ZStack {
            starsBackground

            VStack(spacing: 0) {
                Spacer()

                HStack(spacing: 24) {
                    featureIcon(index: 0, symbol: "face.smiling.inverse", label: "Mood", color: Color.stMoodBlue)
                    featureIcon(index: 1, symbol: "heart.fill", label: "Heart", color: Color.stHeartRed)
                    featureIcon(index: 2, symbol: "figure.run", label: "Activity", color: Color.stExerciseRing)
                }

                Spacer().frame(height: 16)

                page3Line(index: 1) {
                    Text("One look. And you know they're okay.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.40))
                }

                Spacer().frame(height: 52)

                page3Line(index: 2) {
                    VStack(spacing: 6) {
                        Text("Miles apart.")
                            .foregroundStyle(.white.opacity(0.50))
                        Text("Right beside you.")
                            .foregroundStyle(.stPrimaryText)
                    }
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                }

                Spacer()
                Spacer()
            }
            .multilineTextAlignment(.center)
        }
        .onChange(of: currentPage) { _, newPage in
            if newPage == 2 { startPage3Animation() }
            if newPage != 2 { resetPage3Animation() }
        }
    }

    private func featureIcon(index: Int, symbol: String, label: String, color: Color) -> some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(color.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(color.opacity(0.3), lineWidth: 0.5)
                    )
                    .frame(width: 82, height: 82)

                Image(systemName: symbol)
                    .font(.system(size: 32))
                    .foregroundStyle(color)
            }
            .scaleEffect(page3IconScale[index])
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: page3IconScale[index])

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.stSecondaryText)
                .opacity(page3IconScale[index] > 0.5 ? 1 : 0)
                .animation(.easeOut(duration: 0.3), value: page3IconScale[index])
        }
    }

    private func page3Line<Content: View>(index: Int, @ViewBuilder content: () -> Content) -> some View {
        content()
            .opacity(page3LineVisible[index] ? 1 : 0)
            .offset(y: page3LineVisible[index] ? 0 : 14)
            .animation(.easeOut(duration: 0.7), value: page3LineVisible[index])
    }

    private func startPage3Animation() {
        let iconDelays: [Double] = [0.3, 0.55, 0.8]
        for i in 0..<iconDelays.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + iconDelays[i]) {
                page3IconScale[i] = 1.0
            }
        }
        let textDelays: [Double] = [1.3, 2.0]
        for i in 0..<textDelays.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + textDelays[i]) {
                page3LineVisible[i + 1] = true
            }
        }
    }

    private func resetPage3Animation() {
        for i in 0..<page3LineVisible.count { page3LineVisible[i] = false }
        for i in 0..<page3IconScale.count { page3IconScale[i] = 0.01 }
    }

    // MARK: - Stars Background

    private var starsBackground: some View {
        Canvas { context, size in
            let starCount = 120
            var rng = SeededRandomNumberGenerator(seed: 42)
            for _ in 0..<starCount {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let radius = CGFloat.random(in: 0.4...1.4, using: &rng)
                let alpha = CGFloat.random(in: 0.15...0.7, using: &rng)
                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(alpha)))
            }
        }
        .ignoresSafeArea()
    }
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
