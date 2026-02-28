import SwiftUI

struct UserSelectorBar: View {
    let contacts: [User]
    let selectedContact: User?
    let myAvatarEmoji: String
    let onSelect: (User) -> Void
    /// Called when the user taps "Your People" in the expanded deck — deselects contact.
    var onDeselect: () -> Void = {}
    var onExpansionChanged: (Bool) -> Void = { _ in }

    @State private var isExpanded = false

    var body: some View {
        GlassCard(cornerRadius: 28, isInteractive: true) {
            VStack(alignment: .leading, spacing: 12) {
                mainHeaderCard
                    .contentShape(Rectangle())
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.84)) {
                                isExpanded.toggle()
                            }
                            onExpansionChanged(isExpanded)
                        }
                    )

                if isExpanded {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            // ── A: "Your People" home card (first, only when a contact is selected)
                            if selectedContact != nil {
                                Button {
                                    onDeselect()
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                        isExpanded = false
                                    }
                                    onExpansionChanged(false)
                                } label: {
                                    yourPeopleDeckCard
                                }
                                .buttonStyle(.plain)
                                .contentShape(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                )
                            }

                            ForEach(deckContacts) { contact in
                                let selected = contact.id == selectedContact?.id
                                Button {
                                    onSelect(contact)
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                        isExpanded = false
                                    }
                                    onExpansionChanged(false)
                                } label: {
                                    deckContactCard(for: contact, isSelected: selected)
                                }
                                .buttonStyle(.plain)
                                .contentShape(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                )
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .frame(height: 80)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .onChange(of: selectedContact?.id) { _, _ in
            if isExpanded {
                withAnimation(.spring(response: 0.24, dampingFraction: 0.90)) {
                    isExpanded = false
                }
                onExpansionChanged(false)
            }
        }
    }

    // MARK: - Header cards

    @ViewBuilder
    private var mainHeaderCard: some View {
        if let selectedContact {
            mainContactCard(for: selectedContact)
        } else {
            mainPromptCard
        }
    }

    private var mainPromptCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("View Your World")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.stPrimaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)

                // Invisible spacer matching the height of statusRow(compact: false)
                // so this card is the same height as mainContactCard (3-row layout).
                Color.clear.frame(height: 20)

                Text("Tap to check in on someone")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.stSecondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                avatarBubble(emoji: myAvatarEmoji, isSelected: true, size: 58)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func mainContactCard(for contact: User) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.stPrimaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.42)
                statusRow(for: contact, compact: false)
                Text(cityCountry(from: contact.locationName))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.stSecondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                avatarBubble(emoji: contact.avatarEmoji, isSelected: true, size: 58)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Deck cards

    /// "Overview" home card — first item in the expanded list when a contact is selected.
    private var yourPeopleDeckCard: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Me")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.stPrimaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.80)

                HStack(spacing: 4) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Home")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Color.stAccent)
            }

            Spacer(minLength: 6)

            avatarBubble(emoji: myAvatarEmoji, isSelected: true, size: 38)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 186, height: 78, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.stAccent.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.stAccent.opacity(0.65), lineWidth: 1.4)
        )
    }

    private func deckContactCard(for contact: User, isSelected: Bool) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(contact.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.stPrimaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                statusRow(for: contact, compact: true)
                Text(cityCountry(from: contact.locationName))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.stSecondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            avatarBubble(emoji: contact.avatarEmoji, isSelected: isSelected, size: 38)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 186, height: 78, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isSelected ? Color.white.opacity(0.16) : Color.white.opacity(0.11))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    isSelected ? Color.stAccent.opacity(0.72) : Color.white.opacity(0.16),
                    lineWidth: 1.1
                )
        )
    }

    // MARK: - Shared helpers

    private var deckContacts: [User] {
        guard let selectedContact else { return contacts }
        return [selectedContact] + contacts.filter { $0.id != selectedContact.id }
    }

    private func statusRow(for contact: User, compact: Bool) -> some View {
        HStack(spacing: compact ? 5 : 6) {
            Circle()
                .fill(contact.isOnline ? Color.green : Color.gray)
                .frame(width: compact ? 8 : 10, height: compact ? 8 : 10)
            Text(contact.isOnline ? "Live" : "Offline")
                .font(compact
                      ? .system(size: 13, weight: .semibold)
                      : .system(size: 16, weight: .semibold))
                .foregroundStyle(contact.isOnline ? .green : .stSecondaryText)
        }
    }

    private func avatarBubble(emoji: String, isSelected: Bool, size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.stAccent.opacity(0.26) : Color.white.opacity(0.08))
                .frame(width: size, height: size)
            Circle()
                .stroke(
                    isSelected ? Color.stAccent : Color.white.opacity(0.20),
                    lineWidth: isSelected ? 2.6 : 1.2
                )
                .frame(width: size, height: size)
            Text(emoji)
                .font(.system(size: size * 0.47))
        }
    }

    private func cityCountry(from locationName: String) -> String {
        let segments = locationName
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard let city = segments.first else { return locationName }
        guard let country = segments.last, segments.count > 1 else { return city }
        return "\(city), \(country)"
    }
}
