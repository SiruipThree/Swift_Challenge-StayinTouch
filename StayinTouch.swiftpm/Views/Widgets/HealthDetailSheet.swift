import SwiftUI

struct HealthDetailSheet: View {
    let health: HealthSnapshot?
    let contactName: String

    private struct HealthRow: Identifiable {
        let id = UUID()
        let icon: String
        let iconColor: Color
        let title: String
        let value: String
        let subtitle: String
    }

    private var rows: [HealthRow] {
        guard let h = health else { return [] }
        return [
            HealthRow(
                icon: "heart.fill",
                iconColor: Color(red: 1.0, green: 0.27, blue: 0.38),
                title: "Heart Rate",
                value: "\(h.heartRate) BPM",
                subtitle: h.heartStatus.rawValue
            ),
            HealthRow(
                icon: "bed.double.fill",
                iconColor: Color(red: 0.42, green: 0.46, blue: 1.0),
                title: "Sleep",
                value: String(format: "%.1f hrs", h.sleepHours),
                subtitle: h.sleepHours >= 7 ? "Well rested" : "Could use more"
            ),
            HealthRow(
                icon: "thermometer.medium",
                iconColor: Color(red: 1.0, green: 0.58, blue: 0.18),
                title: "Wrist Temp",
                value: String(format: "%.1f °C", h.wristTemperature),
                subtitle: h.wristTemperature > 36.5 ? "Slightly warm" : "Normal"
            ),
            HealthRow(
                icon: "lungs.fill",
                iconColor: Color(red: 0.20, green: 0.78, blue: 0.96),
                title: "Blood Oxygen",
                value: "\(h.bloodOxygen)%",
                subtitle: h.bloodOxygen >= 97 ? "Excellent" : h.bloodOxygen >= 95 ? "Normal" : "Low"
            ),
            HealthRow(
                icon: "waveform.path.ecg",
                iconColor: Color(red: 0.22, green: 0.84, blue: 0.56),
                title: "HRV",
                value: "\(h.hrv) ms",
                subtitle: h.hrv >= 50 ? "Well recovered" : h.hrv >= 30 ? "Moderate" : "Stressed"
            ),
            HealthRow(
                icon: "wind",
                iconColor: Color(red: 0.46, green: 0.76, blue: 0.88),
                title: "Respiratory Rate",
                value: "\(h.respiratoryRate) breaths/min",
                subtitle: h.respiratoryRate <= 16 ? "Normal" : "Elevated"
            ),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Health")
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                    Text(contactName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                updatedLabel
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 24)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(rows) { row in
                        healthRow(row)
                        if row.id != rows.last?.id {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

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
    }

    @ViewBuilder
    private func healthRow(_ row: HealthRow) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(row.iconColor.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: row.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(row.iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(row.value)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text(row.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private var updatedLabel: some View {
        if let h = health {
            Text(relativeTime(h.lastUpdated))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        return "\(minutes / 60)h ago"
    }
}
