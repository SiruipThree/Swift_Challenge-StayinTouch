import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var opacity: Double = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "🌏",
            title: "6,841 miles apart",
            subtitle: "129 days since we last met",
            description: "As an international student, I live thousands of miles from the people I love most. In four years abroad, I've only been home once.",
            accentColor: .stAccent
        ),
        OnboardingPage(
            emoji: "💙",
            title: "Always wondering",
            subtitle: "Is she okay? Did he eat? Are they safe?",
            description: "My parents worry about me. I worry about them. We're all too busy to call every day — but the care never stops.",
            accentColor: .stMoodBlue
        ),
        OnboardingPage(
            emoji: "👋",
            title: "Stayin' Touch",
            subtitle: "Feel close without a single word",
            description: "A gentle way to stay connected. See their mood, know they're healthy, share a moment from your day — and send a little nudge that says \"I'm thinking of you.\"",
            accentColor: .stAccent
        )
    ]
    
    var body: some View {
        ZStack {
            Color.stBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 420)
                
                Spacer()
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.stAccent : Color.white.opacity(0.2))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)
                
                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4)) { currentPage += 1 }
                    } else {
                        withAnimation(.easeOut(duration: 0.4)) { opacity = 0 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onComplete() }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Enter")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.stAccent)
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                
                if currentPage < pages.count - 1 {
                    Button("Skip") { 
                        withAnimation(.easeOut(duration: 0.4)) { opacity = 0 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onComplete() }
                    }
                    .font(.callout)
                    .foregroundStyle(.stSecondaryText)
                    .padding(.bottom, 20)
                }
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { opacity = 1 }
        }
    }
    
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            Text(page.emoji)
                .font(.system(size: 72))
                .shadow(color: page.accentColor.opacity(0.4), radius: 20)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.stPrimaryText)
                .multilineTextAlignment(.center)
            
            Text(page.subtitle)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(page.accentColor)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundStyle(.stSecondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
        }
        .padding(.horizontal, 20)
    }
}

private struct OnboardingPage {
    let emoji: String
    let title: String
    let subtitle: String
    let description: String
    let accentColor: Color
}
