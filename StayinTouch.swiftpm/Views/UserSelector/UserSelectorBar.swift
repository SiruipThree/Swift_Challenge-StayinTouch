import SwiftUI

struct UserSelectorBar: View {
    let currentUser: User
    let contacts: [User]
    let selectedContact: User
    let onSelect: (User) -> Void
    
    var body: some View {
        GlassCard(cornerRadius: 24) {
            HStack(spacing: 0) {
                // Contact name and status
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedContact.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.stPrimaryText)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(selectedContact.isOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        Text(selectedContact.isOnline ? "Live" : "Offline")
                            .font(.caption)
                            .foregroundStyle(selectedContact.isOnline ? .green : .stSecondaryText)
                    }
                }
                
                Spacer()
                
                // Avatar selector
                HStack(spacing: -4) {
                    ForEach(contacts) { contact in
                        Button { onSelect(contact) } label: {
                            avatarBubble(
                                emoji: contact.avatarEmoji,
                                name: contact.name,
                                isSelected: contact.id == selectedContact.id
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func avatarBubble(emoji: String, name: String, isSelected: Bool) -> some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.stAccent.opacity(0.2) : Color.white.opacity(0.08))
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    Circle()
                        .stroke(Color.stAccent, lineWidth: 2)
                        .frame(width: 44, height: 44)
                }
                
                Text(emoji)
                    .font(.title3)
            }
            
            Text(name)
                .font(.system(size: 10))
                .foregroundStyle(isSelected ? Color.stAccent : .stSecondaryText)
        }
        .padding(.horizontal, 4)
    }
}
