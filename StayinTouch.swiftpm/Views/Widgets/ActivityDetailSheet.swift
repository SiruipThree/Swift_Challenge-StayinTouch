import SwiftUI

// MARK: - Trend line shape (smooth bezier through 7 points)

private struct TrendLineShape: Shape {
    let values: [CGFloat]

    func path(in rect: CGRect) -> Path {
        guard values.count >= 2 else { return Path() }
        let n = values.count
        let minV = (values.min() ?? 0) * 0.92
        let maxV = (values.max() ?? 1) * 1.04
        let range = max(maxV - minV, 1)
        let xStep = rect.width / CGFloat(n - 1)

        func pt(_ i: Int) -> CGPoint {
            let x = CGFloat(i) * xStep
            let y = rect.height * (1 - (values[i] - minV) / range)
            return CGPoint(x: x, y: y)
        }

        var path = Path()
        path.move(to: pt(0))
        for i in 1..<n {
            let prev = pt(i - 1)
            let curr = pt(i)
            let cx   = (prev.x + curr.x) / 2
            path.addCurve(to: curr,
                          control1: CGPoint(x: cx, y: prev.y),
                          control2: CGPoint(x: cx, y: curr.y))
        }
        return path
    }
}

// MARK: - ActivityDetailSheet

struct ActivityDetailSheet: View {
    let activity: ActivitySnapshot?

    // Animation states
    @State private var moveBarProgress: CGFloat   = 0
    @State private var exerciseProgress: CGFloat  = 0
    @State private var standDotsShown: Int        = 0
    @State private var trendLineProgress: CGFloat = 0

    private var trendValues: [CGFloat] {
        guard let a = activity, !a.weeklyMoveTrend.isEmpty else {
            return [300, 340, 360, 320, 400, 370, 380]
        }
        return a.weeklyMoveTrend.map { CGFloat($0) }
    }

    private let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header ─────────────────────────────────────────────
            HStack(alignment: .firstTextBaseline) {
                Text("Daily Activity")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                Text("Today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 20)

            // ── Three metric cards ──────────────────────────────────
            HStack(spacing: 10) {
                moveCard
                exerciseCard
                standCard
            }
            .padding(.horizontal, 16)

            // ── 7-day trend ────────────────────────────────────────
            trendCard
                .padding(.horizontal, 16)
                .padding(.top, 14)

            Text("Demo data only — not connected to real health sensors")
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .presentationDetents([.medium])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(28)
        .onAppear { triggerAnimations() }
    }

    // MARK: Move card

    private var moveCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Move")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text(activity != nil ? "\(activity!.moveCalories)" : "—")
                .font(.title3).fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("kcal")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, -6)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.stMoveRing.opacity(0.18))
                        .frame(height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.stMoveRing)
                        .frame(width: geo.size.width * moveBarProgress, height: 7)
                }
            }
            .frame(height: 7)

            if let a = activity {
                Text("\(Int(a.moveProgress * 100))% of goal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.07))
        )
    }

    // MARK: Exercise card

    private var exerciseCard: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Exercise")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.stExerciseRing.opacity(0.18), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: exerciseProgress)
                    .stroke(
                        Color.stExerciseRing,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 58, height: 58)

            if let a = activity {
                Text("\(a.exerciseMinutes) min")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.07))
        )
    }

    // MARK: Stand card (dot grid)

    private var standCard: some View {
        let goal = activity?.standGoal ?? 12
        let cols = 3
        let rows  = Int(ceil(Double(goal) / Double(cols)))

        return VStack(alignment: .leading, spacing: 6) {
            Text("Stand")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            // Dot grid
            VStack(spacing: 5) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<cols, id: \.self) { col in
                            let idx = row * cols + col
                            if idx < goal {
                                Circle()
                                    .fill(idx < standDotsShown
                                          ? Color.stStandRing
                                          : Color.stStandRing.opacity(0.15))
                                    .frame(width: 9, height: 9)
                                    .scaleEffect(idx < standDotsShown ? 1.0 : 0.7)
                                    .animation(
                                        .spring(response: 0.3, dampingFraction: 0.6)
                                        .delay(Double(idx) * 0.07),
                                        value: standDotsShown
                                    )
                            }
                        }
                    }
                }
            }

            if let a = activity {
                Text("\(a.standHours) hrs")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.07))
        )
    }

    // MARK: Trend chart

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("7-day trend")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.primary)

            ZStack(alignment: .bottomLeading) {
                // Shaded fill under the line
                TrendFillShape(values: trendValues)
                    .fill(
                        LinearGradient(
                            colors: [Color.stAccent.opacity(0.22), Color.stAccent.opacity(0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .opacity(Double(trendLineProgress))

                // Line
                TrendLineShape(values: trendValues)
                    .trim(from: 0, to: trendLineProgress)
                    .stroke(
                        Color.stAccent,
                        style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
                    )
            }
            .frame(height: 70)
            .clipped()

            // Day labels
            HStack {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                    if label != dayLabels.last { Spacer() }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.07))
        )
    }

    // MARK: Animation trigger

    private func triggerAnimations() {
        guard let a = activity else { return }

        // Move bar
        withAnimation(.easeInOut(duration: 1.2).delay(0.1)) {
            moveBarProgress = CGFloat(min(a.moveProgress, 1.0))
        }
        // Exercise ring
        withAnimation(.easeInOut(duration: 1.4).delay(0.2)) {
            exerciseProgress = CGFloat(min(a.exerciseProgress, 1.0))
        }
        // Stand dots — animate count up
        let target = a.standHours
        for i in 1...max(target, 1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(i) * 0.07) {
                standDotsShown = i
            }
        }
        // Trend line
        withAnimation(.easeInOut(duration: 1.6).delay(0.4)) {
            trendLineProgress = 1.0
        }
    }
}

// MARK: - Shaded fill shape under trend line

private struct TrendFillShape: Shape {
    let values: [CGFloat]

    func path(in rect: CGRect) -> Path {
        guard values.count >= 2 else { return Path() }
        let n = values.count
        let minV  = (values.min() ?? 0) * 0.92
        let maxV  = (values.max() ?? 1) * 1.04
        let range = max(maxV - minV, 1)
        let xStep = rect.width / CGFloat(n - 1)

        func pt(_ i: Int) -> CGPoint {
            CGPoint(
                x: CGFloat(i) * xStep,
                y: rect.height * (1 - (values[i] - minV) / range)
            )
        }

        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: pt(0))
        for i in 1..<n {
            let prev = pt(i - 1)
            let curr = pt(i)
            let cx   = (prev.x + curr.x) / 2
            path.addCurve(to: curr,
                          control1: CGPoint(x: cx, y: prev.y),
                          control2: CGPoint(x: cx, y: curr.y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}
