import SwiftUI

// MARK: - Location Sharing Mode

enum LocationSharingMode: String, CaseIterable, Identifiable {
    case on       = "on"
    case off      = "off"
    case freeze3  = "freeze3"
    case freeze5  = "freeze5"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .on:      "On"
        case .off:     "Off"
        case .freeze3: "Off for 3 Days"
        case .freeze5: "Off for 5 Days"
        }
    }

    var icon: String {
        switch self {
        case .on:      "location.fill"
        case .off:     "location.slash.fill"
        case .freeze3: "snowflake"
        case .freeze5: "snowflake"
        }
    }

    var iconColor: Color {
        switch self {
        case .on:      .green
        case .off:     .red.opacity(0.8)
        case .freeze3: .cyan
        case .freeze5: .cyan
        }
    }

    /// Whether this mode requires the "freeze" confirmation dialog.
    var requiresConfirmation: Bool {
        self == .freeze3 || self == .freeze5
    }

    var freezeDays: Int {
        switch self {
        case .freeze3: 3
        case .freeze5: 5
        default:       0
        }
    }
}

// MARK: - Settings View

/// Settings tab: User profile, location sharing, and app info.
struct SettingsView: View {
    @Bindable var viewModel: AppViewModel

    @State private var locationMode: LocationSharingMode = .on
    @State private var pendingMode: LocationSharingMode? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.stBackgroundGradientTop, Color.stBackgroundGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                GlassEffectContainer(spacing: 24) {
                    VStack(spacing: 24) {

                        // ── Profile header ────────────────────────────────────
                        VStack(spacing: 12) {
                            Text(viewModel.currentUser.avatarEmoji)
                                .font(.system(size: 64))
                            Text(viewModel.currentUser.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.stPrimaryText)
                            Text(viewModel.currentUser.locationName)
                                .font(.subheadline)
                                .foregroundStyle(.stSecondaryText)
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))

                        // ── Location Sharing ──────────────────────────────────
                        locationSection

                        // ── About ─────────────────────────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.stPrimaryText)

                            VStack(spacing: 0) {
                                settingsRow(title: "StayinTouch", subtitle: "Swift Student Challenge 2026")
                                Divider().background(Color.white.opacity(0.2)).padding(.leading, 16)
                                settingsRow(title: "Version", subtitle: "1.0")
                            }
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
                        }

                        // ── Story ─────────────────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("The Story")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.stPrimaryText)

                            Text("As an international student, I've been away from home for four years. StayinTouch connects me with the people I love—without words, across distances.")
                                .font(.subheadline)
                                .foregroundStyle(.stSecondaryText)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                }
            }
        }
        // ── Freeze confirmation sheet ─────────────────────────────────────────
        .sheet(item: $pendingMode) { mode in
            FreezeConfirmSheet(freezeMode: mode) { confirmed in
                if confirmed {
                    withAnimation(.spring(response: 0.3)) { locationMode = mode }
                }
                pendingMode = nil
            }
        }
    }

    // MARK: - Location section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.stAccent)
                Text("Location Sharing")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.stPrimaryText)
            }

            // Status badge
            HStack(spacing: 6) {
                Image(systemName: locationMode.icon)
                    .font(.system(size: 12))
                Text(locationStatusLabel)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(locationMode.iconColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(locationMode.iconColor.opacity(0.12))
                    .overlay(Capsule().stroke(locationMode.iconColor.opacity(0.3), lineWidth: 0.8))
            )

            // Option rows
            VStack(spacing: 0) {
                ForEach(Array(LocationSharingMode.allCases.enumerated()), id: \.element.id) { idx, mode in
                    locationOptionRow(mode)
                    if idx < LocationSharingMode.allCases.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.12))
                            .padding(.leading, 50)
                    }
                }
            }
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

            // Contextual hint
            if locationMode == .off {
                hintRow(
                    icon: "eye.slash",
                    color: .red.opacity(0.8),
                    text: "Your contacts can no longer see your location."
                )
            } else if locationMode.requiresConfirmation {
                hintRow(
                    icon: "snowflake",
                    color: .cyan,
                    text: "Your location appears frozen for \(locationMode.freezeDays) days. Contacts won't know sharing is paused."
                )
            }
        }
    }

    private func locationOptionRow(_ mode: LocationSharingMode) -> some View {
        let isSelected = locationMode == mode
        return Button {
            selectMode(mode)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(mode.iconColor.opacity(isSelected ? 0.2 : 0.08))
                        .frame(width: 34, height: 34)
                    Image(systemName: mode.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(mode.iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.label)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(.stPrimaryText)
                    if mode.requiresConfirmation {
                        Text("Freezes your last known location")
                            .font(.caption2)
                            .foregroundStyle(.stSecondaryText)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(mode.iconColor)
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func hintRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .padding(.top, 1)
            Text(text)
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
                .lineSpacing(3)
        }
        .padding(.horizontal, 4)
    }

    private var locationStatusLabel: String {
        switch locationMode {
        case .on:      "Sharing live location"
        case .off:     "Location sharing off"
        case .freeze3: "Frozen for 3 days"
        case .freeze5: "Frozen for 5 days"
        }
    }

    private func selectMode(_ mode: LocationSharingMode) {
        if mode.requiresConfirmation {
            pendingMode = mode
        } else {
            withAnimation(.spring(response: 0.3)) {
                locationMode = mode
            }
        }
    }

    // MARK: - Shared helpers

    private func settingsRow(title: String, subtitle: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.stPrimaryText)
            Spacer()
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
        }
        .padding(16)
    }
}

// MARK: - Freeze Confirmation Sheet

struct FreezeConfirmSheet: View {
    let freezeMode: LocationSharingMode
    let onDismiss: (Bool) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 14)
                .padding(.bottom, 24)

            // Icon
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "snowflake")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.cyan)
            }
            .padding(.bottom, 20)

            // Title
            Text("Freeze Location for \(freezeMode.freezeDays) Days?")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 14)

            // Explanation card
            VStack(alignment: .leading, spacing: 12) {
                explanationRow(
                    icon: "eye",
                    color: .cyan,
                    title: "Invisible to contacts",
                    body: "They won't see a \"location off\" message or any notification."
                )
                Divider().opacity(0.2)
                explanationRow(
                    icon: "mappin.and.ellipse",
                    color: .orange,
                    title: "Last location stays visible",
                    body: "Your location will appear frozen at your current position for \(freezeMode.freezeDays) days."
                )
                Divider().opacity(0.2)
                explanationRow(
                    icon: "arrow.clockwise",
                    color: .green,
                    title: "Auto-resumes after \(freezeMode.freezeDays) days",
                    body: "Live sharing restores automatically when the period ends."
                )
            }
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 24)
            .padding(.bottom, 28)

            // Buttons
            VStack(spacing: 10) {
                Button {
                    onDismiss(true)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "snowflake")
                        Text("Freeze for \(freezeMode.freezeDays) Days")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.cyan.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.black)
                }

                Button {
                    onDismiss(false)
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.18), lineWidth: 0.8))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .presentationDetents([.fraction(0.72)])
        .presentationBackground(Color(red: 0.10, green: 0.11, blue: 0.20))
        .presentationCornerRadius(28)
    }

    private func explanationRow(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
