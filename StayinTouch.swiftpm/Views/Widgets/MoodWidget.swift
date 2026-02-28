import SwiftUI

struct MoodWidget: View {
    let mood: MoodEntry?
    let contactName: String
    var isEditable: Bool = false
    /// Last reaction emoji sent to this contact — shown in the right indicator.
    var reactionEmoji: String? = nil
    let onSetMood: (MoodEntry) -> Void
    /// Called when the reaction button is tapped (contact mode only).
    /// HomeTabView shows the picker and burst animation.
    var body: some View {
        ZStack {
            // ── Visual card ───────────────────────────────────────────────
            GlassCard(fillsHeight: true) {
                HStack(spacing: 0) {
                    // Left: emoji + At/Location + vibe label
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 8) {
                            Text(mood?.emoji ?? "😶")
                                .font(.system(size: 32))

                            VStack(alignment: .center, spacing: 1) {
                                Text("At")
                                    .font(.caption2)
                                    .foregroundStyle(.stSecondaryText)
                                Text(strippedLocation(mood?.activity))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.stPrimaryText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .fixedSize()
                        }

                        Text(mood?.label ?? "No mood set")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.stPrimaryText)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    // Right indicator — visual only (no hit testing)
                    VStack {
                        Spacer()
                        rightIndicator
                        Spacer()
                    }
                    .padding(.leading, 4)
                    .allowsHitTesting(false)
                }
            }

            // Tap is handled by HomeTabView's outer-ZStack button (zIndex 25),
            // same pattern as the edit button — no interaction inside the card.
        }
    }

    @ViewBuilder
    private var rightIndicator: some View {
        if isEditable {
            // Pencil — tapped by transparent HomeTabView overlay
            ZStack {
                Circle()
                    .fill(Color(red: 0.22, green: 0.84, blue: 1.0).opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.22, green: 0.84, blue: 1.0))
            }
        } else if let reaction = reactionEmoji {
            // Show the last sent reaction emoji
            ZStack {
                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 36, height: 36)
                Text(reaction)
                    .font(.system(size: 20))
            }
        } else {
            // Default: outline heart SF Symbol (no emoji, subtle)
            ZStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: "heart")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }

    private func strippedLocation(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "–" }
        for prefix in ["After ", "At ", "In ", "On "] {
            if raw.hasPrefix(prefix) { return String(raw.dropFirst(prefix.count)) }
        }
        return raw
    }
}
