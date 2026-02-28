import SwiftUI

// MARK: - ECG waveform shape (2 QRS cycles)

private struct ECGShape: Shape {
    func path(in rect: CGRect) -> Path {
        let W = rect.width
        let H = rect.height
        let base = H * 0.60   // baseline y

        // All (x fraction, y) pairs — two QRS + T-wave cycles
        let pts: [(CGFloat, CGFloat)] = [
            (0.00, base),
            (0.05, base),
            (0.09, base - H * 0.14),   // P wave
            (0.13, base),
            (0.16, base),
            (0.19, base + H * 0.14),   // Q (small dip)
            (0.22, H * 0.04),          // R (tall spike)
            (0.24, base + H * 0.28),   // S
            (0.27, base),
            (0.34, base),
            (0.42, base - H * 0.18),   // T wave
            (0.52, base),
            (0.56, base),
            (0.59, base + H * 0.12),   // Q2
            (0.62, H * 0.06),          // R2
            (0.64, base + H * 0.24),   // S2
            (0.67, base),
            (0.74, base),
            (0.82, base - H * 0.16),   // T wave 2
            (0.92, base),
            (1.00, base),
        ]

        var path = Path()
        path.move(to: CGPoint(x: pts[0].0 * W, y: pts[0].1))
        for p in pts.dropFirst() {
            path.addLine(to: CGPoint(x: p.0 * W, y: p.1))
        }
        return path
    }
}

// MARK: - HeartWidget

struct HeartWidget: View {
    let health: HealthSnapshot?
    let contactName: String

    @State private var heartScale: CGFloat = 1.0
    @State private var waveProgress: CGFloat = 0

    var body: some View {
        GlassCard(fillsHeight: true) {
            VStack(alignment: .leading, spacing: 8) {
                // Header row
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color(red: 1.0, green: 0.27, blue: 0.38))
                        .font(.title2)
                        .scaleEffect(heartScale)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Heart")
                            .font(.caption)
                            .foregroundStyle(.stSecondaryText)
                        Text(health?.heartStatus.rawValue ?? "Unknown")
                            .font(.caption2)
                            .foregroundStyle(.stSecondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))
                }

                // BPM value
                if let health {
                    Text("\(health.heartRate) BPM")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.stPrimaryText)
                }

                // ECG waveform
                ECGShape()
                    .trim(from: 0, to: waveProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.27, blue: 0.38).opacity(0.35),
                                Color(red: 1.0, green: 0.27, blue: 0.38).opacity(0.90),
                                Color(red: 1.0, green: 0.27, blue: 0.38).opacity(0.55),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
                    )
                    .frame(height: 24)
                    .clipped()

                Spacer(minLength: 0)
            }
        }
        // Re-run animation whenever the displayed contact changes
        .task(id: contactName) {
            waveProgress = 0
            try? await Task.sleep(for: .milliseconds(80))
            withAnimation(.easeInOut(duration: 1.6)) {
                waveProgress = 1
            }
        }
    }
}
