import SwiftUI

/// Today widget — purely visual display. All tap interactions are handled by
/// HomeTabView overlays at zIndex 25 (above the globe interaction layer at zIndex 10).
struct TodayWidget: View {
    let posts: [TodayPost]
    /// Label shown on the Share/Edit CTA at the bottom. Pass nil to hide the CTA entirely
    /// (used on contact pages where only view-detail is available, not editing).
    var shareButtonLabel: String? = "Share My Today"

    // Post expires 24h after creation; warn when ≤ 4h remain.
    private var expiryWarning: String? {
        guard let first = posts.first else { return nil }
        let remaining = first.timestamp.addingTimeInterval(86400).timeIntervalSinceNow
        guard remaining > 0, remaining < 4 * 3600 else { return nil }
        let hours = Int(remaining / 3600)
        let mins  = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        return hours > 0 ? "Expires in \(hours)h" : "Expires in \(mins)m"
    }

    var body: some View {
        GlassCard(fillsHeight: true) {
            VStack(alignment: .leading, spacing: 8) {

                // ── Header ────────────────────────────────────────────────────
                HStack {
                    Text("Today")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.stPrimaryText)
                    Spacer()
                    if let warning = expiryWarning {
                        // Amber expiry badge
                        HStack(spacing: 3) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .font(.system(size: 10))
                            Text(warning)
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.orange)
                    } else if let first = posts.first {
                        Text(timeAgo(first.timestamp))
                            .font(.caption)
                            .foregroundStyle(.stSecondaryText)
                    }
                }

                if posts.isEmpty {
                    // ── Empty state ───────────────────────────────────────────
                    emptyStateView()
                } else {
                    // ── Photo thumbnail (single, wider landscape crop) ─────────
                    if let latest = posts.first { photoThumbnail(latest) }

                    // ── Caption ────────────────────────────────────────────────
                    if let first = posts.first {
                        Text(first.caption)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.stPrimaryText)
                            .lineLimit(2)
                            .minimumScaleFactor(0.84)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Spacer pushes the CTA to the very bottom so the overlay aligns.
                Spacer(minLength: 0)

                // ── Share CTA (home only) ─────────────────────────────────────
                // Hidden on contact pages. Visual only — tap captured by HomeTabView.
                if let label = shareButtonLabel {
                    HStack(spacing: 5) {
                        Image(systemName: posts.isEmpty
                              ? "plus.circle.fill"
                              : "person.crop.circle.badge.plus")
                            .font(.system(size: 11, weight: .semibold))
                        Text(posts.isEmpty ? "Share your day" : label)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Color.stAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.stAccent.opacity(posts.isEmpty ? 0.18 : 0.12))
                            .overlay(Capsule().stroke(Color.stAccent.opacity(0.35), lineWidth: 0.8))
                    )
                }
            }
        }
    }

    // ── Empty state placeholder ───────────────────────────────────────────────
    @ViewBuilder
    private func emptyStateView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 1.2, dash: [5, 4])
                )
                .foregroundStyle(Color.white.opacity(0.18))
                .frame(maxWidth: .infinity)
                .frame(height: 72)

            VStack(spacing: 4) {
                Image(systemName: shareButtonLabel != nil ? "sun.horizon" : "moon.zzz")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.white.opacity(0.35))
                Text(shareButtonLabel != nil
                     ? "Nothing shared yet"
                     : "Quiet today")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.35))
            }
        }
    }

    private func photoThumbnail(_ post: TodayPost) -> some View {
        Group {
            if let data = post.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 80)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(gradientForPhoto(post.photoName))
                    .frame(width: 100, height: 80)
                    .overlay(
                        Image(systemName: iconForPhoto(post.photoName))
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.8))
                    )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }

    private func gradientForPhoto(_ name: String) -> LinearGradient {
        let colors: [Color] = {
            switch name {
            case "photo_cherry_blossom": return [.pink.opacity(0.6), .purple.opacity(0.4)]
            case "photo_park_bench":     return [.green.opacity(0.5), .brown.opacity(0.3)]
            case "photo_flower":         return [.orange.opacity(0.5), .pink.opacity(0.4)]
            case "photo_home_cooking":   return [.orange.opacity(0.6), .yellow.opacity(0.3)]
            case "photo_sunset":         return [.orange.opacity(0.5), .purple.opacity(0.5)]
            case "photo_campus":         return [.blue.opacity(0.4), .gray.opacity(0.3)]
            case "photo_coffee":         return [.brown.opacity(0.5), .orange.opacity(0.3)]
            default:                     return [.gray.opacity(0.3), .gray.opacity(0.2)]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func iconForPhoto(_ name: String) -> String {
        switch name {
        case "photo_cherry_blossom": return "leaf.fill"
        case "photo_park_bench":     return "tree.fill"
        case "photo_flower":         return "camera.macro"
        case "photo_home_cooking":   return "fork.knife"
        case "photo_sunset":         return "sun.horizon.fill"
        case "photo_campus":         return "building.columns.fill"
        case "photo_coffee":         return "cup.and.saucer.fill"
        default:                     return "photo"
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        return "\(hours)h ago"
    }
}

// MARK: - Grouped Reactions View

/// Displays reactions grouped by emoji with staggered spring entrance animation.
/// Used only on "my" own Today posts — shows who reacted and how many.
/// Tap any pill to see the full list of people who sent that reaction.
struct GroupedReactionsView: View {

    let reactions: [Reaction]

    struct Group: Identifiable {
        let id: String
        let emoji: String
        let count: Int
        let avatars: [String]
    }

    struct DetailGroup: Identifiable {
        let id: String
        let emoji: String
        let members: [(avatar: String, userId: String)]
    }

    private var groups: [Group] {
        var map: [String: [Reaction]] = [:]
        for r in reactions { map[r.emoji, default: []].append(r) }
        return map.map { emoji, rs in
            Group(id: emoji, emoji: emoji, count: rs.count,
                  avatars: Array(rs.prefix(3).map(\.fromUserEmoji)))
        }.sorted { $0.count > $1.count }
    }

    private func detailGroup(for emoji: String) -> DetailGroup {
        let rs = reactions.filter { $0.emoji == emoji }
        return DetailGroup(
            id: emoji,
            emoji: emoji,
            members: rs.map { (avatar: $0.fromUserEmoji, userId: $0.fromUserId) }
        )
    }

    @State private var appeared = false
    @State private var selectedDetailGroup: DetailGroup? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Friends reacted")
                .font(.caption)
                .foregroundStyle(.stSecondaryText)

            HStack(spacing: 10) {
                ForEach(Array(groups.enumerated()), id: \.element.id) { idx, group in
                    Button {
                        selectedDetailGroup = detailGroup(for: group.emoji)
                    } label: {
                        reactionPill(group)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(appeared ? 1.0 : 0.4)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.65)
                        .delay(Double(idx) * 0.08),
                        value: appeared
                    )
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { appeared = true }
        .sheet(item: $selectedDetailGroup) { detail in
            reactionDetailSheet(detail)
        }
    }

    private func reactionPill(_ group: Group) -> some View {
        HStack(spacing: 6) {
            Text(group.emoji)
                .font(.title3)

            if group.count > 1 {
                Text("\(group.count)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.stSecondaryText)
            }

            HStack(spacing: -6) {
                ForEach(group.avatars.indices, id: \.self) { i in
                    Text(group.avatars[i])
                        .font(.system(size: 13))
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.stBackground))
                        .overlay(Circle().stroke(Color.stCardBorder, lineWidth: 0.8))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
                .overlay(Capsule().stroke(Color.stCardBorder, lineWidth: 0.5))
        )
    }

    @ViewBuilder
    private func reactionDetailSheet(_ detail: DetailGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(detail.emoji)
                    .font(.largeTitle)
                Text("Reactions")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(detail.members.count) people")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 16)

            Divider().padding(.horizontal, 24)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(detail.members.enumerated()), id: \.offset) { idx, member in
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color.white.opacity(0.10))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Text(member.avatar)
                                        .font(.system(size: 22))
                                )
                            Text(displayName(for: member.userId))
                                .font(.body).fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)

                        if idx < detail.members.count - 1 {
                            Divider().padding(.leading, 80)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .presentationDetents([.medium])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(28)
    }

    private func displayName(for userId: String) -> String {
        switch userId {
        case "mom":     return "Mom"
        case "dad":     return "Dad"
        case "hayden":  return "Hayden"
        case "tommy":   return "Tommy"
        case "eric":    return "Eric"
        case "mengxi":  return "Mengxi"
        case "grandma": return "Grandma"
        case "grandpa":     return "Grandpa"
        case "grandmaLong": return "Grandma Long"
        case "songshu": return "Songshu"
        case "gege":    return "Brother"
        case "jiejie":  return "Sister"
        case "mg":      return "Mg"
        case "me":      return "Me"
        default:        return userId
        }
    }
}

// MARK: - Today Detail View (Sheet)

struct TodayDetailView: View {
    let post: TodayPost
    let onReaction: (ReactionOption, TodayPost) -> Void
    /// True when viewing the current user's own post — shows grouped friend reactions
    /// instead of the React bar (you can't react to your own post).
    var isMyPost: Bool = false
    /// Notes already sent in previous sessions (loaded from AppViewModel).
    var initialSentNotes: [String] = []
    /// Called whenever a new note is sent — caller should persist it.
    var onNoteSent: (String) -> Void = { _ in }
    /// Called when the user confirms post deletion. nil = no delete capability.
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var noteSent = false
    @State private var noteText = ""
    @State private var sentNotes: [String] = []
    @State private var selectedReaction: ReactionOption? = nil
    @State private var burstEmoji: String? = nil
    @State private var showDeleteConfirm = false

    // Remaining lifetime: positive = still live, negative = expired.
    private var remainingSeconds: TimeInterval {
        post.timestamp.addingTimeInterval(86400).timeIntervalSinceNow
    }
    private var isNearingExpiry: Bool { remainingSeconds > 0 && remainingSeconds < 4 * 3600 }
    private var expiryLabel: String {
        let h = Int(remainingSeconds / 3600)
        let m = Int((remainingSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        return h > 0 ? "~\(h)h left" : "~\(m)m left"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Photo ──────────────────────────────────────────────────
                    photoHero()

                    // ── Caption ───────────────────────────────────────────────
                    Text(post.caption)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.stPrimaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // ── Expiry warning (isMyPost only, ≤4h remaining) ─────────
                    if isMyPost && isNearingExpiry {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.badge.exclamationmark.fill")
                                .font(.system(size: 13))
                            Text("This post will disappear soon — \(expiryLabel)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.30), lineWidth: 0.8))
                        )
                    }

                    Divider().opacity(0.3)

                    if isMyPost {
                        // ── MY POST: grouped friend reactions (read-only) ──────
                        if !post.reactions.isEmpty {
                            GroupedReactionsView(reactions: post.reactions)
                        }

                        // ── Messages from friends ──────────────────────────────
                        if !post.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Messages")
                                    .font(.caption)
                                    .foregroundStyle(.stSecondaryText)
                                ForEach(post.notes) { note in
                                    noteRow(note)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // ── Your own sent notes ────────────────────────────────
                        if !sentNotes.isEmpty { yourNotesSection() }

                        // ── Note input ─────────────────────────────────────────
                        noteInputRow()

                    } else {
                        // ── CONTACT POST: React bar (my reactions only) ────────
                        VStack(spacing: 10) {
                            Text("React")
                                .font(.caption)
                                .foregroundStyle(.stSecondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 12) {
                                ForEach(ReactionOption.allCases) { option in
                                    let isSelected = selectedReaction == option
                                    Button {
                                        if isSelected {
                                            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                                                selectedReaction = nil
                                            }
                                        } else {
                                            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                                                selectedReaction = option
                                            }
                                            onReaction(option, post)
                                            burstEmoji = option.rawValue
                                        }
                                    } label: {
                                        Text(option.rawValue)
                                            .font(.title2)
                                            .padding(10)
                                            .background(
                                                Circle()
                                                    .fill(isSelected ? Color.stAccent.opacity(0.28) : Color.white.opacity(0.08))
                                                    .overlay(Circle().stroke(isSelected ? Color.stAccent.opacity(0.7) : Color.clear, lineWidth: 1.5))
                                            )
                                            .scaleEffect(isSelected ? 1.12 : 1.0)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // ── Your own sent notes ────────────────────────────────
                        if !sentNotes.isEmpty { yourNotesSection() }

                        // ── Note input ─────────────────────────────────────────
                        noteInputRow()
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .overlay {
                if noteSent {
                    SendConfirmationOverlay(emoji: "💌", message: "Sent!", isVisible: $noteSent)
                }
                if let emoji = burstEmoji {
                    GeometryReader { geo in
                        ReactionBurstView(
                            emoji: emoji,
                            origin: CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.42)
                        ) { burstEmoji = nil }
                    }
                    .allowsHitTesting(false)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.stAccent)
                }
                if isMyPost, onDelete != nil {
                    ToolbarItem(placement: .destructiveAction) {
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                }
            }
            .alert("Delete Post?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    dismiss()
                    onDelete?()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This post will be removed immediately and can't be undone.")
            }
        }
        .onAppear {
            // Restore persisted notes for this post
            sentNotes = initialSentNotes
            // For contact posts: pre-select my previous reaction (if any)
            if !isMyPost {
                if let mine = post.reactions.first(where: { $0.fromUserId == "me" }),
                   let option = ReactionOption(rawValue: mine.emoji) {
                    selectedReaction = option
                }
            }
        }
    }

    // ── Sub-views ──────────────────────────────────────────────────────────────

    @ViewBuilder
    private func noteRow(_ note: ContactNote) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(note.fromUserEmoji)
                .font(.system(size: 22))
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.white.opacity(0.08)))
            VStack(alignment: .leading, spacing: 2) {
                Text(note.fromUserName)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.stSecondaryText)
                Text(note.text)
                    .font(.callout)
                    .foregroundStyle(.stPrimaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.stCardBorder, lineWidth: 0.5))
        )
    }

    @ViewBuilder
    private func yourNotesSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your notes")
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
            ForEach(sentNotes.indices, id: \.self) { idx in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.stAccent)
                        .font(.caption)
                    Text(sentNotes[idx])
                        .font(.callout)
                        .foregroundStyle(.stPrimaryText)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.stAccent.opacity(0.08)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func noteInputRow() -> some View {
        HStack(spacing: 10) {
            TextField("Write a quick note...", text: $noteText)
                .textFieldStyle(.plain)
                .font(.callout)
                .foregroundStyle(.stPrimaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.stCardBorder, lineWidth: 0.5))
                )
            if !noteText.isEmpty {
            Button {
                let trimmed = noteText.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                sentNotes.append(trimmed)
                onNoteSent(trimmed)   // persist in AppViewModel
                noteText = ""
                noteSent = true
            } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(Color.stAccent)
                        .padding(10)
                        .background(Circle().fill(Color.stAccent.opacity(0.15)))
                }
            }
        }
    }

    // ── Photo hero: real image takes priority over gradient placeholder ────────
    @ViewBuilder
    private func photoHero() -> some View {
        if let data = post.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 260)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(gradientForPhoto(post.photoName))
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                Image(systemName: iconForPhoto(post.photoName))
                    .font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }

    private func gradientForPhoto(_ name: String) -> LinearGradient {
        let colors: [Color] = {
            switch name {
            case "photo_cherry_blossom": return [.pink.opacity(0.55), .purple.opacity(0.4)]
            case "photo_park_bench":     return [.green.opacity(0.5), .brown.opacity(0.3)]
            case "photo_flower":         return [.orange.opacity(0.5), .pink.opacity(0.4)]
            case "photo_home_cooking":   return [.orange.opacity(0.6), .yellow.opacity(0.3)]
            case "photo_sunset":         return [.orange.opacity(0.5), .purple.opacity(0.5)]
            case "photo_campus":         return [.blue.opacity(0.4), .gray.opacity(0.3)]
            case "photo_coffee":         return [.brown.opacity(0.5), .orange.opacity(0.3)]
            default:                     return [.blue.opacity(0.3), .purple.opacity(0.3)]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func iconForPhoto(_ name: String) -> String {
        switch name {
        case "photo_cherry_blossom": return "leaf.fill"
        case "photo_park_bench":     return "tree.fill"
        case "photo_flower":         return "camera.macro"
        case "photo_home_cooking":   return "fork.knife"
        case "photo_sunset":         return "sun.horizon.fill"
        case "photo_campus":         return "building.columns.fill"
        case "photo_coffee":         return "cup.and.saucer.fill"
        default:                     return "photo"
        }
    }
}
