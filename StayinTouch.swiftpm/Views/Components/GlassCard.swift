import SwiftUI

/// Liquid Glass card component using iOS 26's new design language.
/// Uses `.glassEffect()` for the translucent, reflective material that responds to touch.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var isInteractive: Bool = false
    /// When true the card stretches to fill the height proposed by its parent
    /// (used for equal-height paired cards). Other usages stay at natural height.
    var fillsHeight: Bool = false
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .frame(
                maxWidth: fillsHeight ? .infinity : nil,
                maxHeight: fillsHeight ? .infinity : nil,
                alignment: .topLeading
            )
            .clipped()
            .padding(16)
            // Second frame sits immediately outside padding and directly inside
            // glassEffect. iOS 26's glassEffect sizes its glass to its *direct*
            // child — so this frame, accepting the full proposed height, is what
            // makes the glass card fill the height the parent HStack proposes.
            .frame(
                maxWidth: fillsHeight ? .infinity : nil,
                maxHeight: fillsHeight ? .infinity : nil
            )
            .glassEffect(
                isInteractive ? .regular.interactive() : .regular,
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
    }
}

/// Liquid Glass button using iOS 26's glass button style.
struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white.opacity(0.95))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassEffect(.regular.interactive(), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
