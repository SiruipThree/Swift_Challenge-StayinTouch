import SwiftUI

/// People tab: Grid of all contacts sorted by longest separation first.
struct PeopleTabView: View {
    @Bindable var viewModel: AppViewModel

    @State private var showDemoAlert = false

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    /// Contacts sorted by daysApart descending (longest apart → first card).
    private var sortedContacts: [User] {
        viewModel.contacts.sorted {
            $0.lastSeenDate < $1.lastSeenDate   // older lastSeen = further apart
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.stBackgroundGradientTop, Color.stBackgroundGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Header: title + add button ────────────────────────────
                    HStack(alignment: .firstTextBaseline) {
                        Text("People")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.stPrimaryText)

                        Spacer()

                        Button {
                            showDemoAlert = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.10))
                                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 0.8))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "plus")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.stPrimaryText)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // ── Grid ──────────────────────────────────────────────────
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(sortedContacts) { contact in
                            PersonCard(
                                contact: contact,
                                mood: viewModel.moods[contact.id]
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)
                }
            }
        }
        .alert("Demo Mode", isPresented: $showDemoAlert) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("Adding new friends isn't available in demo mode.")
        }
    }
}

// MARK: - Person Card

private struct PersonCard: View {
    let contact: User
    let mood: MoodEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Top row: avatar + online dot + separation badge ─────────────
            HStack(alignment: .top) {
                ZStack(alignment: .bottomTrailing) {
                    Text(contact.avatarEmoji)
                        .font(.system(size: 38))
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(Color.white.opacity(0.08)))

                    if contact.isOnline {
                        Circle()
                            .fill(Color(red: 0.22, green: 0.85, blue: 0.45))
                            .frame(width: 13, height: 13)
                            .overlay(Circle().stroke(Color(red: 0.09, green: 0.09, blue: 0.15), lineWidth: 2))
                    }
                }

                Spacer(minLength: 0)

                // Separation time badge
                separationBadge
            }

            // ── Name ────────────────────────────────────────────────────────
            Text(contact.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.stPrimaryText)
                .lineLimit(1)

            // ── Location ────────────────────────────────────────────────────
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundStyle(.stSecondaryText)
                Text(shortLocation(contact.locationName))
                    .font(.caption)
                    .foregroundStyle(.stSecondaryText)
                    .lineLimit(1)
            }

            // ── Mood pill ───────────────────────────────────────────────────
            if let mood {
                HStack(spacing: 5) {
                    Text(mood.emoji)
                        .font(.system(size: 13))
                    Text(mood.label)
                        .font(.caption)
                        .foregroundStyle(.stSecondaryText)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.white.opacity(0.07)))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Separation badge

    private var separationBadge: some View {
        let (text, color) = separationInfo(contact.lastSeenDate)
        return VStack(spacing: 2) {
            Image(systemName: "clock.arrow.2.circlepath")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.28), lineWidth: 0.8))
        )
    }

    /// Returns (display text, badge color) for the time since last seen.
    private func separationInfo(_ date: Date) -> (String, Color) {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: date, to: now
        )
        let years  = components.year  ?? 0
        let months = components.month ?? 0
        let days   = components.day   ?? 0
        let hours  = components.hour  ?? 0

        let text: String
        if years > 0 {
            text = months > 0 ? "\(years)y \(months)m" : "\(years)y"
        } else if months > 0 {
            text = "\(months)m"
        } else if days > 0 {
            text = "\(days)d"
        } else {
            text = "\(max(hours, 1))h"
        }

        // Color: warm orange for long separations, cyan for medium, soft green for recent
        let color: Color
        if years >= 1 {
            color = Color(red: 1.0, green: 0.60, blue: 0.25)   // warm orange
        } else if months >= 3 {
            color = Color(red: 1.0, green: 0.82, blue: 0.30)   // amber
        } else if days >= 1 {
            color = Color(red: 0.35, green: 0.78, blue: 0.98)  // cyan
        } else {
            color = Color(red: 0.35, green: 0.88, blue: 0.58)  // mint green
        }

        return (text, color)
    }

    private func shortLocation(_ full: String) -> String {
        full.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? full
    }
}
