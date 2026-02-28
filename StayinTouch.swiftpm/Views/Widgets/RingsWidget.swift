import SwiftUI

struct RingsWidget: View {
    let activity: ActivitySnapshot?

    @State private var barProgress: [CGFloat] = [0, 0, 0]

    // Unique key so onChange fires when switching contacts (all three values combined)
    private var activityKey: String {
        guard let a = activity else { return "nil" }
        return "\(a.moveCalories)-\(a.exerciseMinutes)-\(a.standHours)"
    }

    private struct RowData {
        let icon: String
        let iconColor: Color
        let label: String   // Apple ring name: Move / Exercise / Stand
        let unit: String    // value unit: cal / min / hrs
        let value: Int
        let trackColor: Color
        let fillColor: Color
    }

    private var rows: [RowData] {
        guard let a = activity else { return [] }
        return [
            RowData(icon: "flame.fill",   iconColor: .stMoveRing,
                    label: "Move",     unit: "cal", value: a.moveCalories,
                    trackColor: .stMoveRing.opacity(0.18),     fillColor: .stMoveRing),
            RowData(icon: "figure.run",    iconColor: .stExerciseRing,
                    label: "Exercise", unit: "min", value: a.exerciseMinutes,
                    trackColor: .stExerciseRing.opacity(0.18), fillColor: .stExerciseRing),
            RowData(icon: "figure.stand", iconColor: .stStandRing,
                    label: "Stand",    unit: "hrs", value: a.standHours,
                    trackColor: .stStandRing.opacity(0.18),    fillColor: .stStandRing),
        ]
    }

    private var targetProgress: [CGFloat] {
        guard let a = activity else { return [0, 0, 0] }
        return [
            CGFloat(min(a.moveProgress,     1.0)),
            CGFloat(min(a.exerciseProgress, 1.0)),
            CGFloat(min(a.standProgress,    1.0)),
        ]
    }

    var body: some View {
        GlassCard(fillsHeight: true) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Daily Activity")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.stPrimaryText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(.bottom, 10)

                if activity != nil {
                    VStack(spacing: 9) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                            ringBarRow(row: row, progress: barProgress[idx])
                        }
                    }
                } else {
                    Text("No data")
                        .font(.caption)
                        .foregroundStyle(.stSecondaryText)
                }

                Spacer(minLength: 0)
            }
        }
        .onAppear { animateBars() }
        .onChange(of: activityKey) { _, _ in
            barProgress = [0, 0, 0]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                animateBars()
            }
        }
    }

    @ViewBuilder
    private func ringBarRow(row: RowData, progress: CGFloat) -> some View {
        VStack(spacing: 5) {
            // Icon + unit label  |  Spacer  |  value
            HStack(spacing: 5) {
                Image(systemName: row.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(row.iconColor)

                Text(row.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.stSecondaryText)

                Spacer()

                Text("\(row.value) \(row.unit)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.stPrimaryText)
                    .lineLimit(1)
            }

            // Progress track + fill
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(row.trackColor)
                        .frame(height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(row.fillColor)
                        .frame(width: max(0, geo.size.width * progress), height: 7)
                }
            }
            .frame(height: 7)
        }
    }

    private func animateBars() {
        let targets = targetProgress
        for i in 0..<3 {
            withAnimation(.easeInOut(duration: 1.4).delay(Double(i) * 0.15)) {
                barProgress[i] = targets[i]
            }
        }
    }
}
