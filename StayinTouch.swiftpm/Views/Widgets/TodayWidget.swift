import SwiftUI

struct TodayWidget: View {
    let posts: [TodayPost]
    let myPosts: [TodayPost]
    let contactName: String
    let onReaction: (ReactionOption, TodayPost) -> Void
    
    @State private var showDetail = false
    @State private var showMyPosts = false
    @State private var selectedPost: TodayPost?
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Today")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.stPrimaryText)
                    
                    Spacer()
                    
                    if let first = posts.first {
                        Text(timeAgo(first.timestamp))
                            .font(.caption)
                            .foregroundStyle(.stSecondaryText)
                    }
                }
                
                // Photo thumbnails row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(posts) { post in
                            Button {
                                selectedPost = post
                                showDetail = true
                            } label: {
                                photoThumbnail(post)
                            }
                        }
                    }
                }
                
                if let firstPost = posts.first {
                    Text(firstPost.caption)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.stPrimaryText)
                }
                
                // Toggle to see your own Today
                Button {
                    withAnimation(.spring(response: 0.3)) { showMyPosts.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showMyPosts ? "person.fill" : "person")
                            .font(.caption)
                        Text(showMyPosts ? "My Today" : "Show My Today")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.stAccent)
                }
                
                if showMyPosts {
                    myPostsSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            if let post = selectedPost {
                TodayDetailView(post: post, onReaction: onReaction)
                    .presentationDetents([.medium, .large])
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
    
    private func photoThumbnail(_ post: TodayPost) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(gradientForPhoto(post.photoName))
            .frame(width: 70, height: 70)
            .overlay(
                VStack {
                    Spacer()
                    Image(systemName: iconForPhoto(post.photoName))
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
    }
    
    private var myPostsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Today")
                .font(.caption)
                .foregroundStyle(.stSecondaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(myPosts) { post in
                        VStack(spacing: 4) {
                            photoThumbnail(post)
                            Text(post.caption)
                                .font(.caption2)
                                .foregroundStyle(.stSecondaryText)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(.top, 4)
    }
    
    private func gradientForPhoto(_ name: String) -> LinearGradient {
        let colors: [Color] = {
            switch name {
            case "photo_cherry_blossom": return [.pink.opacity(0.6), .purple.opacity(0.4)]
            case "photo_park_bench": return [.green.opacity(0.5), .brown.opacity(0.3)]
            case "photo_flower": return [.orange.opacity(0.5), .pink.opacity(0.4)]
            case "photo_home_cooking": return [.orange.opacity(0.6), .yellow.opacity(0.3)]
            case "photo_sunset": return [.orange.opacity(0.5), .purple.opacity(0.5)]
            case "photo_campus": return [.blue.opacity(0.4), .gray.opacity(0.3)]
            case "photo_coffee": return [.brown.opacity(0.5), .orange.opacity(0.3)]
            default: return [.gray.opacity(0.3), .gray.opacity(0.2)]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private func iconForPhoto(_ name: String) -> String {
        switch name {
        case "photo_cherry_blossom": return "leaf.fill"
        case "photo_park_bench": return "tree.fill"
        case "photo_flower": return "camera.macro"
        case "photo_home_cooking": return "fork.knife"
        case "photo_sunset": return "sun.horizon.fill"
        case "photo_campus": return "building.columns.fill"
        case "photo_coffee": return "cup.and.saucer.fill"
        default: return "photo"
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        return "\(hours)h ago"
    }
}

// MARK: - Today Detail View (Sheet)

struct TodayDetailView: View {
    let post: TodayPost
    let onReaction: (ReactionOption, TodayPost) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var reactionSent = false
    @State private var noteText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Large photo placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white.opacity(0.5))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(post.caption)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.stPrimaryText)
                
                // Existing reactions
                if !post.reactions.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(post.reactions) { reaction in
                            Text(reaction.emoji)
                                .font(.title3)
                        }
                    }
                }
                
                // Reaction bar
                VStack(spacing: 8) {
                    Text("Send a reaction")
                        .font(.caption)
                        .foregroundStyle(.stSecondaryText)
                    
                    HStack(spacing: 12) {
                        ForEach(ReactionOption.allCases) { option in
                            Button {
                                onReaction(option, post)
                                reactionSent = true
                            } label: {
                                Text(option.rawValue)
                                    .font(.title)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.08))
                                    )
                            }
                        }
                    }
                }
                
                // Quick note
                HStack {
                    TextField("Write a quick note...", text: $noteText)
                        .textFieldStyle(.plain)
                        .font(.callout)
                        .foregroundStyle(.stPrimaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.stCardBorder, lineWidth: 0.5)
                                )
                        )
                    
                    if !noteText.isEmpty {
                        Button {
                            noteText = ""
                            reactionSent = true
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(Color.stAccent)
                                .padding(10)
                                .background(Circle().fill(Color.stAccent.opacity(0.15)))
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.stAccent)
                }
            }
            .overlay {
                if reactionSent {
                    SendConfirmationOverlay(
                        emoji: "💌",
                        message: "Sent!",
                        isVisible: $reactionSent
                    )
                }
            }
        }
    }
}
